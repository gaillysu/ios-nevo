//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockController: UITableViewController, SyncControllerDelegate,AddAlarmDelegate {

    class var SAVED_ALARM_HOUR_KEY:String {
        return "SAVED_ALARM_HOUR_KEY"
    }

    class var SAVED_ALARM_MIN_KEY:String {
        return "SAVED_ALARM_MIN_KEY"
    }

    class var SAVED_ALARM_ENABLED_KEY:String {
        return "SAVED_ALARM_ENABLED_KEY"
    }

    class var SAVED_ALARM_INDEX_KEY:String {
        return "SAVED_ALARM_INDEX_KEY"
    }

    class var SAVED_ALARM_ARRAY0:String {
        return "SAVED_ALARM_ARRAY0";
    }

    class var SAVED_ALARM_ARRAY1:String {
        return "SAVED_ALARM_ARRAY1";
    }

    class var SAVED_ALARM_ARRAY2:String {
        return "SAVED_ALARM_ARRAY2";
    }

    @IBOutlet var alarmView: alarmClockView!

    private var mAlarmhour:Int = 8
    private var mAlarmmin:Int = 30
    private var mAlarmindex:Int = 0
    private var mAlarmenable:Bool = false
    var alarmArray:[Alarm] = []
    var mAlarmArray:[UserAlarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alarmView.bulidAlarmView()
        
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        self.editButtonItem().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let rightAddButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("controllManager:"))
        //
        rightAddButton.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.rightBarButtonItem = rightAddButton

        let array:NSArray = UserAlarm.getAll()
        for alarmModel in array{
            let useralarm:UserAlarm = alarmModel as! UserAlarm
            mAlarmArray.append(useralarm)

            let date:NSDate = NSDate(timeIntervalSince1970: useralarm.timer)
            let alarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: mAlarmenable)
            alarmArray.append(alarm)
        }
        // Do any additional setup after loading the view.
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
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addAlarm, animated: true)
        }

        if(sender.isKindOfClass(UISwitch.classForCoder())){
            let mSwitch:UISwitch = sender as! UISwitch
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":mAlarmArray[mSwitch.tag].id,"timer":mAlarmArray[mSwitch.tag].timer,"label":"\(mAlarmArray[mSwitch.tag].label)","status":mSwitch.on,"repeatStatus":mAlarmArray[mSwitch.tag].repeatStatus])
            if(addalarm.update()){
                mAlarmArray.removeAtIndex(mSwitch.tag)
                mAlarmArray.append(addalarm)
                self.tableView.reloadData()

                let date:NSDate = NSDate(timeIntervalSince1970: addalarm.timer)
                let alarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: mSwitch.on)
                alarmArray.removeAtIndex(mSwitch.tag)
                alarmArray.append(alarm)
                AppDelegate.getAppDelegate().setAlarm(alarmArray)
            }

        }

    }

    // MARK: - AddAlarmDelegate
    func onDidAddAlarmAction(timer:NSTimeInterval,repeatStatus:Bool,name:String){

        if(alarmArray.count>3){
            let aler:UIAlertView = UIAlertView(title: "Tip", message: "Only add three alarm", delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
            aler.show()
        }else{
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":0,"timer":timer,"label":"\(name)","status":true,"repeatStatus":repeatStatus])
            if(addalarm.add()){
                mAlarmArray.append(addalarm)
                self.tableView.reloadData()

                let date:NSDate = NSDate(timeIntervalSince1970: timer)
                let alarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: mAlarmenable)
                alarmArray.append(alarm)
                AppDelegate.getAppDelegate().setAlarm(alarmArray)
            }else{
                let aler:UIAlertView = UIAlertView(title: "Tip", message: "Database insert fail", delegate: nil, cancelButtonTitle: "ok")
                aler.show()
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

    // MARK: - Function
    /**
    Format from the alarm data

    :param: alarmArray Alarm dictionary

    :returns: Returns the Alarm
    */
    func getLoclAlarm(alarmArray:NSDictionary)->Alarm{
        let alarm_index:Int = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_INDEX_KEY) as! NSNumber).integerValue
        let alarm_hour:Int = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_HOUR_KEY) as! NSNumber).integerValue
        let alarm_min:Int = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_MIN_KEY) as! NSNumber).integerValue
        let alarm_enabled:Bool = (alarmArray.objectForKey(AlarmClockController.SAVED_ALARM_ENABLED_KEY) as! NSNumber).boolValue
        let alarm:Alarm = Alarm(index: alarm_index, hour: alarm_hour, minute: alarm_min, enable: alarm_enabled)
        return alarm
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

    func setAlarm(aObject:AnyObject) {
        var tagValue:Int = 0
        if(aObject.isKindOfClass(UISwitch .classForCoder())){
            tagValue = (aObject as! UISwitch).tag

            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            switch tagValue {
            case 0:
                if let alarmArray1 = userDefaults.objectForKey(AlarmClockController.SAVED_ALARM_ARRAY0) as? NSDictionary {
                    let alarm:Alarm = getLoclAlarm(alarmArray1)
                    mAlarmhour = alarm.getHour()
                    mAlarmmin  = alarm.getMinute()
                }
            case 1:
                if let alarmArray2 = userDefaults.objectForKey(AlarmClockController.SAVED_ALARM_ARRAY1) as? NSDictionary {
                    let alarm:Alarm = getLoclAlarm(alarmArray2)
                    mAlarmhour = alarm.getHour()
                    mAlarmmin  = alarm.getMinute()
                }
            case 2:
                if let alarmArray3 = userDefaults.objectForKey(AlarmClockController.SAVED_ALARM_ARRAY2) as? NSDictionary {
                    let alarm:Alarm = getLoclAlarm(alarmArray3)
                    mAlarmhour = alarm.getHour()
                    mAlarmmin  = alarm.getMinute()
                }
            default:
                ""
            }
            mAlarmindex = tagValue
            mAlarmenable = (aObject as! UISwitch).on
            addAlarmArray((aObject as! UISwitch).tag)

        }

        if(aObject.isKindOfClass(UIButton .classForCoder())){
            tagValue = (aObject as! UIButton).tag

        }

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let alarmDict:NSDictionary = [AlarmClockController.SAVED_ALARM_HOUR_KEY : NSNumber(integer: mAlarmhour),AlarmClockController.SAVED_ALARM_MIN_KEY : NSNumber(integer: mAlarmmin),AlarmClockController.SAVED_ALARM_ENABLED_KEY : NSNumber(bool: mAlarmenable),AlarmClockController.SAVED_ALARM_INDEX_KEY : NSNumber(integer: mAlarmindex)]
        let loadUserKey:String = String(format: "SAVED_ALARM_ARRAY%d",tagValue);
        userDefaults.setObject(alarmDict, forKey: loadUserKey)
        
        userDefaults.synchronize()
        
    }


    func addAlarmArray(index:Int){
        for object in alarmArray{
            let alarm:Alarm = (object as Alarm)
            if(alarm.getIndex() == index){
                let alarm:Alarm = Alarm(index:index, hour: mAlarmhour, minute: mAlarmmin, enable: mAlarmenable)
                alarmArray.removeAtIndex(index)
                alarmArray.insert(alarm, atIndex: index)
                AppDelegate.getAppDelegate().setAlarm(alarmArray)
                return;
            }
        }
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }


    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return mAlarmArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("alarmCell", forIndexPath: indexPath)
        let alarmModel:UserAlarm = mAlarmArray[indexPath.row]
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


    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if(mAlarmArray[indexPath.row].remove()){
                alarmArray.removeAtIndex(indexPath.row)
                mAlarmArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
