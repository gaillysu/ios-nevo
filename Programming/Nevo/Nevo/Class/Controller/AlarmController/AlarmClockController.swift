//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import RealmSwift
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
    import RxDataSources
#endif

class AlarmClockController: UITableViewController {
    fileprivate var selectedIndex: IndexPath?
    fileprivate var isEditingFlag: Bool = false;
    fileprivate var allAlarmArray: [MEDUserAlarm] = []
    fileprivate var oldAlarmArray: [Alarm] = []
    fileprivate var wakeArray: [MEDUserAlarm] = []
    fileprivate var sleepArray: [MEDUserAlarm] = []
    fileprivate var isOldAddAlarmFlag: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.getFirmwareVersion() <= 31 && userDefaults.getSoftwareVersion() <= 18
    }
    
    fileprivate lazy var formatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "HH:mm a"
        return format
    }()
    
    fileprivate lazy var rightBarButton: UIBarButtonItem = {
        let rightItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addAlarmAction(_ :)))
        
        return rightItem
    }()
    
    fileprivate lazy var leftEditItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(alarmEditAction(_:)))
    }()
    
    fileprivate lazy var leftDoneItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(alarmEditAction(_:)))
    }()
    
    var alarmItems = Variable([
        AlarmSectionModel(header:"Wake Alarm",items:[AlarmSectionModelItem(timer: "", title: "", describing: "", state: false)]),
        AlarmSectionModel(header:"Sleep Alarm",items:[AlarmSectionModelItem(timer: "", title: "", describing: "", state: false)])])
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("alarmTitle", comment:"")
        tableView.sectionFooterHeight = 20
        tableView.alwaysBounceVertical = true
        tableView.bounces = true
        tableView.allowsSelectionDuringEditing = true;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        
        tableView.viewDefaultColorful()
        
        initializeAlarmData()
        
        leftBarButtonReaction()
        
        ConnectionManager.manager.startConnect(false)
        
        tableView.register(UINib(nibName: "AlarmClockVCell",bundle:nil), forCellReuseIdentifier: "alarmCell")
        
        let dataSource = RxTableViewSectionedReloadDataSource<AlarmSectionModel>()
        
        dataSource.configureCell = { (_, tv, indexPath, element: AlarmSectionModelItem) in
            let cell = tv.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmClockVCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            if self.isEditingFlag {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }else{
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            cell.alarmItem = element
            
            cell.actionCallBack = {
                (sender) -> Void in
                let segment = sender as! UISwitch
                
                var alarmArray = self.improviseArray(section: indexPath.section)
                
                self.updateNewAlarmData(alarmArray: &alarmArray, mSwitch: segment)
            }
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource[sectionIndex].header
        }
        
        dataSource.canEditRowAtIndexPath = { (ds, ip) in
            return true
        }
        
        dataSource.setSections(alarmItems.value)
        
        alarmItems.asObservable().bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        checkConnection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.subviewsSatisfy(theCondition: { (v) -> (Bool) in
            return v.frame.height == 0.5
        }, do: { (v) in
            v.isHidden = false
        })
        
        navigationItem.leftBarButtonItem = leftEditItem
    }
}

// MARK: - Left bar button
extension AlarmClockController {
    func addAlarmAction(_ leftitem:UIBarButtonItem) {
        tableView.reloadData()
        
        tableView.setEditing(false, animated: true)
        
        var addAlarmController: UIViewController?
        
        if isOldAddAlarmFlag {
            
            addAlarmController = {
                $0.mDelegate = self
                return $0
            }(AddAlarmController(style: .grouped))
        } else {
            
            addAlarmController = {
                $0.mDelegate = self
                return $0
            }(NewAddAlarmController(style: .grouped))
        }
        addAlarmController!.title = NSLocalizedString("add_alarm", comment: "")
        addAlarmController!.hidesBottomBarWhenPushed = true
        navigationController?.show(addAlarmController!, sender: self)
    }
    
    func leftBarButtonReaction() {
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = isEditingFlag ? leftDoneItem : leftEditItem
    }
    
    func alarmEditAction(_ leftitem:UIBarButtonItem) {
        
        isEditingFlag = !isEditingFlag
        leftBarButtonReaction()
        tableView.reloadData()
    }
}

// MARK: - Initialize data
extension AlarmClockController {
    
