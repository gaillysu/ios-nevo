//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import Timepiece

class AlarmClockController: UITableViewController, SyncControllerDelegate,AddAlarmDelegate {
    @IBOutlet var alarmView: alarmClockView!

    private var slectedIndex:Int = -1 //To edit a record the number of rows selected content
    var mAlarmArray:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initValue()

        alarmView.bulidAlarmView()
        
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        self.editButtonItem().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let rightAddButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(controllManager(_:)))
        rightAddButton.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.rightBarButtonItem = rightAddButton

        self.tableView.allowsSelectionDuringEditing = true;

    }

    func initValue() {
        let array:NSArray = UserAlarm.getAll()
        for alarmModel in array{
            let useralarm:UserAlarm = alarmModel as! UserAlarm
            mAlarmArray.addObject(useralarm)
        }

        if(UserAlarm.isExistInTable()){
            UserAlarm.updateTable()
        }
    }

    override func viewDidAppear(animated: Bool) {
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
    func controllManager(sender:AnyObject){

        if(sender.isKindOfClass(UIBarButtonItem.classForCoder())){
            if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue <= 18) {
                let addAlarm:AddAlarmController = AddAlarmController()
                addAlarm.title = NSLocalizedString("add_alarm", comment: "")
                addAlarm.mDelegate = self
                addAlarm.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(addAlarm, animated: true)
            }else{
                let addAlarm:NewAddAlarmController = NewAddAlarmController()
                addAlarm.title = NSLocalizedString("add_alarm", comment: "")
                addAlarm.mDelegate = self
                addAlarm.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(addAlarm, animated: true)
            }

            self.editing = false
            self.tableView.setEditing(false, animated: true)

        }

        if(sender.isKindOfClass(UISwitch.classForCoder())){
            let mSwitch:UISwitch = sender as! UISwitch

            if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue <= 18) {
                //Sleep alarm set
                var alarmCount:Int = 0
                for (index, value) in mAlarmArray.enumerate() {
                    let alarm:UserAlarm = value as! UserAlarm
                    if(alarm.status){
                        alarmCount += 1
                    }
                }

                if(alarmCount == 3) {
                    if(mSwitch.on){
                        mSwitch.setOn(false, animated: true)
                        let titleString:String = NSLocalizedString("alarmTitle", comment: "")
                        let msg:String = NSLocalizedString("nevo_alarms_supports", comment: "")
                        let buttonString:String = NSLocalizedString("Ok", comment: "")

                        if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){

                            let actionSheet:UIAlertController = UIAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                            actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                            let alertAction:UIAlertAction = UIAlertAction(title: buttonString, style: UIAlertActionStyle.Default, handler: { ( alert) -> Void in

                            })
                            actionSheet.addAction(alertAction)

                            self.presentViewController(actionSheet, animated: true, completion: nil)
                        }else{
                            let actionSheet:UIAlertView = UIAlertView(title: titleString, message: msg, delegate: nil, cancelButtonTitle: buttonString)
                            actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
                            actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                            actionSheet.show()
                        }
                    }else{
                        saveSwicthData(mSwitch)
                    }
                }else{
                    saveSwicthData(mSwitch)
                }
            }else{
                saveNewAlarmSwicthData(mSwitch)
            }
        }
    }


    func saveNewAlarmSwicthData(mSwitch:UISwitch) {
        var sleepAlarmCount:Int = 0
        var dayAlarmCount:Int = 0
        for alarm in mAlarmArray{
            let alarmModel:UserAlarm =  alarm as! UserAlarm
            if(alarmModel.type == 1 && alarmModel.status) {
                sleepAlarmCount += 1
            }else if (alarmModel.type == 0 && alarmModel.status){
                dayAlarmCount += 1
            }
        }

        var isDayStatus:Bool = false
        var isSleepStatus:Bool = false
        if(dayAlarmCount < 7){
            isDayStatus = true
        }

        if(sleepAlarmCount < 14) {
            isSleepStatus = true
        }

        let alarmModel:UserAlarm =  mAlarmArray[mSwitch.tag] as! UserAlarm
        let switchStatus:Bool = Bool(alarmModel.type) ? isSleepStatus:isDayStatus
        if(switchStatus || !mSwitch.on) {
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":mSwitch.on,"repeatStatus":false,"dayOfWeek":alarmModel.dayOfWeek,"type":alarmModel.type])
            let res:Bool = addalarm.update()
            let date:NSDate = NSDate(timeIntervalSince1970: addalarm.timer)
            let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: Bool(addalarm.type) ? sleepAlarmCount:dayAlarmCount, alarmWeekday: addalarm.dayOfWeek)
            if(AppDelegate.getAppDelegate().isConnected() && res){
                AppDelegate.getAppDelegate().setNewAlarm(newAlarm)
                self.SyncAlarmAlertView()
            }else{
                self.willSyncAlarmAlertView()
            }
        }else{
            mSwitch.setOn(false, animated: true)
            let titleString:String = NSLocalizedString("alarmTitle", comment: "")
            let msg:String = NSLocalizedString("Nevo supports only 7 alarms for now.", comment: "")
            let buttonString:String = NSLocalizedString("Ok", comment: "")

            if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){

                let actionSheet:UIAlertController = UIAlertController(title: titleString, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                let alertAction:UIAlertAction = UIAlertAction(title: buttonString, style: UIAlertActionStyle.Default, handler: { ( alert) -> Void in

                })
                actionSheet.addAction(alertAction)

                self.presentViewController(actionSheet, animated: true, completion: nil)
            }else{
                let actionSheet:UIAlertView = UIAlertView(title: titleString, message: msg, delegate: nil, cancelButtonTitle: buttonString)
                actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
                actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                actionSheet.show()
            }
        }

    }

    func saveSwicthData(mSwitch:UISwitch) {
        let alarmA:UserAlarm = mAlarmArray[mSwitch.tag] as! UserAlarm
        let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmA.id,"timer":alarmA.timer,"label":"\(alarmA.label)","status":mSwitch.on,"repeatStatus":alarmA.repeatStatus,"dayOfWeek":alarmA.dayOfWeek,"type":alarmA.type])
        addalarm.update()

        mAlarmArray.replaceObjectAtIndex(mSwitch.tag, withObject: addalarm)
        self.tableView.reloadData()

        var alarmArray:[Alarm] = []

        for (index, value) in mAlarmArray.enumerate() {
            if((value as! UserAlarm).status) {
                let date:NSDate = NSDate(timeIntervalSince1970: addalarm.timer)
                let alarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: mSwitch.on)
                alarmArray.append(alarm)
            }
        }

        if(AppDelegate.getAppDelegate().isConnected()) {
            AppDelegate.getAppDelegate().setAlarm(alarmArray)
            SyncAlarmAlertView()
        }else{
            willSyncAlarmAlertView()
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
    func onDidAddAlarmAction(timer:NSTimeInterval,repeatStatus:Bool,name:String){

        let isStatus:Bool = mAlarmArray.count<3 ? true:false //Nevo sync only three alarm

        if(slectedIndex >= 0){
            let alarmModel:UserAlarm =  mAlarmArray[slectedIndex] as! UserAlarm
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":alarmModel.status,"repeatStatus":repeatStatus,"dayOfWeek":0,"type":0])
            if(addalarm.update()){
                mAlarmArray.replaceObjectAtIndex(slectedIndex, withObject: addalarm)
                self.editing = false
                self.tableView.setEditing(false, animated: true)
                self.tableView.reloadData()

                if(isStatus) {
                    var alarmArray:[Alarm] = []
                    for (index, value) in mAlarmArray.enumerate() {
                        if((value as! UserAlarm).status) {
                            let date:NSDate = NSDate(timeIntervalSince1970: timer)
                            let alarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: (value as! UserAlarm).status)
                            alarmArray.append(alarm)
                        }
                    }

                    for index:Int in alarmArray.count ..< 3 {
                        let date:NSDate = NSDate(timeIntervalSince1970: timer)
                        let alarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: false)
                        alarmArray.append(alarm)
                    }

                    if(AppDelegate.getAppDelegate().isConnected()){
                        AppDelegate.getAppDelegate().setAlarm(alarmArray)
                        SyncAlarmAlertView()
                    }else{
                        willSyncAlarmAlertView()
                    }
                }
                slectedIndex = -1
            }
        }else{
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":0,"timer":timer,"label":"\(name)","status":isStatus,"repeatStatus":repeatStatus,"dayOfWeek":0,"type":0])
            addalarm.add({ (id, completion) -> Void in
                if(completion!){
                    addalarm.id = id!
                    self.mAlarmArray.addObject(addalarm)
                    self.tableView.reloadData()

                    if(isStatus) {
                        var alarmArray:[Alarm] = []
                        for (index, value) in self.mAlarmArray.enumerate() {
                            if((value as! UserAlarm).status) {
                                let date:NSDate = NSDate(timeIntervalSince1970: timer)
                                let alarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: (value as! UserAlarm).status)
                                alarmArray.append(alarm)
                            }
                        }

                        for index:Int in alarmArray.count ..< 3 {
                            let date:NSDate = NSDate(timeIntervalSince1970: timer)
                            let alarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: true)
                            alarmArray.append(alarm)
                        }

                        if(AppDelegate.getAppDelegate().isConnected()){
                            AppDelegate.getAppDelegate().setAlarm(alarmArray)
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

    func onDidAddAlarmAction(timer:NSTimeInterval,name:String,repeatNumber:Int,alarmType:Int) {

        var sleepAlarmCount:Int = 7
        var dayAlarmCount:Int = 0
        for alarm in mAlarmArray{
            let alarmModel:UserAlarm =  alarm as! UserAlarm
            if(alarmModel.type == 1 && alarmModel.status) {
                sleepAlarmCount++
            }else if (alarmModel.type == 0 && alarmModel.status){
                dayAlarmCount++
            }
        }

        if(slectedIndex >= 0){
            let alarmModel:UserAlarm =  mAlarmArray[slectedIndex] as! UserAlarm
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":alarmModel.status,"repeatStatus":false,"dayOfWeek":repeatNumber,"type":alarmType])
            if(addalarm.update()){
                mAlarmArray.replaceObjectAtIndex(slectedIndex, withObject: addalarm)
                self.editing = false
                self.tableView.setEditing(false, animated: true)
                self.tableView.reloadData()

                let date:NSDate = NSDate(timeIntervalSince1970: timer)
                let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: Bool(alarmType) ? sleepAlarmCount:dayAlarmCount, alarmWeekday: repeatNumber)

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

            let switchStatus:Bool = Bool(alarmType) ? isSleepStatus:isDayStatus
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":0,"timer":timer,"label":"\(name)","status":switchStatus ,"repeatStatus":false,"dayOfWeek":repeatNumber,"type":alarmType])
            addalarm.add({ (id, completion) -> Void in
                if(completion!){
                    addalarm.id = id!
                    self.mAlarmArray.addObject(addalarm)
                    self.tableView.reloadData()

                    let date:NSDate = NSDate(timeIntervalSince1970: timer)
                    let newAlarm:NewAlarm = NewAlarm(alarmhour: date.hour, alarmmin: date.minute, alarmNumber: Bool(alarmType) ? sleepAlarmCount:dayAlarmCount, alarmWeekday: repeatNumber)

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

    // MARK: - SyncControllerDelegate
    func receivedRSSIValue(number:NSNumber){

    }

    func packetReceived(packet:NevoPacket) {
    
    }

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check

        //checkConnection()

    }

    func syncFinished(){

    }

    func stringFromDate(date:NSDate) -> String {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "HH:mm a"
        let dateString:String = dateFormatter.stringFromDate(date)
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
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }


    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(mAlarmArray.count == 0) {
            tableView.backgroundView = NotAlarmView.getNotAlarmView()
        }else{
             tableView.backgroundView = nil
        }
        return mAlarmArray.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let titleArray:[String] = ["Sleep Alarm","alarmTitle"]
        //NSLocalizedString(titleArray[section], comment: "")
        return ""
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("alarmCell", forIndexPath: indexPath)
        let alarmModel:UserAlarm = mAlarmArray[indexPath.row] as! UserAlarm
        let timerLabel = endCell.contentView.viewWithTag(1500)
        if(timerLabel != nil){
            let date:NSDate = NSDate(timeIntervalSince1970: alarmModel.timer)
            (timerLabel as! UILabel).text = stringFromDate(date)
        }

        let nameLabel = endCell.contentView.viewWithTag(1600)
        if(nameLabel != nil){
            (nameLabel as! UILabel).text = alarmModel.label
        }

        let mSwitch = endCell.contentView.viewWithTag(1700)
        if(mSwitch != nil){
            (mSwitch as! UISwitch).tag = indexPath.row
            (mSwitch as! UISwitch).addTarget(self, action: #selector(controllManager(_:)), forControlEvents: UIControlEvents.ValueChanged)
            (mSwitch as! UISwitch).on = alarmModel.status
        }

        endCell.selectionStyle = UITableViewCellSelectionStyle.None
        return endCell
    }


    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let willAlarm:UserAlarm = mAlarmArray[indexPath.row] as! UserAlarm
            if(willAlarm.remove()){
                mAlarmArray.removeObjectAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                var alarmArray:[Alarm] = []
                for (index, value) in self.mAlarmArray.enumerate() {
                    if((value as! UserAlarm).status) {
                        let date:NSDate = NSDate(timeIntervalSince1970: (value as! UserAlarm).timer)
                        let alarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: (value as! UserAlarm).status)
                        alarmArray.append(alarm)
                    }
                }

                for index:Int in alarmArray.count ..< 3 {
                    let date:NSDate = NSDate()
                    let alarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: false)
                    alarmArray.append(alarm)
                }

                //Only delete state switch on will be synchronized to watch
                if(willAlarm.status) {
                    if(AppDelegate.getAppDelegate().isConnected()){
                        AppDelegate.getAppDelegate().setAlarm(alarmArray)
                        self.SyncAlarmAlertView()
                    }else{
                        self.willSyncAlarmAlertView()
                    }
                }
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(self.editing){
            slectedIndex = indexPath.row
            let alarmModel:UserAlarm = mAlarmArray[indexPath.row] as! UserAlarm

            if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue <= 18) {
                let addAlarm:AddAlarmController = AddAlarmController()
                addAlarm.title = NSLocalizedString("edit_alarm", comment: "")
                addAlarm.timer = alarmModel.timer
                addAlarm.name = alarmModel.label
                addAlarm.repeatStatus = alarmModel.repeatStatus
                addAlarm.mDelegate = self
                addAlarm.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(addAlarm, animated: true)
            }else{
                let addAlarm:NewAddAlarmController = NewAddAlarmController()
                addAlarm.title = NSLocalizedString("edit_alarm", comment: "")
                addAlarm.timer = alarmModel.timer
                addAlarm.name = alarmModel.label
                addAlarm.alarmTypeIndex = alarmModel.type
                addAlarm.repeatSelectedIndex = alarmModel.dayOfWeek
                addAlarm.mDelegate = self
                addAlarm.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(addAlarm, animated: true)
            }

        }

    }
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}
