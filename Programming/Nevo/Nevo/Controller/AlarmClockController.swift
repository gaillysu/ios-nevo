//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockController: UIViewController, SyncControllerDelegate,ButtonManagerCallBack {

    @IBOutlet var alarmView: alarmClockView!
    
    let SAVED_ALARM_HOUR_KEY = "SAVED_ALARM_HOUR_KEY"
    let SAVED_ALARM_MIN_KEY = "SAVED_ALARM_MIN_KEY"
    let SAVED_ALARM_ENABLED_KEY = "SAVED_ALARM_ENABLED_KEY"
    let SAVED_ALARM_INDEX_KEY = "SAVED_ALARM_INDEX_KEY"

    let SAVED_ALARM_ARRAY0 = "SAVED_ALARM_ARRAY0"
    let SAVED_ALARM_ARRAY1 = "SAVED_ALARM_ARRAY1"
    let SAVED_ALARM_ARRAY2 = "SAVED_ALARM_ARRAY2"
    
    private var mAlarmhour:Int = 8
    private var mAlarmmin:Int = 30
    private var mAlarmindex:Int = 0
    private var mAlarmenable:Bool = false
    private var mSyncController:SyncController?
    var alarmArray:[Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        //If we have any previously saved hour, min and/or enabled/ disabled, we'll use those variables first
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let alarmArray1 = userDefaults.objectForKey(SAVED_ALARM_ARRAY0) as? NSDictionary {
            alarmArray.append(getLoclAlarm(alarmArray1))
        }

        if let alarmArray2 = userDefaults.objectForKey(SAVED_ALARM_ARRAY1) as? NSDictionary {
            alarmArray.append(getLoclAlarm(alarmArray2))
        }
        
        if let alarmArray3 = userDefaults.objectForKey(SAVED_ALARM_ARRAY2) as? NSDictionary {
            alarmArray.append(getLoclAlarm(alarmArray3))
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

    /**
    Format from the alarm data

    :param: alarmArray Alarm dictionary

    :returns: Returns the Alarm
    */
    func getLoclAlarm(alarmArray:NSDictionary)->Alarm{
        let alarm_index:Int = (alarmArray.objectForKey(SAVED_ALARM_INDEX_KEY) as! NSNumber).integerValue
        let alarm_hour:Int = (alarmArray.objectForKey(SAVED_ALARM_HOUR_KEY) as! NSNumber).integerValue
        let alarm_min:Int = (alarmArray.objectForKey(SAVED_ALARM_MIN_KEY) as! NSNumber).integerValue
        let alarm_enabled:Bool = (alarmArray.objectForKey(SAVED_ALARM_ENABLED_KEY) as! NSNumber).boolValue
        let alarm:Alarm = Alarm(index: alarm_index, hour: alarm_hour, minute: alarm_min, enable: alarm_enabled)
        return alarm
    }

    func stringFromDate(date:NSDate) -> String {
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
    }

    /*
    call back Button Action
    */
    func controllManager(sender:AnyObject){

        if (sender.isEqual(alarmView.selectedTimerButton1) || sender.isEqual(alarmView.selectedTimerButton2) || sender.isEqual(alarmView.selectedTimerButton3)){
            alarmView.initPickerView(mAlarmhour,min: mAlarmmin)
            alarmView.setCurrentButton(sender as! UIButton)
            AppTheme.DLog("alarmView.selectedTimerButton")
        }

        if sender.isEqual(alarmView.animationView.getNoConnectScanButton()) {
            AppTheme.DLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(alarmView.getEnterButton()){
            AppTheme.DLog("alarmView.enterButton")
            setAlarm(sender)
        }

        if sender.isEqual(alarmView.setingButton){
            AppTheme.DLog("alarmView.setingButton")

        }

        if sender.isEqual(alarmView.alarmSwicth1){
            alarmView.setCurrentButton(alarmView.selectedTimerButton1)
            setAlarm(sender)
            AppTheme.DLog("alarmView.amButton")

        }

        if sender.isEqual(alarmView.alarmSwicth2){
            alarmView.setCurrentButton(alarmView.selectedTimerButton2)
            setAlarm(sender)
            AppTheme.DLog("alarmView.pmButton")
        }

        if sender.isEqual(alarmView.alarmSwicth3){
            alarmView.setCurrentButton(alarmView.selectedTimerButton3)
            setAlarm(sender)
            AppTheme.DLog("alarmView.pmButton")
        }

        if sender.isEqual(alarmView.setingButton){
            self.performSegueWithIdentifier("Home_Seting", sender: self)
        }

    }
    
    func setAlarm(aObject:AnyObject) {
        var tagValue:Int = 0
        if(aObject.isKindOfClass(UISwitch .classForCoder())){
            tagValue = (aObject as! UISwitch).tag

            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            switch tagValue {
            case 0:
                if let alarmArray1 = userDefaults.objectForKey(SAVED_ALARM_ARRAY0) as? NSDictionary {
                    let alarm:Alarm = getLoclAlarm(alarmArray1)
                    mAlarmhour = alarm.getHour()
                    mAlarmmin  = alarm.getMinute()
                }
            case 1:
                if let alarmArray2 = userDefaults.objectForKey(SAVED_ALARM_ARRAY1) as? NSDictionary {
                    let alarm:Alarm = getLoclAlarm(alarmArray2)
                    mAlarmhour = alarm.getHour()
                    mAlarmmin  = alarm.getMinute()
                }
            case 2:
                if let alarmArray3 = userDefaults.objectForKey(SAVED_ALARM_ARRAY2) as? NSDictionary {
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
            
            if let date = alarmView.getDatePicker()?.date  {

                var strDate = stringFromDate(date)

                var lines:[String] = strDate.componentsSeparatedByString(":");

                mAlarmhour = (lines[0] as NSString).integerValue
                mAlarmmin  = (lines[1] as NSString).integerValue
            }

            mAlarmenable = alarmView.getEnabled((aObject as! UIButton).tag)
            addAlarmArray((aObject as! UIButton).tag)
            mAlarmindex = tagValue
        }

        alarmView.setAlarmTime(mAlarmhour,min: mAlarmmin,andObject: alarmView.getCurrentButton())

        let userDefaults = NSUserDefaults.standardUserDefaults();
        let alarmDict:NSDictionary = NSDictionary(objectsAndKeys: NSNumber(integer: mAlarmhour),SAVED_ALARM_HOUR_KEY,NSNumber(integer: mAlarmmin),SAVED_ALARM_MIN_KEY,NSNumber(bool: mAlarmenable),SAVED_ALARM_ENABLED_KEY,NSNumber(integer: mAlarmindex),SAVED_ALARM_INDEX_KEY)
        let loadUserKey:String = String(format: "SAVED_ALARM_ARRAY%d",tagValue);
        userDefaults.setObject(alarmDict, forKey: loadUserKey)
        
        userDefaults.synchronize()
        
    }

    func addAlarmArray(index:Int){
        for object in enumerate(alarmArray){
            AppTheme.DLog("元素下标:\(object.0)  元素值:\(object.1)");
            var alarm:Alarm = (object.1 as Alarm)
            if(alarm.getIndex() == index){
                var alarm:Alarm = Alarm(index:index, hour: mAlarmhour, minute: mAlarmmin, enable: mAlarmenable)
                alarmArray.removeAtIndex(object.0)
                alarmArray.insert(alarm, atIndex: index)
                return;
            }
        }

        var alarm:Alarm = Alarm(index:index, hour: mAlarmhour, minute: mAlarmmin, enable: mAlarmenable)
        alarmArray.append(alarm)

        mSyncController?.setAlarm(alarmArray)
    }

    func reconnect() {
            alarmView.animationView.RotatingAnimationObject(alarmView.animationView.getNoConnectImage()!)
            mSyncController?.connect()
    }

    /**
    See SyncControllerDelegate
    */
     func packetReceived(packet:NevoPacket) {
    
    }

    /**

    See SyncControllerDelegate

    */

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check

        checkConnection()

    }



    /**

    Checks if any device is currently connected

    */

    func checkConnection() {

        if mSyncController != nil && !(mSyncController!.isConnected()) {
            //We are currently not connected
            var isView:Bool = false
            for view in alarmView.subviews {
                let anView:UIView = view as! UIView
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
        self.view.bringSubviewToFront(alarmView.titleBgView)
    }

}
