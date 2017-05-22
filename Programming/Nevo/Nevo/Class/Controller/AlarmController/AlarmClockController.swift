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

class AlarmClockController: UITableViewController {
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    fileprivate var selectedIndex: IndexPath?
    fileprivate var isEditingFlag: Bool = false;
    
    var allAlarmArray: [MEDUserAlarm] = []
    var oldAlarmArray: [Alarm] = []
    var wakeArray: [MEDUserAlarm] = []
    var sleepArray: [MEDUserAlarm] = []
    
    var isOldAddAlarmFlag: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.getFirmwareVersion() <= 31 && userDefaults.getSoftwareVersion() <= 18
    }
    
    lazy var leftEditItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(alarmEditAction(_:)))
    }()
    
    lazy var leftDoneItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(alarmEditAction(_:)))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("alarmTitle", comment:"")
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        tableView.sectionFooterHeight = 20
        tableView.allowsSelectionDuringEditing = true;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        
        tableView.viewDefaultColorful()
        
        initializeAlarmData()
        
        leftBarButtonReaction()
        
        ConnectionManager.manager.startConnect(false)
        
        tableView.register(UINib(nibName: "AlarmClockVCell",bundle:nil), forCellReuseIdentifier: "alarmCell")
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
    
    func leftBarButtonReaction() {
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
    }
}

// MARK: - ButtonManagerCallBack
extension AlarmClockController {

    @IBAction func controllManager(_ sender:AnyObject){
        tableView.reloadData()
        
        if(sender.isEqual(rightBarButton)){
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
    }

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
    
    override func numberOfSections(in tableView: UITableView) -> Int{
        tableView.backgroundView = nil
        
        if wakeArray.count > 0 && sleepArray.count > 0 {
            return 2
        } else if wakeArray.count > 0 || sleepArray.count > 0 {
            return 1
        } else {
            tableView.backgroundView = NoneAlarmView.factory()
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return improviseArray(section: section).count
    }
    
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmClockVCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if isEditingFlag {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        let alarmModel = improviseArray(section: indexPath.section)[indexPath.row]
        
        cell.alarmSwicth.isOn = alarmModel.status
        cell.alarmSwicth.tag = indexPath.row
        
        let dayArray = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let alarmDate = Date(timeIntervalSince1970: alarmModel.timer)
        
        if !alarmModel.status {
            cell.alarmInLabel.text = NSLocalizedString("alarm_disabled", comment: "")
        }else{
            print("alarmModel.alarmWeek:\(alarmModel.alarmWeek)")
            
            if !(alarmModel.alarmWeek == 0) {
                if Date().weekday != alarmModel.alarmWeek{
                    cell.alarmInLabel.text = NSLocalizedString("alarm_on", comment: "") + NSLocalizedString(dayArray[alarmModel.alarmWeek - 1], comment: "")
                }else{
                    let nowDate = Date.date(year: Date().year, month: Date().month, day: Date().day, hour: alarmDate.hour, minute: alarmDate.minute, second: 0)
                    if nowDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                        cell.alarmInLabel.text = NSLocalizedString("alarm_on", comment: "") + NSLocalizedString(dayArray[alarmModel.alarmWeek - 1], comment: "")
                    } else {
                        let nowHour:Int = abs(alarmDate.hour-Date().hour)
                        let nowMinute:Int = abs(alarmDate.minute-Date().minute)
                        cell.alarmInLabel.text = NSLocalizedString("alarm_in", comment: "")+"\(nowHour)h \(nowMinute)m"
                    }
                }
            } else {
                cell.alarmInLabel.text = "Alarm is available"
            }
        }
        
        cell.dateLabel.text = alarmDate.stringFromFormat("HH:mm a")
        cell.titleLabel.text = alarmModel.label
        
        if alarmModel.label.characters.count == 0 {
            cell.titleLabel.text = NSLocalizedString("alarmTitle", comment: "")
        }
        
        cell.actionCallBack = {
            (sender) -> Void in
            let segment = sender as! UISwitch
            
            var alarmArray = self.improviseArray(section: indexPath.section)
            
            self.updateNewAlarmData(alarmArray: &alarmArray, mSwitch: segment)
        }
        
        return cell
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
