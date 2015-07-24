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
            setAlarm(sender)
            AppTheme.DLog("alarmView.amButton")

        }

        if sender.isEqual(alarmView.alarmSwicth2){
            setAlarm(sender)
            AppTheme.DLog("alarmView.pmButton")
        }

        if sender.isEqual(alarmView.alarmSwicth2){
            setAlarm(sender)
            AppTheme.DLog("alarmView.pmButton")
        }

        if sender.isEqual(alarmView.setingButton){
            self.performSegueWithIdentifier("Home_Seting", sender: self)
        }

    }
    
    func setAlarm(aObject:AnyObject) {
        
        if let date = alarmView.getDatePicker()?.date  {
            
            var strDate = stringFromDate(date)
            
            var lines:[String] = strDate.componentsSeparatedByString(":");
            
            mAlarmhour = (lines[0] as NSString).integerValue
            mAlarmmin  = (lines[1] as NSString).integerValue
            
        }

        if(aObject.isEqual(UISwitch)){
            mAlarmenable = alarmView.getEnabled(aObject as! UISwitch)
        }

        alarmView.setAlarmTime(mAlarmhour,min: mAlarmmin,andObject: alarmView.getCurrentButton())

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
