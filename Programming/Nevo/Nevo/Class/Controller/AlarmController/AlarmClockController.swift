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
    var mWakeAlarmArray:NSMutableArray = NSMutableArray()
    var mSleepAlarmArray:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sleep And Wake"
        
        initValue()
        AppDelegate.getAppDelegate().startConnect(false)
        self.editButtonItem.tintColor = UIColor.getBaseColor()
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()

        self.tableView.allowsSelectionDuringEditing = true;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.register(UINib(nibName: "AlarmClockVCell",bundle:nil), forCellReuseIdentifier: "alarmCell")
    }

    func initValue() {
        self.view.backgroundColor = UIColor.white
        
        let array:NSArray = UserAlarm.getAll()
        mWakeAlarmArray.removeAllObjects()
        mSleepAlarmArray.removeAllObjects()
        for alarmModel in array{
            let useralarm:UserAlarm = alarmModel as! UserAlarm
            if useralarm.type == 0 {
                mWakeAlarmArray.add(useralarm)
            }else{
                mSleepAlarmArray.add(useralarm)
            }
        }

        if(UserAlarm.isExistInTable()){
            _ = UserAlarm.updateTable()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        checkConnection()
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

        if(sender.isEqual(rightBarButton)){
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            let addAlarm:NewAddAlarmController = NewAddAlarmController()
            addAlarm.title = NSLocalizedString("add_alarm", comment: "")
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.show(addAlarm, sender: self)
        }

        if(sender.isKind(of: UISwitch.classForCoder())){
            let mSwitch:UISwitch = sender as! UISwitch
            updateNewAlarmSwicthData(mWakeAlarmArray,index: mSwitch.tag,status:mSwitch.isOn)
        }
    }

    func sleepSwitchManager(_ sender:UISwitch) {
        updateNewAlarmSwicthData(mSleepAlarmArray,index: sender.tag,status:sender.isOn)
    }
    
    func updateNewAlarmSwicthData(_ mAlarmArray:NSArray,index:Int,status:Bool) {
        var weakAlarmCount:Int = 0
        var sleepAlarmCount:Int = 0
        var weakOpenNumber:Int = 0
        var sleepOpenNumber:Int = 0
        for alarm in mAlarmArray{
            let alarmModel:UserAlarm =  alarm as! UserAlarm
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

        let alarmModel:UserAlarm =  mAlarmArray[index] as! UserAlarm
        if(isStatus) {
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":status ? isStatus:status,"repeatStatus":false,"dayOfWeek":alarmModel.dayOfWeek,"type":alarmModel.type])
            let res:Bool = addalarm.update()
            let date:Date = Date(timeIntervalSince1970: addalarm.timer)
            let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: addalarm.type == 1 ? (index+7):index, alarmWeekday: status ? addalarm.dayOfWeek:0)
            if(AppDelegate.getAppDelegate().isConnected() && res){
                AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                if newAlarm.getAlarmNumber()<7 {
                    mWakeAlarmArray.replaceObject(at: index, with: addalarm)
                }else{
                    mSleepAlarmArray.replaceObject(at: index, with: addalarm)
                }
                self.SyncAlarmAlertView()
            }else{
                self.willSyncAlarmAlertView()
            }
        }else{
            let titleString:String = NSLocalizedString("alarmTitle", comment: "")
            let msg:String = NSLocalizedString("Nevo supports only 7 alarms for now.", comment: "")
            let buttonString:String = NSLocalizedString("Ok", comment: "")
            let actionSheet:UIAlertController = UIAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.alert)
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
        let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }

    /**
     Syncing alarm
     */
    func SyncAlarmAlertView() {
        let banner = Banner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }

    // MARK: - AddAlarmDelegate
    func onDidAddAlarmAction(_ timer:TimeInterval,repeatStatus:Bool,name:String) {
    
    }
    
    func onDidAddAlarmAction(_ timer:TimeInterval,name:String,repeatNumber:Int,alarmType:Int) {
        var sleepAlarmCount:Int = 7
        var dayAlarmCount:Int = 0
        let alarmArray:NSArray = alarmType==1 ? mSleepAlarmArray:mWakeAlarmArray
        
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
            let alarmModel:UserAlarm =  alarmArray[slectedIndex] as! UserAlarm
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":alarmModel.status,"repeatStatus":false,"dayOfWeek":repeatNumber,"type":alarmType])
            if(addalarm.update()){
                
                (alarmType==0 ? mSleepAlarmArray:mWakeAlarmArray).replaceObject(at: slectedIndex, with: addalarm)
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
                    (alarmType==1 ? self.mSleepAlarmArray:self.mWakeAlarmArray).add(addalarm)
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
        if mWakeAlarmArray.count == 0 && mSleepAlarmArray.count == 0 {
            tableView.backgroundView = NotAlarmView.getNotAlarmView()
            return 0
        }else{
            tableView.backgroundView = nil
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            return mSleepAlarmArray.count
        }else if section == 1 {
            return mWakeAlarmArray.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let headerLabel:LineLabel = LineLabel(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 30))
        let titleArray:[String] = ["Sleep Alarm","Wake Alarm"]
        headerLabel.text = NSLocalizedString(titleArray[section], comment: "")
        headerLabel.textColor = UIColor.black
        headerLabel.textAlignment = NSTextAlignment.center
        if section == 0 {
            headerLabel.backgroundColor = AppTheme.NEVO_SOLAR_GRAY()
        }else{
            headerLabel.backgroundColor = UIColor.white
        }
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let endCell:AlarmClockVCell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmClockVCell
        endCell.selectionStyle = UITableViewCellSelectionStyle.none

        var alarmModel:UserAlarm?
        if (indexPath as NSIndexPath).section == 0 {
            alarmModel = mSleepAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
            endCell.contentView.backgroundColor = AppTheme.NEVO_SOLAR_GRAY()
        }else{
            alarmModel = mWakeAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
            endCell.contentView.backgroundColor = UIColor.white
        }
        
        let dayArray:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let date:Date = Date(timeIntervalSince1970: alarmModel!.timer)
        if alarmModel?.dayOfWeek == 0 {
            endCell.alarmIn.text = "Alarm close"
        }else{
            if alarmModel!.dayOfWeek != Date().weekday {
                endCell.alarmIn.text = "Alarm on \(dayArray[alarmModel!.dayOfWeek-1]) "
            }else{
                if date.hour>=Date().hour && date.minute>Date().minute {
                    let nowHour:Int = abs(date.hour-Date().hour)
                    let noeMinte:Int = abs(date.minute-Date().minute)
                    endCell.alarmIn.text = "Alarm in \(nowHour)h \(noeMinte)m"
                }else{
                    endCell.alarmIn.text = "Alarm close"
                }
            }
        }
        endCell.dateLabel.text = stringFromDate(date)
        endCell.titleLabel.text = alarmModel!.label
        endCell.alarmSwicth.tag = (indexPath as NSIndexPath).row
        endCell.alarmSwicth.isOn = alarmModel!.status
        if (indexPath as NSIndexPath).section == 0 {
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
        let button1 = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        button1.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
        return [button1]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            var willAlarm:UserAlarm?
            if (indexPath as NSIndexPath).section == 0 {
                willAlarm = mSleepAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
            }else{
                willAlarm = mWakeAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
            }

            if(willAlarm!.remove()){
                if (indexPath as NSIndexPath).section == 0 {
                    mSleepAlarmArray.removeObject(at: (indexPath as NSIndexPath).row)
                }else{
                    mWakeAlarmArray.removeObject(at: (indexPath as NSIndexPath).row)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                var alarmArray:[NewAlarm] = []
                let array:NSArray = (indexPath as NSIndexPath).section==1 ? mWakeAlarmArray:mSleepAlarmArray
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
            if (indexPath as NSIndexPath).section == 0 {
                alarmModel = mSleepAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
            }else{
                alarmModel = mWakeAlarmArray[(indexPath as NSIndexPath).row] as? UserAlarm
            }

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
