//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockController: UIViewController, SyncControllerDelegate,ButtonManagerCallBack {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.getAppDelegate().startConnect(false, delegate: self)

        //If we have any previously saved hour, min and/or enabled/ disabled, we'll use those variables first
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let alarmArray1 = userDefaults.objectForKey(AlarmClockController.SAVED_ALARM_ARRAY0) as? NSDictionary {
            alarmArray.append(getLoclAlarm(alarmArray1))
        }else{
            alarmArray.append(Alarm(index:0, hour: mAlarmhour, minute: mAlarmmin, enable: mAlarmenable))
        }

        if let alarmArray2 = userDefaults.objectForKey(AlarmClockController.SAVED_ALARM_ARRAY1) as? NSDictionary {
            alarmArray.append(getLoclAlarm(alarmArray2))
        }else{
            alarmArray.append(Alarm(index:1, hour: mAlarmhour, minute: mAlarmmin, enable: mAlarmenable))
        }
        
        if let alarmArray3 = userDefaults.objectForKey(AlarmClockController.SAVED_ALARM_ARRAY2) as? NSDictionary {
            alarmArray.append(getLoclAlarm(alarmArray3))
        }else{
            alarmArray.append(Alarm(index:2, hour: mAlarmhour, minute: mAlarmmin, enable: mAlarmenable))
        }

        alarmView.bulidAlarmView(self,array: alarmArray)
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

        if sender.isEqual(alarmView.animationView.getNoConnectScanButton()) {
            AppTheme.DLog("noConnectScanButton")
            reconnect()
        }

    }

    // MARK: - SyncControllerDelegate
    func receivedRSSIValue(number:NSNumber){

    }

    func packetReceived(packet:NevoPacket) {
    
    }

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check

        checkConnection()

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
        dateFormatter.dateFormat = "HH:mm"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
    }

    /**
    Checks if any device is currently connected
    */
    func checkConnection() {

        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
            var isView:Bool = false
            for view in alarmView.subviews {
                let anView:UIView = view 
                if anView.isEqual(alarmView.animationView.bulibNoConnectView()) {
                    isView = true
                }
            }
            if !isView {
                alarmView.addSubview(alarmView.animationView.bulibNoConnectView())
                reconnect()
            }
        } else {

            alarmView.animationView.endConnectRemoveView()
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
        alarmView.animationView.RotatingAnimationObject(alarmView.animationView.getNoConnectImage()!)
        AppDelegate.getAppDelegate().connect()
    }

}
