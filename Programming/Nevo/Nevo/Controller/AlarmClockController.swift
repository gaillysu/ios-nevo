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
    
    private var mAlarmhour:Int = 8
    private var mAlarmmin:Int = 30
    private var mAlarmenable:Bool = false
    private var mSyncController:SyncController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)
        
        //If we have any previously saved hour, min and/or enabled/ disabled, we'll use those variables first
        if let alarmHourSaved = NSUserDefaults.standardUserDefaults().objectForKey(SAVED_ALARM_HOUR_KEY) as? Int {
            mAlarmhour = alarmHourSaved
        }

        if let alarmMinSaved = NSUserDefaults.standardUserDefaults().objectForKey(SAVED_ALARM_MIN_KEY) as? Int {
            mAlarmmin = alarmMinSaved
        }
        
        if let alarmEnableSaved = NSUserDefaults.standardUserDefaults().objectForKey(SAVED_ALARM_ENABLED_KEY) as? Bool {
            mAlarmenable = alarmEnableSaved
        }

        alarmView.bulidAlarmView(self,hour:mAlarmhour,min:mAlarmmin,enabled:mAlarmenable)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()
    }

    override func viewDidLayoutSubviews() {
        alarmView.bulidUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        if sender.isEqual(alarmView.selectedTimerButton){
            alarmView.initPickerView(mAlarmhour,min: mAlarmmin)
            NSLog("alarmView.selectedTimerButton")
        }

        if sender.isEqual(alarmView.alarmSwitch){
            NSLog("alarmView.alarmSwitch")
            setAlarm()
        }

        if sender.isEqual(alarmView.animationView.getNoConnectScanButton()?) {
            NSLog("noConnectScanButton")
            reconnect()
        }
        if sender.isEqual(alarmView.getEnterButton()?){
            NSLog("alarmView.enterButton")
            setAlarm()
        }
        if sender.isEqual(alarmView.setingButton){
            NSLog("alarmView.setingButton")

        }

        if sender.isEqual(alarmView.amButton){
            alarmView.amButton.selected = true
            alarmView.pmButton.selected = false
            NSLog("alarmView.amButton")

        }
        if sender.isEqual(alarmView.pmButton){
            alarmView.amButton.selected = false
            alarmView.pmButton.selected = true
            NSLog("alarmView.pmButton")

        }

        if sender.isEqual(alarmView.setingButton){
            self.performSegueWithIdentifier("Home_Seting", sender: self)
        }

    }
    
    func setAlarm() {
        
        if let date = alarmView.getDatePicker()?.date  {
            
            var strDate = stringFromDate(date)
            
            var lines:[String] = strDate.componentsSeparatedByString(":");
            
            mAlarmhour = (lines[0] as NSString).integerValue
            mAlarmmin  = (lines[1] as NSString).integerValue
            
        }
        
        mAlarmenable = alarmView.getEnabled()
        
        alarmView.setAlarmTime(mAlarmhour,min: mAlarmmin)
        
        mSyncController?.setAlarm(mAlarmhour, alarmmin: mAlarmmin, alarmenable: mAlarmenable)
        
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        userDefaults.setObject(mAlarmhour,forKey:SAVED_ALARM_HOUR_KEY)
        userDefaults.setObject(mAlarmmin,forKey:SAVED_ALARM_MIN_KEY)
        userDefaults.setObject(mAlarmenable,forKey:SAVED_ALARM_ENABLED_KEY)
        
        userDefaults.synchronize()
        
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
           alarmView.addSubview(alarmView.animationView.bulibNoConnectView())
            reconnect()
        } else {
            
            alarmView.animationView.endConnectRemoveView()
        }


    }

}
