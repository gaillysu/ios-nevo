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
import Timepiece

class AlarmClockController: UITableViewController,AddAlarmDelegate {
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    fileprivate var selectedIndex: IndexPath?
    fileprivate var isEditingFlag: Bool = false;
    
    var allAlarmArray: [MEDUserAlarm] = []
    var oldAlarmArray: [Alarm] = []
    var wakeArray: [MEDUserAlarm] = []
    var sleepArray: [MEDUserAlarm] = []
    
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
        
        AppDelegate.getAppDelegate().startConnect(false)
        
        tableView.register(UINib(nibName: "AlarmClockVCell",bundle:nil), forCellReuseIdentifier: "alarmCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        checkConnection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.allSubviews(do: { (v) in
            v.isHidden = v.frame.height == 0.5
        })
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
            
            if AppDelegate.getAppDelegate().getMconnectionController()!.getFirmwareVersion() <= 31 && AppDelegate.getAppDelegate().getMconnectionController()!.getSoftwareVersion() <= 18 {
                
                addAlarmController = {
                    $0.mDelegate = self
                    return $0
                }(AddAlarmController())
            }else{
                
                addAlarmController = {
                    $0.mDelegate = self
                    return $0
                }(NewAddAlarmController())
            }
            
            addAlarmController!.title = NSLocalizedString("add_alarm", comment: "")
            addAlarmController!.hidesBottomBarWhenPushed = true
            navigationController?.show(addAlarmController!, sender: self)
        }

        if(sender.isKind(of: UISwitch.classForCoder())){
            let mSwitch: UISwitch = sender as! UISwitch
            updateNewAlarmData(alarmArray: &wakeArray, mSwitch: mSwitch)
        }
    }
    
    func sleepSwitchManager(_ sender:UISwitch) {
        updateNewAlarmData(alarmArray: &sleepArray,mSwitch:sender)
    }

    func updateNewAlarmData(alarmArray: inout [MEDUserAlarm], mSwitch: UISwitch) {
        let index = mSwitch.tag
        let alarmModel = alarmArray[index]
        
        var alarmCount = 0
        
        for alarm in alarmArray{
            if alarm.status {
                alarmCount += 1
            }
        }

        var maxCount = 0
        if !AppTheme.isTargetLunaR_OR_Nevo() {
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
            
            if(AppDelegate.getAppDelegate().isConnected()){
                AppDelegate.getAppDelegate().setNewAlarm (newAlarm)
                syncAlarmAlertView()
            }else{
                willSyncAlarmAlertView()
            }
        }else{
            let title = NSLocalizedString("alarmTitle", comment: "")
            let actionMsg = NSLocalizedString("Ok", comment: "")
            
            let localizedKey = AppTheme.isTargetLunaR_OR_Nevo() ? "nevo_alarms_limit" : "lunar_alarms_limit"
            let detailMsg = NSLocalizedString(localizedKey, comment: "")
            
            let actionSheet = MEDAlertController(title: title, message: detailMsg, preferredStyle: .alert)
            actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            
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
        headerLabel.backgroundColor = UIColor.getGreyColor()
        
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
            if Date().weekday != alarmModel.alarmWeek{
                cell.alarmInLabel.text = NSLocalizedString("alarm_on", comment: "") + NSLocalizedString(dayArray[alarmModel.alarmWeek], comment: "")
            }else{
                let nowDate = Date.date(year: Date().year, month: Date().month, day: Date().day, hour: alarmDate.hour, minute: alarmDate.minute, second: 0)
                if nowDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                    cell.alarmInLabel.text = NSLocalizedString("alarm_on", comment: "") + NSLocalizedString(dayArray[alarmModel.alarmWeek], comment: "")
                } else {
                    let nowHour:Int = abs(alarmDate.hour-Date().hour)
                    let nowMinute:Int = abs(alarmDate.minute-Date().minute)
                    cell.alarmInLabel.text = NSLocalizedString("alarm_in", comment: "")+"\(nowHour)h \(nowMinute)m"
                }
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
        
        action.backgroundColor = UIColor.getBaseColor()
        
        return [action]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarm = improviseArray(section: indexPath.section)[indexPath.row]
            
            if improviseArray(section: indexPath.section) == wakeArray {
                wakeArray.remove(at: indexPath.row)
            } else {
                sleepArray.remove(at: indexPath.row)
            }

            let status = alarm.status
            if(alarm.remove()){
                // 如果删除某一个闹钟后, 如果需要删除 tableview 中 section, 就需要执行 deleteSections 方法
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
                    if(AppDelegate.getAppDelegate().isConnected()){
                        for alarm in newAlarmArray {
                            AppDelegate.getAppDelegate().setNewAlarm(alarm)
                        }
                        syncAlarmAlertView()
                    }else{
                        willSyncAlarmAlertView()
                    }
                }
                
                tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if(isEditingFlag){
            
            selectedIndex = indexPath
            
            var alarmModel:MEDUserAlarm?
            
            alarmModel = improviseArray(section: indexPath.section)[indexPath.row]
            
            var addAlarmController: UIViewController?
            
            if AppDelegate.getAppDelegate().getMconnectionController()!.getFirmwareVersion() <= 31 && AppDelegate.getAppDelegate().getMconnectionController()!.getSoftwareVersion() <= 18 {
                
                addAlarmController = {
                    $0.timer = alarmModel!.timer
                    $0.name = alarmModel!.label
                    $0.repeatStatus = alarmModel!.status;
                    $0.mDelegate = self
                    return $0
                }(AddAlarmController())
            } else {
                addAlarmController = {
                    $0.timer = alarmModel!.timer
                    $0.name = alarmModel!.label
                    $0.alarmTypeIndex = alarmModel!.type
                    $0.repeatSelectedIndex = alarmModel!.alarmWeek
                    $0.mDelegate = self
                    return $0
                }(NewAddAlarmController())
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
        if !AppDelegate.getAppDelegate().isConnected() {
            AppDelegate.getAppDelegate().connect()
        }
    }
    
    func willSyncAlarmAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }
    
    func syncAlarmAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }
}

// MARK: - AddAlarmDelegate
extension AlarmClockController {
    
    func onDidAddAlarmAction(_ timer: TimeInterval, repeatStatus: Bool, name: String) {
        
        if(AppDelegate.getAppDelegate().isConnected()) {
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
            
            initializeAlarmData()
            tableView.reloadData()
            
            let date = Date(timeIntervalSince1970: timer)
            let alarm = oldAlarmArray[selectedIndex!.row]
            
            let tempAlarm = Alarm(index:allAlarmArray.count, hour: date.hour, minute: date.minute, enable: alarm.getEnable())
            
            oldAlarmArray.replaceSubrange(selectedIndex!.row..<selectedIndex!.row+1, with: [tempAlarm])
            
            if(AppDelegate.getAppDelegate().isConnected()){
                AppDelegate.getAppDelegate().setAlarm(oldAlarmArray.filter{$0.getEnable() == true})
            }
            
            selectedIndex = nil
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
                if(AppDelegate.getAppDelegate().isConnected()){
                    let oldAlarm = self.oldAlarmArray.filter{$0.getEnable() == true}
                    AppDelegate.getAppDelegate().setAlarm(oldAlarm)
                }
            }else{
                print("Database insert error.")
            }
            
            initializeAlarmData()
            tableView.reloadData()
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
            
            if(AppDelegate.getAppDelegate().isConnected()){
                AppDelegate.getAppDelegate().setNewAlarm()
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
                    if(AppDelegate.getAppDelegate().isConnected()){
                        AppDelegate.getAppDelegate().setNewAlarm()
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