    func initializeAlarmData() {
        let array = MEDUserAlarm.getAll()
        allAlarmArray.removeAll()
        oldAlarmArray.removeAll()
        for (index,alarmModel) in array.enumerated() {
            let useralarm:MEDUserAlarm = alarmModel as! MEDUserAlarm
            if useralarm.type == 0 {
                let date:Date = Date(timeIntervalSince1970: useralarm.timer)
                let oldAlarm:Alarm = Alarm(index: index, hour: date.hour, minute: date.minute, enable: useralarm.status)
                oldAlarmArray.append(oldAlarm)
            }
            allAlarmArray.append(useralarm)
        }
        
        wakeArray = allAlarmArray.filter({$0.type == 0})
        sleepArray = allAlarmArray.filter({$0.type == 1})
        
        let wakeAlarmItem = getAlarmInfo(wakeArray)
        let sleepAlarmItem = getAlarmInfo(sleepArray)
        
        alarmItems = Variable([
            AlarmSectionModel(header:"Wake Alarm",items:wakeAlarmItem),
            AlarmSectionModel(header:"Sleep Alarm",items:sleepAlarmItem)])
    }
    
    func getAlarmInfo(_ value:[MEDUserAlarm])-> [AlarmSectionModelItem] {
        var alarmWakeItem:[AlarmSectionModelItem] = []
        for alarmValue in value {
            let alarmDate = Date(timeIntervalSince1970: alarmValue.timer)
            
            let timerString:String = formatter.string(from: alarmDate)
            let alarmState:Bool = alarmValue.status
            var describing:String = ""
            var titleString:String = alarmValue.label
            
            if titleString.characters.count == 0 {
                titleString = NSLocalizedString("alarmTitle", comment: "")
            }
            
            let dayArray = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
            
            
            
            if alarmValue.status {
                describing = NSLocalizedString("alarm_disabled", comment: "")
            }else{
                
                if !(alarmValue.alarmWeek == 0) {
                    if Date().weekday != alarmValue.alarmWeek{
                        describing = NSLocalizedString("alarm_on", comment: "") + NSLocalizedString(dayArray[alarmValue.alarmWeek - 1], comment: "")
                    }else{
                        let nowDate = Date.date(year: Date().year, month: Date().month, day: Date().day, hour: alarmDate.hour, minute: alarmDate.minute, second: 0)
                        if nowDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                            describing = NSLocalizedString("alarm_on", comment: "") + NSLocalizedString(dayArray[alarmValue.alarmWeek - 1], comment: "")
                        } else {
                            let nowHour:Int = abs(alarmDate.hour-Date().hour)
                            let nowMinute:Int = abs(alarmDate.minute-Date().minute)
                            describing = NSLocalizedString("alarm_in", comment: "")+"\(nowHour)h \(nowMinute)m"
                        }
                    }
                } else {
                    describing = "Alarm is available"
                }
            }
            
            alarmWakeItem.append(AlarmSectionModelItem(timer: timerString, title: titleString, describing: describing, state: alarmState))
        }
        return alarmWakeItem
    }
}

// MARK: - ButtonManagerCallBack
extension AlarmClockController {

    func updateNewAlarmData(alarmArray: inout [MEDUserAlarm], mSwitch: UISwitch) {
        tableView.reloadData()
        
        let index = mSwitch.tag
        let alarmModel = alarmArray[index]
        
        var alarmCount = 0
        
        for alarm in alarmArray{
            if alarm.status {
                alarmCount += 1
            }
        }

        var maxCount = 0
        if isOldAddAlarmFlag {
            maxCount = 4
        } else {
            maxCount = 8
        }
        
        let isAvailable = alarmCount < maxCount
        
        if(isAvailable) {
            let realm = try! Realm()
            try! realm.write {
                alarmModel.status = mSwitch.isOn ? isAvailable : false
                let alarmWeek = alarmModel.alarmWeek
                alarmModel.alarmWeek = alarmWeek == 0 ? 1 : alarmWeek
            }
            
            let date = Date(timeIntervalSince1970: alarmModel.timer)
            
            let newAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: alarmModel.type == 1 ? (index+7):index, alarmWeekday: mSwitch.isOn ? alarmModel.alarmWeek:0)
            
            if ConnectionManager.manager.isConnected {
                ConnectionManager.manager.setNewAlarm (newAlarm)
                syncAlarmAlertView()
            }else{
                willSyncAlarmAlertView()
            }
        }else{
            let title = NSLocalizedString("alarmTitle", comment: "")
            let actionMsg = NSLocalizedString("Ok", comment: "")
            
            let localizedKey = "nevo_alarms_limit"
            let detailMsg = NSLocalizedString(localizedKey, comment: "")
            
            let actionSheet = MEDAlertController(title: title, message: detailMsg, preferredStyle: .alert)
            actionSheet.view.tintColor = UIColor.baseColor
            
            let action = AlertAction(title: actionMsg, style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })
            
