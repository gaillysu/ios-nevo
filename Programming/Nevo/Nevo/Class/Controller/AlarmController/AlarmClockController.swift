//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner

class AlarmClockController: UITableViewController,AddAlarmDelegate {
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    fileprivate var slectedIndex:Int = -1 //To edit a record the number of rows selected content
    var mAlarmArray:[UserAlarm] = []
    var oldAlarmArray:[Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("sleep_and_wake", comment:"")
        
        initValue()
        AppDelegate.getAppDelegate().startConnect(false)

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.tableView.sectionFooterHeight = 20
        self.tableView.allowsSelectionDuringEditing = true;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.tableView.register(UINib(nibName: "AlarmClockVCell",bundle:nil), forCellReuseIdentifier: "alarmCell")
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tableView.backgroundColor = UIColor.getLightBaseColor()
        }
    }

    func initValue() {
        let array:NSArray = UserAlarm.getAll()
        mAlarmArray.removeAll()
        oldAlarmArray.removeAll()
        for (index,alarmModel) in array.enumerated() {
            let useralarm:UserAlarm = alarmModel as! UserAlarm
            if useralarm.type == 0 {
                let date:Date = Date(timeIntervalSince1970: useralarm.timer)
                let oldAlarm:Alarm = Alarm(index: index, hour: date.hour, minute: date.minute, enable: useralarm.status)
                oldAlarmArray.append(oldAlarm)
            }
            mAlarmArray.append(useralarm)
        }

        if(UserAlarm.isExistInTable()){
            _ = UserAlarm.updateTable()
        }
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ButtonManagerCallBack
    /*
    call back Button Action
    */
    @IBAction func controllManager(_ sender:AnyObject){
        self.tableView.reloadData()
        if(sender.isEqual(rightBarButton)){
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            if AppDelegate.getAppDelegate().getMconnectionController()!.getFirmwareVersion().integerValue <= 31 && AppDelegate.getAppDelegate().getMconnectionController()!.getSoftwareVersion().integerValue <= 18 {
                let addAlarm:AddAlarmController = AddAlarmController()
                addAlarm.title = NSLocalizedString("add_alarm", comment: "")
                addAlarm.mDelegate = self
                addAlarm.hidesBottomBarWhenPushed = true
                self.navigationController?.show(addAlarm, sender: self)
            }else{
                let addAlarm:NewAddAlarmController = NewAddAlarmController()
                addAlarm.title = NSLocalizedString("add_alarm", comment: "")
                addAlarm.mDelegate = self
                addAlarm.hidesBottomBarWhenPushed = true
                self.navigationController?.show(addAlarm, sender: self)
            }
            
        }

        if(sender.isKind(of: UISwitch.classForCoder())){
            let mSwitch:UISwitch = sender as! UISwitch
            updateNewAlarmSwicthData(mAlarmArray,index: mSwitch.tag,status:mSwitch.isOn)
        }
    }

    func sleepSwitchManager(_ sender:UISwitch) {
        updateNewAlarmSwicthData(mAlarmArray,index: sender.tag,status:sender.isOn)
        self.tableView.reloadData()
    }
    
    func updateNewAlarmSwicthData(_ alarmArray:[UserAlarm],index:Int,status:Bool) {
        var weakAlarmCount:Int = 0
        var sleepAlarmCount:Int = 0
        var weakOpenNumber:Int = 0
        var sleepOpenNumber:Int = 0
        for alarm in mAlarmArray{
            let alarmModel:UserAlarm =  alarm
            if (alarmModel.type == 0){
                if alarmModel.status {
                    weakOpenNumber += 1
                }
                weakAlarmCount += 1
            }else{
                if alarmModel.status {
                    sleepOpenNumber += 1
                }
                sleepAlarmCount += 1
            }
        }

        var isStatus:Bool = false
        if(weakOpenNumber < 7 && sleepOpenNumber<7){
            isStatus = true
        }

        let alarmModel:UserAlarm =  mAlarmArray[index]
        if(isStatus) {
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":status ? isStatus:status,"repeatStatus":false,"dayOfWeek":alarmModel.dayOfWeek,"type":alarmModel.type])
            let res:Bool = addalarm.update()
            let date:Date = Date(timeIntervalSince1970: addalarm.timer)
            let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: addalarm.type == 1 ? (index+7):index, alarmWeekday: status ? addalarm.dayOfWeek:0)
            if(AppDelegate.getAppDelegate().isConnected() && res){
                AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                mAlarmArray.replaceSubrange(index..<index+1, with: [addalarm])
                self.SyncAlarmAlertView()
            }else{
                self.willSyncAlarmAlertView()
            }
        }else{
            let titleString:String = NSLocalizedString("alarmTitle", comment: "")
            let msg:String = NSLocalizedString("Nevo supports only 7 alarms for now.", comment: "")
            let buttonString:String = NSLocalizedString("Ok", comment: "")
            let actionSheet:ActionSheetView = ActionSheetView(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.alert)
            actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            let alertAction:UIAlertAction = UIAlertAction(title: buttonString, style: UIAlertActionStyle.default, handler: { ( alert) -> Void in
                
            })
            actionSheet.addAction(alertAction)
            
            self.present(actionSheet, animated: true, completion: nil)
        }

    }


    /**
     Will sync when nevo is connected
     */
    func willSyncAlarmAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }

    /**
     Syncing alarm
     */
    func SyncAlarmAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }

    // MARK: - AddAlarmDelegate
    func onDidAddAlarmAction(_ timer:TimeInterval,repeatStatus:Bool,name:String) {
        if(AppDelegate.getAppDelegate().isConnected()) {
            let banner = Banner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }else{
            let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
        
        if(slectedIndex >= 0){
            let alarmModel:UserAlarm =  mAlarmArray[slectedIndex]
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":true,"repeatStatus":repeatStatus])
            if(addalarm.update()){
                mAlarmArray.replaceSubrange(slectedIndex..<slectedIndex+1, with: [addalarm])
                self.isEditing = false
                self.tableView.setEditing(false, animated: true)
                self.tableView.reloadData()
                
                let date:Date = Date(timeIntervalSince1970: timer)
                let alarm:Alarm = oldAlarmArray[slectedIndex]
                let reAlarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: alarm.getEnable())
                oldAlarmArray.replaceSubrange(slectedIndex..<slectedIndex+1, with: [reAlarm])
                if(AppDelegate.getAppDelegate().isConnected()){
                    AppDelegate.getAppDelegate().setAlarm(oldAlarmArray.filter{$0.getEnable() == true})
                }
                slectedIndex = -1
            }
        }else{
            let date:Date = Date(timeIntervalSince1970: timer)
            
            let alarmArray = oldAlarmArray.filter{$0.getEnable() == true}
            let alarmState:Bool = alarmArray.count>3 ? false:true
            
            let alarm:Alarm = Alarm(index:self.oldAlarmArray.count, hour: date.hour, minute: date.minute, enable: alarmState)
            oldAlarmArray.append(alarm)
            
            let addalarm:UserAlarm = UserAlarm()
            addalarm.id = 0
            addalarm.timer = timer
            addalarm.label = "\(name)"
            addalarm.status = alarmState
            addalarm.repeatStatus = repeatStatus
            addalarm.add({ (id, completion) -> Void in
                if(completion!){
                    addalarm.id = id!
                    if(AppDelegate.getAppDelegate().isConnected()){
                        let kk = self.oldAlarmArray.filter{$0.getEnable() == true}
                        AppDelegate.getAppDelegate().setAlarm(kk)
                    }
                }else{
                    let aler:UIAlertView = UIAlertView(title: "Tip", message: "Database insert fail", delegate: nil, cancelButtonTitle: "ok")
                    aler.show()
                }
            })
            self.mAlarmArray.append(addalarm)
            self.tableView.reloadData()
        }
    }
    
    func onDidAddAlarmAction(_ timer:TimeInterval,name:String,repeatNumber:Int,alarmType:Int) {
        var sleepAlarmCount:Int = 7
        var dayAlarmCount:Int = 0
        let array:NSArray = UserAlarm.getAll()
        for alarm in array{
            let alarmModel:UserAlarm =  alarm as! UserAlarm
            if(alarmModel.type == 1 && alarmModel.status) {
                sleepAlarmCount += 1
            }else if (alarmModel.type == 0 && alarmModel.status){
                dayAlarmCount += 1
            }
        }
        
        if(slectedIndex >= 0){
            let alarmModel:UserAlarm =  mAlarmArray[slectedIndex]
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":alarmModel.status,"repeatStatus":false,"dayOfWeek":repeatNumber,"type":alarmType])
            if(addalarm.update()){
                mAlarmArray.replaceSubrange(slectedIndex..<slectedIndex+1, with: [addalarm])
                self.isEditing = false
                self.tableView.setEditing(false, animated: true)
                self.tableView.reloadData()

                let date:Date = Date(timeIntervalSince1970: timer)
                let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: alarmType == 1 ? sleepAlarmCount:dayAlarmCount, alarmWeekday: repeatNumber)
                if(AppDelegate.getAppDelegate().isConnected()){
                    AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                    SyncAlarmAlertView()
                }else{
                    willSyncAlarmAlertView()
                }
                slectedIndex = -1
            }
        }else{
            var isDayStatus:Bool = false
            var isSleepStatus:Bool = false
            if(dayAlarmCount<=6){
                isDayStatus = true
            }

            if(sleepAlarmCount<=13) {
                isSleepStatus = true
            }

            let switchStatus:Bool = (alarmType == 1) ? isSleepStatus:isDayStatus
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":0,"timer":timer,"label":"\(name)","status":switchStatus ,"repeatStatus":false,"dayOfWeek":repeatNumber,"type":alarmType])
            addalarm.add({ (id, completion) -> Void in
                if(completion!){
                    addalarm.id = id!
                    self.mAlarmArray.append(addalarm)
                    self.tableView.reloadData()

                    let date:Date = Date(timeIntervalSince1970: timer)
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: (alarmType == 1) ? sleepAlarmCount:dayAlarmCount, alarmWeekday: repeatNumber)

                    if(switchStatus) {
                        if(AppDelegate.getAppDelegate().isConnected()){
                            AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                            self.SyncAlarmAlertView()
                        }else{
                            self.willSyncAlarmAlertView()
                        }
                    }
                }else{
                    let aler:UIAlertView = UIAlertView(title: "Tip", message: "Database insert fail", delegate: nil, cancelButtonTitle: "ok")
                    aler.show()
                }
            })
        }
    }

    func stringFromDate(_ date:Date) -> String {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "HH:mm a"
        let dateString:String = dateFormatter.string(from: date)
        return dateString
    }

    /**
    Checks if any device is currently connected
    */
    func checkConnection() {

        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
            reconnect()
        }
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }


    // MARK: - UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int{
        tableView.backgroundView = nil
        if mAlarmArray.count > 1 {
            return 2
        } else {
            if hasSleepAlarmArray {
                return 1
            } else {
                tableView.backgroundView = NotAlarmView.getNotAlarmView()
                return 0
            }
        }
    }

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
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if hasWakeAlarmArray && hasSleepAlarmArray {
            if section == 0 {
                return mSleepAlarmArray.count
            }else if section == 1 {
                return mWakeAlarmArray.count
            }
        } else {
            if hasSleepAlarmArray {
                return mSleepAlarmArray.count
            } else if hasWakeAlarmArray {
                return mWakeAlarmArray.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let headerLabel:LineLabel = LineLabel(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 30))
        let titleArray:[String] = ["Sleep Alarm","Wake Alarm"]
        
        if hasWakeAlarmArray && hasSleepAlarmArray {
            headerLabel.text = NSLocalizedString(titleArray[section], comment: "")
        } else {
            if hasSleepAlarmArray {
                headerLabel.text = NSLocalizedString(titleArray[0], comment: "")
            } else if hasWakeAlarmArray {
                headerLabel.text = NSLocalizedString(titleArray[1], comment: "")
            } else {
                return UIView()
            }
        }
        
        headerLabel.textColor = UIColor.black
        headerLabel.textAlignment = NSTextAlignment.center
        headerLabel.backgroundColor = UIColor.white
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            headerLabel.backgroundColor = UIColor.getGreyColor()
            headerLabel.textColor = UIColor.white
        }
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let endCell:AlarmClockVCell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmClockVCell
        endCell.selectionStyle = UITableViewCellSelectionStyle.none

        var alarmModel:UserAlarm?
        
        if hasWakeAlarmArray && hasSleepAlarmArray {
            if (indexPath as NSIndexPath).section == 0 {
                alarmModel = mSleepAlarmArray[indexPath.row]
            }else{
                alarmModel = mWakeAlarmArray[indexPath.row]
            }
        } else {
            if hasSleepAlarmArray {
                alarmModel = mSleepAlarmArray[indexPath.row]
            } else if hasWakeAlarmArray {
                alarmModel = mWakeAlarmArray[indexPath.row]
            }
        }
        
        endCell.contentView.backgroundColor = UIColor.white
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            endCell.backgroundColor = UIColor.getGreyColor()
            endCell.contentView.backgroundColor = UIColor.getGreyColor()
            endCell.dateLabel.textColor = UIColor.white
            endCell.titleLabel.textColor = UIColor.white
            endCell.alarmIn.textColor = UIColor.white
            endCell.alarmSwicth.onTintColor = UIColor.getBaseColor()
        }
        
        let dayArray:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let date:Date = Date(timeIntervalSince1970: alarmModel!.timer)
        
        if alarmModel!.dayOfWeek != Date().weekday {
            if alarmModel?.dayOfWeek == 0 {
                alarmModel?.dayOfWeek = 2
            }
            endCell.alarmIn.text = NSLocalizedString("alarm_on", comment: "")+NSLocalizedString(dayArray[alarmModel!.dayOfWeek-1], comment: "")
        }else{
            let nowHour:Int = abs(date.hour-Date().hour)
            let noeMinte:Int = abs(date.minute-Date().minute)
            endCell.alarmIn.text = NSLocalizedString("alarm_in", comment: "")+"\(nowHour)h \(noeMinte)m"
        }
        
        endCell.dateLabel.text = stringFromDate(date)
        endCell.titleLabel.text = alarmModel!.label
        if alarmModel?.label.characters.count == 0 {
            endCell.titleLabel.text = NSLocalizedString("alarmTitle", comment: "")
        }
        
        endCell.alarmSwicth.tag = (indexPath as NSIndexPath).row
        endCell.alarmSwicth.isOn = alarmModel!.status
        
        if !endCell.alarmSwicth.isOn {
            endCell.alarmIn.text = NSLocalizedString("alarm_disabled", comment: "")
        }
        
        
        if alarmModel!.type == 1 {
            endCell.alarmSwicth.addTarget(self, action: #selector(sleepSwitchManager(_:)), for: UIControlEvents.valueChanged)
        }else{
            endCell.alarmSwicth.addTarget(self, action: #selector(controllManager(_:)), for: UIControlEvents.valueChanged)
        }
        
        return endCell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment:""), handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        
        // MARK: - APPTHEME ADJUST
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            button1.backgroundColor = UIColor.getBaseColor()
        } else {
            button1.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        return [button1]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            var willAlarm:UserAlarm?
            
            if hasWakeAlarmArray && hasSleepAlarmArray {
                if (indexPath as NSIndexPath).section == 0 {
                    willAlarm = mSleepAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                }else{
                    willAlarm = mWakeAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                }
            } else {
                if hasSleepAlarmArray {
                    willAlarm = mSleepAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                } else if hasWakeAlarmArray {
                    willAlarm = mWakeAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                } else {
                }
            }
            
            var mSleepAlarmIsGoingNone:Bool = false
            var mWakeAlarmIsGoingNone:Bool = false

            if(willAlarm!.remove()){
                if hasWakeAlarmArray && hasSleepAlarmArray {
                    if (indexPath as NSIndexPath).section == 0 {
                        if mSleepAlarmArray.count == 1 {
                            mSleepAlarmIsGoingNone = true
                        }
                        mSleepAlarmArray.removeObject(at: (indexPath as NSIndexPath).row)
                    }else{
                        if mWakeAlarmArray.count == 1 {
                            mWakeAlarmIsGoingNone = true
                        }
                        mWakeAlarmArray.removeObject(at: (indexPath as NSIndexPath).row)
                    }
                } else {
                    if hasSleepAlarmArray {
                        if mSleepAlarmArray.count == 1 {
                            mSleepAlarmIsGoingNone = true
                        }
                        mSleepAlarmArray.removeObject(at: (indexPath as NSIndexPath).row)
                    } else if hasWakeAlarmArray {
                        if mWakeAlarmArray.count == 1 {
                            mWakeAlarmIsGoingNone = true
                        }
                        mWakeAlarmArray.removeObject(at: (indexPath as NSIndexPath).row)
                    } else {
                    }
                }
                
                // 如果删除某一个闹钟后, 如果需要删除 tableview 中 section, 就需要执行 deleteSections 方法
                // if you delete the last one of one section, you need use "deleteSections" instead of "deleteRows"
                if mWakeAlarmIsGoingNone || mSleepAlarmIsGoingNone {
                    tableView.deleteSections(IndexSet(indexPath.section..<indexPath.section + 1), with: .fade)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
                var alarmArray:[NewAlarm] = []
                
                var array:NSArray = []
                
                if hasWakeAlarmArray && hasSleepAlarmArray {
                    array = (indexPath as NSIndexPath).section==1 ? mWakeAlarmArray:mSleepAlarmArray
                } else {
                    if hasSleepAlarmArray {
                        array = mSleepAlarmArray
                    } else if hasWakeAlarmArray {
                        array = mWakeAlarmArray
                    } else {
                    }
                }
                
                for (index, value) in array.enumerated() {
                    if((value as! UserAlarm).status) {
                        let date:Date = Date(timeIntervalSince1970: (value as! UserAlarm).timer)
                        let alarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: index, alarmWeekday: (value as! UserAlarm).dayOfWeek)
                        alarmArray.append(alarm)
                    }
                }

                //Only delete state switch on will be synchronized to watch
                if(willAlarm!.status) {
                    if(AppDelegate.getAppDelegate().isConnected()){
                        for alarm in alarmArray {
                            let newAlarm:NewAlarm = alarm
                            AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                        }
                        self.SyncAlarmAlertView()
                    }else{
                        self.willSyncAlarmAlertView()
                    }
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if(self.isEditing){
            slectedIndex = (indexPath as NSIndexPath).row
            var alarmModel:UserAlarm?
            
            if hasWakeAlarmArray && hasSleepAlarmArray {
                if (indexPath as NSIndexPath).section == 0 {
                    alarmModel = mSleepAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                }else{
                    alarmModel = mWakeAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                }
            } else {
                if hasSleepAlarmArray {
                    alarmModel = mSleepAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                } else if hasWakeAlarmArray {
                    alarmModel = mWakeAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
                } else {
                }
            }
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)

            let addAlarm:NewAddAlarmController = NewAddAlarmController()
            addAlarm.title = NSLocalizedString("edit_alarm", comment: "")
            addAlarm.timer = alarmModel!.timer
            addAlarm.name = alarmModel!.label
            addAlarm.alarmTypeIndex = alarmModel!.type
            addAlarm.repeatSelectedIndex = alarmModel!.dayOfWeek
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addAlarm, animated: true)
        }

    }
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}
