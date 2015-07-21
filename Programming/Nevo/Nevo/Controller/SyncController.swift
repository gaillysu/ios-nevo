//
//  SyncController.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

/*
The sync controller handles all the very high level connection workflow
It checks that the firmware is up to date, and handles every steps of the synchronisation process
*/

class SyncController: NSObject,ConnectionControllerDelegate,UIAlertViewDelegate {
    
    //Let's sync every days
    let SYNC_INTERVAL:NSTimeInterval = 1*30*60 //unit is second in iOS, every 30min, do sync
    
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    
    private var mDelegates:[SyncControllerDelegate]
 
    private let mConnectionController : ConnectionController

    private var mPacketsbuffer:[NSData]
    
    private let mHealthKitStore:HKHealthStore = HKHealthStore()
    
    private var savedDailyHistory:[NevoPacket.DailyHistory]=[]
    private var currentDay:UInt8 = 0
    private var mAlertUpdateFW = false
    
    /**
    A classic singelton pattern
    */
    class var sharedInstance : SyncController {
        struct Singleton {
            static let instance = SyncController()
        }
        return Singleton.instance
    }

    
  private override init() {
        mDelegates = []
        mPacketsbuffer = []
        mConnectionController = ConnectionControllerImpl.sharedInstance
        super.init()
        mConnectionController.setDelegate(self)
    
    }
    
    func startConnect(forceScan:Bool,delegate:SyncControllerDelegate)
    {
        AppTheme.DLog("New delegate : \(delegate)")
        mDelegates.append(delegate)
        
        if forceScan
        {
            mConnectionController.forgetSavedAddress()
        }
        mConnectionController.connect()
    }
    
    //add new functions when  get connected Nevo
    
    
    /**
    This function will syncrhonise activity data with the watch.
    It is a long process and hence shouldn't be done too often, so we save the date of previous sync.
    The watch should be emptied after all data have been saved.
    */
    func syncActivityData() {
        var lastSync = 0.0
        if let lastSyncSaved = NSUserDefaults.standardUserDefaults().objectForKey(LAST_SYNC_DATE_KEY) as? Double {
            lastSync = lastSyncSaved
        }
        
        if( NSDate().timeIntervalSince1970-lastSync > SYNC_INTERVAL) {
            //We haven't synched for a while, let's sync now !
            AppTheme.DLog("*** Sync started ! ***")
            self.getDailyTrackerInfo()
        }

    }
    
    /**
    When the sync process is finished, le't refresh the date of sync
    */
    func syncFinished() {
        
        AppTheme.DLog("*** Sync finished ***")
        
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        userDefaults.setObject(NSDate().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)
        
        userDefaults.synchronize()
    }
    
    
    func setRTC() {
        sendRequest(SetRTCRequest())
    }
    
    func SetProfile() {
        sendRequest(SetProfileRequest())
    }
    func SetCardio() {
        sendRequest(SetCardioRequest())
    }
    
    func WriteSetting() {
        sendRequest(WriteSettingRequest())
    }
   
    //end functions for connected to Nevo
    
    //below functions by UI
    
    func  getDailyTrackerInfo()
    {
        sendRequest(ReadDailyTrackerInfo())
    }
    
    func  getDailyTracker(trackerno:UInt8)
    {
        sendRequest(ReadDailyTracker(trackerno:trackerno))
    }
    
    func getGoal()
    {
        sendRequest(GetStepsGoalRequest())
    }
    func setGoal(goal:Goal) {
        sendRequest(SetGoalRequest(goal: goal))
    }

    func setAlarm(alarmhour:Int,alarmmin:Int,alarmenable:Bool) {
        sendRequest(SetAlarmRequest(hour:alarmhour,min: alarmmin,enable: alarmenable))
    }
    