            actionSheet.addAction(action)
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableView DataSource
extension AlarmClockController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let headerLabel = LineLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        let titleArray: [String] = ["Sleep Alarm","Wake Alarm"]
        
        var title: String?
        
        if wakeArray.count > 0 && sleepArray.count > 0 {
            title = titleArray[section]
        }else{
            title = sleepArray.count > 0 ? titleArray[0] : titleArray[1]
        }
        
        headerLabel.text = NSLocalizedString(title!, comment: "")
        headerLabel.textAlignment = .center
        
        headerLabel.viewDefaultColorful()
        headerLabel.backgroundColor = UIColor.white
        
        return headerLabel
    }

}

// MARK: - Tableview Delegate
extension AlarmClockController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? LineLabel {
            headerView.addLineView(position: .top)
            headerView.addLineView(position: .bottom)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let action = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment:""), handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        
        action.backgroundColor = UIColor.baseColor
        
        return [action]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarm = improviseArray(section: indexPath.section)[indexPath.row]
            
            if improviseArray(section: indexPath.section) == wakeArray {
                wakeArray.remove(at: indexPath.row)
                
                if wakeArray.count == 0 {
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            } else {
                sleepArray.remove(at: indexPath.row)
                
                if sleepArray.count == 0 {
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
            
            let status = alarm.status
            if(alarm.remove()){
                var newAlarmArray: [NewAlarm] = []
                
                let allAlarmArray = wakeArray + sleepArray
                
                for (index, value) in allAlarmArray.enumerated() {
                    if(value.status) {
                        let date = Date(timeIntervalSince1970: value.timer)
                        let alarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: index, alarmWeekday: value.alarmWeek)
                        newAlarmArray.append(alarm)
                    }
                }

                if(status) {
                    if ConnectionManager.manager.isConnected {
                        for alarm in newAlarmArray {
                            ConnectionManager.manager.setNewAlarm(alarm)
                        }
                        syncAlarmAlertView()
                    }else{
                        willSyncAlarmAlertView()
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
        
        if(isEditingFlag){
            
            selectedIndex = indexPath
            
            var alarmModel:MEDUserAlarm?
            
            alarmModel = improviseArray(section: indexPath.section)[indexPath.row]
            
            var addAlarmController: UIViewController?
            
            if isOldAddAlarmFlag {
                
                addAlarmController = {
                    $0.timer = alarmModel!.timer
                    $0.name = alarmModel!.label
                    $0.repeatStatus = alarmModel!.status;
                    $0.mDelegate = self
                    return $0
                }(AddAlarmController(style: .grouped))
            } else {
                addAlarmController = {
                    $0.timer = alarmModel!.timer
                    $0.name = alarmModel!.label
                    $0.alarmTypeIndex = alarmModel!.type
                    $0.repeatSelectedIndex = alarmModel!.alarmWeek
                    $0.mDelegate = self
                    return $0
                }(NewAddAlarmController(style: .grouped))
            }
            
            addAlarmController!.title = NSLocalizedString("edit_alarm", comment: "")
            addAlarmController!.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(addAlarmController!, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - About connection, sync, etc
extension AlarmClockController {
    func checkConnection() {
        if !ConnectionManager.manager.isConnected {
            ConnectionManager.manager.connect()
        }
    }
    
    func willSyncAlarmAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }
    
    func syncAlarmAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }
}

// MARK: - AddAlarmDelegate
extension AlarmClockController: AddAlarmDelegate {
    
    func onDidAddAlarmAction(_ timer: TimeInterval, repeatStatus: Bool, name: String) {
        
        if ConnectionManager.manager.isConnected {
            syncAlarmAlertView()
        } else {
            willSyncAlarmAlertView()
        }
        
        isEditingFlag = false
        
        if(selectedIndex != nil){
            let alarmModel = improviseArray(section: selectedIndex!.section)[selectedIndex!.row]
            
            let realm = try! Realm()
            try! realm.write {
                alarmModel.timer = timer
                alarmModel.label = name
                alarmModel.status = true
            }
            
            let date = Date(timeIntervalSince1970: timer)
            let alarm = oldAlarmArray[selectedIndex!.row]
            
            let tempAlarm = Alarm(index:allAlarmArray.count, hour: date.hour, minute: date.minute, enable: alarm.getEnable())
            
            oldAlarmArray.replaceSubrange(selectedIndex!.row..<selectedIndex!.row+1, with: [tempAlarm])
            
            if ConnectionManager.manager.isConnected {
                ConnectionManager.manager.setAlarm(self.oldAlarmArray.filter{$0.getEnable() == true})
            }
            
            selectedIndex = nil
            
            initializeAlarmData()
            tableView.reloadData()
        } else {
            
            let date = Date(timeIntervalSince1970: timer)
            
            let alarmArray = oldAlarmArray.filter { $0.getEnable() == true }
            let alarmState = alarmArray.count <= 3 && repeatStatus
            
            let alarm = Alarm(index: oldAlarmArray.count, hour: date.hour, minute: date.minute, enable: alarmState)
            oldAlarmArray.append(alarm)
            
            let newAlarm = MEDUserAlarm()
            newAlarm.key = "\(timer)"
            newAlarm.timer = timer
            newAlarm.label = "\(name)"
            newAlarm.status = alarmState
            newAlarm.type = 0
            if newAlarm.add() {
                if ConnectionManager.manager.isConnected {
                    let oldAlarm = self.oldAlarmArray.filter{$0.getEnable() == true}
                    ConnectionManager.manager.setAlarm(oldAlarm)
                }
            }else{
                print("Database insert error.")
            }
            
            initializeAlarmData()
            tableView.reloadData()
            
            navigationItem.leftBarButtonItem = leftEditItem
        }
    }
    
    func onDidAddAlarmAction(_ timer: TimeInterval, name: String, repeatNumber: Int, alarmType: Int) {
        isEditingFlag = false
        
        var sleepAlarmCount = 7
        var wakeAlarmCount = 0
        
        let allAlarms = MEDUserAlarm.getAll()
        for alarm in allAlarms {
            let alarmModel =  alarm as! MEDUserAlarm
            if(alarmModel.type == 1 && alarmModel.status) {
                sleepAlarmCount += 1
            }else if (alarmModel.type == 0 && alarmModel.status){
                wakeAlarmCount += 1
            }
        }

        if (selectedIndex != nil) {
            let alarmModel = improviseArray(section: selectedIndex!.section)[selectedIndex!.row]
            
            let switchStatus:Bool = (repeatNumber == 0) ? false : alarmModel.status
            
            let realm = try! Realm()
            
            try! realm.write {
                alarmModel.timer = timer
                alarmModel.label = "\(name)"
                alarmModel.status = switchStatus
                alarmModel.alarmWeek = repeatNumber
                alarmModel.type = alarmType
            }
            
            initializeAlarmData()
            
            tableView.reloadData()
            
            if ConnectionManager.manager.isConnected {
                ConnectionManager.manager.setNewAlarm()
                syncAlarmAlertView()
            }else{
                willSyncAlarmAlertView()
            }
            
            selectedIndex = nil
        } else {
            let isWakeAvailabel = wakeAlarmCount <= 6
            let isSleepAvailabel = sleepAlarmCount <= 13
            
            let switchStatus = (alarmType == 1) ? isWakeAvailabel : isSleepAvailabel
            
            let newAlarm = MEDUserAlarm()
            newAlarm.key = "\(timer)"
            newAlarm.timer = timer
            newAlarm.label = "\(name)"
            newAlarm.status = switchStatus
            newAlarm.alarmWeek = repeatNumber
            newAlarm.type = alarmType
           
            if newAlarm.add() {
                if(switchStatus) {
                    if ConnectionManager.manager.isConnected {
                        ConnectionManager.manager.setNewAlarm()
                        syncAlarmAlertView()
                    }else{
                        willSyncAlarmAlertView()
                    }
                }
            }else{
                print("Database insert error.")
            }
            
            initializeAlarmData()
            tableView.reloadData()
            
            navigationItem.leftBarButtonItem = leftEditItem
        }
    }
}

// MARK: - Private util function
extension AlarmClockController {
    func improviseArray(section: Int) -> [MEDUserAlarm] {
        if wakeArray.count > 0 && sleepArray.count > 0 {
            return section == 0 ? sleepArray : wakeArray
        }
        
        if wakeArray.count > 0 {
            return wakeArray
        }
        
        if sleepArray.count > 0 {
            return sleepArray
        }
        
        return []
    }
}
