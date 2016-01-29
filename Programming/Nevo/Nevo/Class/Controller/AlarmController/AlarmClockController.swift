//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockController: UITableViewController, SyncControllerDelegate,AddAlarmDelegate,DatePickerViewDelegate {
    @IBOutlet var alarmView: alarmClockView!

    private var slectedIndex:Int = -1 //To edit a record the number of rows selected content
    var alarmArray:[Alarm] = []
    var mAlarmArray:NSMutableArray = NSMutableArray()
    var configSleepArray:NSMutableArray = NSMutableArray()
    let SleepAlarmKey = "SLEEPALARMKEY";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initValue()

        alarmView.bulidAlarmView()
        
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        self.editButtonItem().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let rightAddButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("controllManager:"))
        rightAddButton.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.rightBarButtonItem = rightAddButton

        self.tableView.allowsSelectionDuringEditing = true;

    }

    func initValue() {
        let dataArray:NSArray = AppTheme.LoadKeyedArchiverName(SleepAlarmKey) as! NSArray
        if(dataArray.count>0) {
            let date:NSTimeInterval = (dataArray[1] as! String).dateFromFormat("YYYY/MM/dd")!.timeIntervalSince1970
            if(date != NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day).timeIntervalSince1970){ return }
            configSleepArray.addObjectsFromArray(dataArray[0] as! [AnyObject])
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }else{
            configSleepArray.addObjectsFromArray([[22,30],[7,30],[5],false])
        }

        let array:NSArray = UserAlarm.getAll()
        for alarmModel in array{
            let useralarm:UserAlarm = alarmModel as! UserAlarm
            mAlarmArray.addObject(useralarm)

            let date:NSDate = NSDate(timeIntervalSince1970: useralarm.timer)
            let alarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: useralarm.status)
            alarmArray.append(alarm)
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
            let addAlarm:AddAlarmController = AddAlarmController()
            addAlarm.title = NSLocalizedString("add_alarm", comment: "")
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addAlarm, animated: true)
        }

        if(sender.isKindOfClass(UISwitch.classForCoder())){
            let mSwitch:UISwitch = sender as! UISwitch
            if(mSwitch.tag == 2700) {
                let startArray:NSArray = configSleepArray[0] as! NSArray
                let endArray:NSArray = configSleepArray[1] as! NSArray
                let weekArray:NSArray = configSleepArray[2] as! NSArray
                let mEnable:Bool = mSwitch.on
                configSleepArray.replaceObjectAtIndex(3, withObject: mEnable)

                let sleepAlarm:ConfigSleepAlarm = ConfigSleepAlarm(startHour: (startArray[0] as! NSNumber).integerValue, startMinute: (startArray[1] as! NSNumber).integerValue, endtHour: (endArray[0] as! NSNumber).integerValue, endMinute: (endArray[1] as! NSNumber).integerValue, enable: mSwitch.on, weekday: (weekArray[0] as! NSNumber).integerValue)
                AppDelegate.getAppDelegate().setSleepStartAlarm(sleepAlarm)

                AppTheme.KeyedArchiverName(SleepAlarmKey, andObject: configSleepArray)
            }else {
                let alarmA:UserAlarm = mAlarmArray[mSwitch.tag] as! UserAlarm
                let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmA.id,"timer":alarmA.timer,"label":"\(alarmA.label)","status":mSwitch.on,"repeatStatus":alarmA.repeatStatus])
                if(addalarm.update()){
                    mAlarmArray.replaceObjectAtIndex(mSwitch.tag, withObject: addalarm)
                    self.tableView.reloadData()

                    let date:NSDate = NSDate(timeIntervalSince1970: addalarm.timer)
                    let alarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: mSwitch.on)
                    alarmArray.removeAtIndex(mSwitch.tag)
                    alarmArray.append(alarm)

                    if(AppDelegate.getAppDelegate().isConnected()) {
                        AppDelegate.getAppDelegate().setAlarm(alarmArray)
                        let banner = Banner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 2.0)
                    }else{
                        let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 2.0)
                    }
                }
            }
        }

    }

    // MARK: - AddAlarmDelegate
    func onDidAddAlarmAction(timer:NSTimeInterval,repeatStatus:Bool,name:String){

        if(mAlarmArray.count==3){
            let aler:UIAlertView = UIAlertView(title: NSLocalizedString("alarmTitle", comment: ""), message:NSLocalizedString("nevo_alarms_supports", comment: "") , delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
            aler.show()
        }else{
            if(AppDelegate.getAppDelegate().isConnected()) {
                let banner = Banner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }else{
                let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }

            if(slectedIndex >= 0){
                let alarmModel:UserAlarm =  mAlarmArray[slectedIndex] as! UserAlarm
                let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":true,"repeatStatus":repeatStatus])
                if(addalarm.update()){
                    mAlarmArray.replaceObjectAtIndex(slectedIndex, withObject: addalarm)
                    self.editing = false
                    self.tableView.setEditing(false, animated: true)
                    self.tableView.reloadData()

                    let date:NSDate = NSDate(timeIntervalSince1970: timer)
                    let alarm:Alarm = alarmArray[slectedIndex]
                    let reAlarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: alarm.getEnable())
                    alarmArray.removeAtIndex(slectedIndex)
                    alarmArray.insert(reAlarm, atIndex: slectedIndex)
                    if(AppDelegate.getAppDelegate().isConnected()){
                        AppDelegate.getAppDelegate().setAlarm(alarmArray)
                    }
                    slectedIndex = -1
                }
            }else{
                let addalarm:UserAlarm = UserAlarm(keyDict: ["id":0,"timer":timer,"label":"\(name)","status":true,"repeatStatus":repeatStatus])
                addalarm.add({ (id, completion) -> Void in
                    if(completion!){
                        addalarm.id = id!
                        self.mAlarmArray.addObject(addalarm)
                        self.tableView.reloadData()

                        let date:NSDate = NSDate(timeIntervalSince1970: timer)
                        let alarm:Alarm = Alarm(index:self.alarmArray.count, hour: date.hour, minute: date.minute, enable: true)
                        self.alarmArray.append(alarm)
                        if(AppDelegate.getAppDelegate().isConnected()){
                            AppDelegate.getAppDelegate().setAlarm(self.alarmArray)
                        }
                    }else{
                        let aler:UIAlertView = UIAlertView(title: "Tip", message: "Database insert fail", delegate: nil, cancelButtonTitle: "ok")
                        aler.show()
                    }
                })
            }
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

    @IBAction func SleepTomerAction(sender: AnyObject) {
        let button:UIButton = sender as! UIButton
        if(button.tag == 1300) {
            let pickerView:DatePickerView = DatePickerView()
            pickerView.delegate = self;
            pickerView.index = 0
            self.presentViewController(pickerView, animated: true, completion: nil)
        }

        if(button.tag == 1500) {
            let pickerView:DatePickerView = DatePickerView()
            pickerView.delegate = self;
            pickerView.index = 1
            self.presentViewController(pickerView, animated: true, completion: nil)
        }
    }

    // MARK: - DatePickerViewDelegate
    func getSelectDate(index:Int,date:NSArray){
        AppTheme.DLog("timer start:\(date)")
        configSleepArray.replaceObjectAtIndex(0, withObject: date)
        let startArray:NSArray = date[0] as! NSArray
        let endArray:NSArray = date[1] as! NSArray
        let weekArray:NSArray = date[2] as! NSArray
        let mEnable:Bool = date[3] as! Bool
        let sleepAlarm:ConfigSleepAlarm = ConfigSleepAlarm(startHour: (startArray[0] as! NSNumber).integerValue, startMinute: (startArray[1] as! NSNumber).integerValue, endtHour: (endArray[0] as! NSNumber).integerValue, endMinute: (endArray[1] as! NSNumber).integerValue, enable: mEnable, weekday: (weekArray[0] as! NSNumber).integerValue)
        AppDelegate.getAppDelegate().setSleepStartAlarm(sleepAlarm)

        AppTheme.KeyedArchiverName(SleepAlarmKey, andObject: configSleepArray)

    }

    // MARK: - UITableViewDelegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 2
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }


    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(section == 0) {
            return 1
        }else{
            return mAlarmArray.count
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let titleArray:[String] = ["Sleep Alarm","Alarm"]
        return titleArray[section]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if(indexPath.section == 0) {
            let endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("sleepAlarmCell", forIndexPath: indexPath)
            endCell.endEditing(false)
            let startArray:NSArray = configSleepArray[0] as! NSArray
            let endArray:NSArray = configSleepArray[1] as! NSArray
            let weekArray:NSArray = configSleepArray[2] as! NSArray
            let mEnable:Bool = configSleepArray[3] as! Bool
            let sleepAlarm:ConfigSleepAlarm = ConfigSleepAlarm(startHour: (startArray[0] as! NSNumber).integerValue, startMinute: (startArray[1] as! NSNumber).integerValue, endtHour: (endArray[0] as! NSNumber).integerValue, endMinute: (endArray[1] as! NSNumber).integerValue, enable: mEnable, weekday: (weekArray[0] as! NSNumber).integerValue)

            let StartTimerLabel = endCell.contentView.viewWithTag(1300)
            if(StartTimerLabel != nil){
                let date:NSDate = NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day, hour: sleepAlarm.getStartHour(), minute: sleepAlarm.getStartMinute(), second: NSDate().second)
                (StartTimerLabel as! UIButton).setTitle(stringFromDate(date), forState: UIControlState.Normal)
            }

            let EndTimerLabel = endCell.contentView.viewWithTag(1500)
            if(EndTimerLabel != nil){
                let date:NSDate = NSDate.date(year: NSDate().year, month: NSDate().month, day: NSDate().day, hour: sleepAlarm.getEndHour(), minute: sleepAlarm.getEndMinute(), second: NSDate().second)
                (EndTimerLabel as! UIButton).setTitle(stringFromDate(date), forState: UIControlState.Normal)
            }

            let mSwitch = endCell.contentView.viewWithTag(2700)
            if(mSwitch != nil){
                (mSwitch as! UISwitch).addTarget(self, action: Selector("controllManager:"), forControlEvents: UIControlEvents.ValueChanged)
                (mSwitch as! UISwitch).on = sleepAlarm.getEnable()
            }

            endCell.selectionStyle = UITableViewCellSelectionStyle.None
            return endCell
        }else{
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
                (mSwitch as! UISwitch).addTarget(self, action: Selector("controllManager:"), forControlEvents: UIControlEvents.ValueChanged)
                (mSwitch as! UISwitch).on = alarmModel.status
            }

            endCell.selectionStyle = UITableViewCellSelectionStyle.None
            return endCell
        }
    }


    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0) {
            return
        }

        if editingStyle == .Delete {
            // Delete the row from the data source
            if((mAlarmArray[indexPath.row] as! UserAlarm).remove()){
                alarmArray.removeAtIndex(indexPath.row)
                mAlarmArray.removeObjectAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                if(AppDelegate.getAppDelegate().isConnected()){
                    AppDelegate.getAppDelegate().setAlarm(alarmArray)
                    let banner = Banner(title: NSLocalizedString("syncing_Alarm", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                }else{
                    let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
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
            let addAlarm:AddAlarmController = AddAlarmController()
            addAlarm.title = NSLocalizedString("edit_alarm", comment: "")
            addAlarm.timer = alarmModel.timer
            addAlarm.name = alarmModel.label
            addAlarm.repeatStatus = alarmModel.repeatStatus
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addAlarm, animated: true)
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