    func SetNortification(settingArray:[NotificationSetting]) {
        AppTheme.DLog("SetNortification")
        sendRequest(SetNortificationRequest(settingArray: settingArray))
    }
    /**
    @ledpattern, define Led light pattern, 0 means off all led, 0xFFFFFF means light on all led( include color and white)
    0x7FF means light on all white led (bit0~bit10), 0x3F0000 means light on all color led (bit16~bit21)
    other value, light on the related led
    @motorOnOff, vibrator true or flase
    */
    func SetLedOnOffandVibrator(ledpattern:UInt32,  motorOnOff:Bool) {
        sendRequest(LedLightOnOffNevoRequest(ledpattern: ledpattern, motorOnOff: motorOnOff))
    }
    func ReadBatteryLevel() {
        sendRequest(ReadBatteryLevelNevoRequest())
    }
    //end functions by UI
    
    func sendRequest(r:Request) {
        if(isConnected()){
            SyncQueue.sharedInstance.post( { (Void) -> (Void) in

                self.mConnectionController.sendRequest(r)
            
            } )
        }else {
            //tell caller
            for (index, delegate) in enumerate(mDelegates) {
                delegate.connectionStateChanged(false)
            }
        }
    }
    
    func packetReceived(packet:RawPacket) {
 
        mPacketsbuffer.append(packet.getRawData())
        if(packet.isLastPacket())
        {
            var packet:NevoPacket = NevoPacket(packets:mPacketsbuffer)
            if(!packet.isVaildPacket())
            {
                AppTheme.DLog("Invaild packet............\(packet.getPackets().count)")
                mPacketsbuffer = []
                return;
            }
            
            for (index, delegate) in enumerate(mDelegates) {
                delegate.packetReceived(packet)
            }
            
            //We just received a full response, so we can safely send the next request
            SyncQueue.sharedInstance.next()
            
            if(packet.getHeader() == SetRTCRequest.HEADER())
            {
                //setp2:start set user profile
                self.SetProfile()
            }
            if(packet.getHeader() == SetProfileRequest.HEADER())
            {
                //step3:
                self.WriteSetting()
            }
            
            if(packet.getHeader() == WriteSettingRequest.HEADER())
            {
                //step4:
                self.SetCardio()
            }
            
            if(packet.getHeader() == SetCardioRequest.HEADER())
            {
                //step5: sync the notification setting, if remove nevo's battery, the nevo notification reset, so here need sync it
                var mNotificationSettingArray:[NotificationSetting] = []
                
                var callsetting:NotificationSetting = NotificationSetting(type: NotificationType.CALL, color: 0)
                var color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(callsetting.getType().rawValue))
                var states = EnterNotificationController.getMotorOnOff(callsetting.getType().rawValue)
                callsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(callsetting)
                
                var smssetting:NotificationSetting = NotificationSetting(type: NotificationType.SMS, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(smssetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(smssetting.getType().rawValue)
                smssetting.updateValue(color, states: states)
                mNotificationSettingArray.append(smssetting)
                
                var emailsetting:NotificationSetting = NotificationSetting(type: NotificationType.EMAIL, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(emailsetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(emailsetting.getType().rawValue)
                emailsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(emailsetting)
                
                var fbsetting:NotificationSetting = NotificationSetting(type: NotificationType.FACEBOOK, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(fbsetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(fbsetting.getType().rawValue)
                fbsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(fbsetting)
                
                var calsetting:NotificationSetting = NotificationSetting(type: NotificationType.CALENDAR, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(calsetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(calsetting.getType().rawValue)
                calsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(calsetting)
                
                var wechatchsetting:NotificationSetting = NotificationSetting(type: NotificationType.WECHAT, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(wechatchsetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(wechatchsetting.getType().rawValue)
                wechatchsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(wechatchsetting)
                //start sync notification setting on the phone side
                SetNortification(mNotificationSettingArray)
            }

            if(packet.getHeader() == SetNortificationRequest.HEADER())
            {
                //copy from AlarmClockController
                var mAlarmhour:Int = 8
                var mAlarmmin:Int = 30
                var mAlarmenable:Bool = false
                let SAVED_ALARM_HOUR_KEY = "SAVED_ALARM_HOUR_KEY"
                let SAVED_ALARM_MIN_KEY = "SAVED_ALARM_MIN_KEY"
                let SAVED_ALARM_ENABLED_KEY = "SAVED_ALARM_ENABLED_KEY"
                 
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
                
                setAlarm(mAlarmhour, alarmmin: mAlarmmin, alarmenable: mAlarmenable)
            }
            
            if(packet.getHeader() == SetAlarmRequest.HEADER())
            {
                //start sync data
                self.syncActivityData()
            }
            
            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER())
            {
                var thispacket = packet.copy() as DailyTrackerInfoNevoPacket
                currentDay = 0
                savedDailyHistory = thispacket.getDailyTrackerInfo()
                AppTheme.DLog("History Total Days:\(savedDailyHistory.count),Today is \(GmtNSDate2LocaleNSDate(NSDate()))")
                if savedDailyHistory.count > 0
                {
                    self.getDailyTracker(currentDay)
                }
            }
            if(packet.getHeader() == ReadDailyTracker.HEADER())
            {
                var thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket
                
                savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Steps:\(savedDailyHistory[Int(currentDay)].TotalSteps)")
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly Steps:\(savedDailyHistory[Int(currentDay)].HourlySteps)")
                
                //save to health kit
                var hk = NevoHKImpl()
                hk.requestPermission()
                
                
                let now:NSDate = NSDate()
                let cal:NSCalendar = NSCalendar.currentCalendar()
                let unitFlags:NSCalendarUnit = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
                let dd:NSDateComponents = cal.components(unitFlags, fromDate: now)
                
                let dd2:NSDateComponents = cal.components(unitFlags, fromDate: savedDailyHistory[Int(currentDay)].Date)
                
                // disable write every day 's total steps, only write every day's hourly steps
                //not save today 's daily steps, due to today not end.
                /*
                if !(dd.year == dd2.year && dd.month == dd2.month && dd.day == dd2.day)
                     && savedDailyHistory[Int(currentDay)].TotalSteps > 0
                {
                hk.writeDataPoint(DailySteps(numberOfSteps: savedDailyHistory[Int(currentDay)].TotalSteps,date: savedDailyHistory[Int(currentDay)].Date), resultHandler: { (result, error) -> Void in
                    if (result != true) {
                       NSLog("Saved Daily steps error:\(error)")
                    }
                    else
                    {
                        NSLog("Saved Daily steps OK")
                    }
                })
                }
                */
                
                for (var i:Int = 0; i<savedDailyHistory[Int(currentDay)].HourlySteps.count; i++)
                {
                    //only save vaild hourly steps for every day, include today.
                    //exclude update current hour step, due to current hour not end
                    //for example: at 10:20~ 10:25AM, walk 100 steps, 10:50~10:59, walk 300 steps
                    //user can't see the 10:00AM record data at 10:XX clock
                    //user can see 10:00AM data when 11:20 do a big sync, the value should be 400 steps
                    //that is to say, user can't see current hour 's step in healthkit, he can see it by waiting one hour
                    
                    if savedDailyHistory[Int(currentDay)].HourlySteps[i] > 0 &&
                    !(i == dd.hour && dd.year == dd2.year && dd.month == dd2.month && dd.day == dd2.day)
                    {
                        hk.writeDataPoint(HourlySteps(numberOfSteps: savedDailyHistory[Int(currentDay)].HourlySteps[i],date: savedDailyHistory[Int(currentDay)].Date,hour:i,update: false), resultHandler: { (result, error) -> Void in
                        if (result != true) {
                            AppTheme.DLog("Save Hourly steps error\(i),\(error)")
                        }
                        else
                        {
                            AppTheme.DLog("Save Hourly steps OK")
                        }
                    })
                    }
                }

                //end save
                currentDay++
                if(currentDay < UInt8(savedDailyHistory.count))
                {
                    self.getDailyTracker(currentDay)
                }
                else
                {
                   currentDay = 0
                   self.syncFinished()
                }
            }

            if(packet.getHeader() == GetStepsGoalRequest.HEADER())
            {
                var thispacket = packet.copy() as DailyStepsNevoPacket
          
                //refresh current hourly steps changing in the healthkit
                /*
                currentDay = 0
                savedDailyHistory = []
                savedDailyHistory.append(NevoPacket.DailyHistory(TotalSteps: 0, HourlySteps: [], Date:NSDate()))
                self.getDailyTracker(currentDay)
                */
                
                /*
                //remove real time count steps to healthkit
                var hk = NevoHKImpl()
                hk.requestPermission()
                
                hk.writeDataPoint(RealTimeCountSteps(numberOfSteps: packet.getDailySteps() - RealTimeCountSteps.getLastNumberOfSteps(),date: RealTimeCountSteps.getLastDate()), resultHandler: { (result, error) -> Void in
                    if (result != true) {
                         NSLog("\(error)")
                    }
                    RealTimeCountSteps.setLastNumberOfSteps(packet.getDailySteps())
                    RealTimeCountSteps.setLastDate(NSDate())
                })
                */
                
            }
            
            mPacketsbuffer = []
        }
    }
    
    func connectionStateChanged(isConnected : Bool) {
        //send local notification
        if isConnected {
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)
        }else {
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
        }
        
        for (index, delegate) in enumerate(mDelegates) {
            delegate.connectionStateChanged(isConnected)
        }
        
        if( isConnected )
        {
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.mPacketsbuffer = []
                self.setRTC()
            })
            
        }
        else
        {
            SyncQueue.sharedInstance.clear()
            mPacketsbuffer = []
        }
    }
    
    /**
    See UIAlertViewDelegate
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        if(buttonIndex==1){
          //GOTO OTA SCREEN
            for (index, delegate) in enumerate(mDelegates) {
                if delegate is HomeController
                {
                    (delegate as! HomeController).gotoOTAScreen()
                    break
                }
            }
        }
    }
    
    /**
    return true, if it is not the first run
    return false ,if it is running the tutorial screen
    */
    func hasLoadHomeController() ->Bool
    {
        for (index, delegate) in enumerate(mDelegates) {
            if delegate is HomeController
            {
                return true
            }
        }
        return false
    }

    /**
    See ConnectionControllerDelegate
    */
    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString)
    {
        var mcuver = GET_SOFTWARE_VERSION()
        var blever = GET_FIRMWARE_VERSION()
        
        AppTheme.DLog("Build in software version: \(mcuver), firmware version: \(blever)")
 
        if ((whichfirmware == DfuFirmwareTypes.SOFTDEVICE  && (version as String).toInt() < mcuver)
          || (whichfirmware == DfuFirmwareTypes.APPLICATION  && (version as String).toInt() < blever))
            
        {
            //for tutorial screen, don't popup update dialog
            if !mAlertUpdateFW  && hasLoadHomeController()
            {
            mAlertUpdateFW = true
                
            var alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: NSLocalizedString("FirmwareAlertMessage", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
            alert.addButtonWithTitle(NSLocalizedString("Enter", comment: ""))
            alert.show()
            }
        }
    }
    /**
    See ConnectionController protocol
    */
    func  getFirmwareVersion() -> NSString
    {
        return isConnected() ? self.mConnectionController.getFirmwareVersion() : NSString()
    }
    
    /**
    See ConnectionController protocol
    */
    func  getSoftwareVersion() -> NSString
    {
        return isConnected() ? self.mConnectionController.getSoftwareVersion() : NSString()
    }
    
    func connect() {
        self.mConnectionController.connect()
    }
    
    func isConnected() -> Bool{
        return mConnectionController.isConnected()

    }
    
}


protocol SyncControllerDelegate {

    /**
    Called when a packet is received from the device
    */
    func packetReceived(NevoPacket)
    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
}