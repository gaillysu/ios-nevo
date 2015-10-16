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
    let SYNC_INTERVAL:NSTimeInterval = 0*30*60 //unit is second in iOS, every 30min, do sync
    
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    
    private var mDelegates:[SyncControllerDelegate]
 
    private let mConnectionController : ConnectionController

    private var mPacketsbuffer:[NSData]
    
    private let mHealthKitStore:HKHealthStore = HKHealthStore()
    
    private var savedDailyHistory:[NevoPacket.DailyHistory]=[]
    private var currentDay:UInt8 = 0
    private var mAlertUpdateFW = false
    private var timer:NSTimer = NSTimer()

    private var todaySleepData:NSMutableArray = NSMutableArray(capacity: 2)
    
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

    func setAlarm(alarm:[Alarm]) {
        sendRequest(SetAlarmRequest(alarm:alarm))
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
            for delegate in mDelegates {
                delegate.connectionStateChanged(false)
            }
        }
    }

    /**
    Format from the alarm data

    :param: alarmArray Alarm dictionary

    :returns: Returns the Alarm
    */
    func getLoclAlarm(alarmArray:NSDictionary)->Alarm{
        let SAVED_ALARM_HOUR_KEY = "SAVED_ALARM_HOUR_KEY"
        let SAVED_ALARM_MIN_KEY = "SAVED_ALARM_MIN_KEY"
        let SAVED_ALARM_ENABLED_KEY = "SAVED_ALARM_ENABLED_KEY"
        let SAVED_ALARM_INDEX_KEY = "SAVED_ALARM_INDEX_KEY"

        let alarm_index:Int = (alarmArray.objectForKey(SAVED_ALARM_INDEX_KEY) as! NSNumber).integerValue
        let alarm_hour:Int = (alarmArray.objectForKey(SAVED_ALARM_HOUR_KEY) as! NSNumber).integerValue
        let alarm_min:Int = (alarmArray.objectForKey(SAVED_ALARM_MIN_KEY) as! NSNumber).integerValue
        let alarm_enabled:Bool = (alarmArray.objectForKey(SAVED_ALARM_ENABLED_KEY) as! NSNumber).boolValue
        let alarm:Alarm = Alarm(index: alarm_index, hour: alarm_hour, minute: alarm_min, enable: alarm_enabled)
        return alarm
    }

    func packetReceived(packet:RawPacket) {
 
        mPacketsbuffer.append(packet.getRawData())
        if(packet.isLastPacket())
        {
            let packet:NevoPacket = NevoPacket(packets:mPacketsbuffer)
            if(!packet.isVaildPacket())
            {
                AppTheme.DLog("Invaild packet............\(packet.getPackets().count)")
                mPacketsbuffer = []
                return;
            }
            
            for delegate in mDelegates {
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
                
                let callsetting:NotificationSetting = NotificationSetting(type: NotificationType.CALL, color: 0)
                var color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(callsetting.getType().rawValue))
                var states = EnterNotificationController.getMotorOnOff(callsetting.getType().rawValue)
                callsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(callsetting)
                
                let smssetting:NotificationSetting = NotificationSetting(type: NotificationType.SMS, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(smssetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(smssetting.getType().rawValue)
                smssetting.updateValue(color, states: states)
                mNotificationSettingArray.append(smssetting)
                
                let emailsetting:NotificationSetting = NotificationSetting(type: NotificationType.EMAIL, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(emailsetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(emailsetting.getType().rawValue)
                emailsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(emailsetting)
                
                let fbsetting:NotificationSetting = NotificationSetting(type: NotificationType.FACEBOOK, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(fbsetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(fbsetting.getType().rawValue)
                fbsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(fbsetting)
                
                let calsetting:NotificationSetting = NotificationSetting(type: NotificationType.CALENDAR, color: 0)
                color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(calsetting.getType().rawValue))
                states = EnterNotificationController.getMotorOnOff(calsetting.getType().rawValue)
                calsetting.updateValue(color, states: states)
                mNotificationSettingArray.append(calsetting)
                
                let wechatchsetting:NotificationSetting = NotificationSetting(type: NotificationType.WECHAT, color: 0)
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
                let mAlarmhour:Int = 8
                let mAlarmmin:Int = 30
                let mAlarmenable:Bool = false

                var alarm:[Alarm] = []

                let SAVED_ALARM_ARRAY0 = "SAVED_ALARM_ARRAY0"
                let SAVED_ALARM_ARRAY1 = "SAVED_ALARM_ARRAY1"
                let SAVED_ALARM_ARRAY2 = "SAVED_ALARM_ARRAY2"

                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                //If we have any previously saved hour, min and/or enabled/ disabled, we'll use those variables first
                if let alarmArray1 = userDefaults.objectForKey(SAVED_ALARM_ARRAY0) as? NSDictionary {
                    alarm.append(getLoclAlarm(alarmArray1))
                }else{
                    alarm.append(Alarm(index: 0,hour: mAlarmhour,minute: mAlarmmin,enable: mAlarmenable))
                }

                if let alarmArray2 = userDefaults.objectForKey(SAVED_ALARM_ARRAY1) as? NSDictionary {
                    alarm.append(getLoclAlarm(alarmArray2))
                }else{
                    alarm.append(Alarm(index: 1,hour: mAlarmhour,minute: mAlarmmin,enable: mAlarmenable))
                }

                if let alarmArray3 = userDefaults.objectForKey(SAVED_ALARM_ARRAY2) as? NSDictionary {
                    alarm.append(getLoclAlarm(alarmArray3))
                }else{
                    alarm.append(Alarm(index: 2,hour: mAlarmhour,minute: mAlarmmin,enable: mAlarmenable))
                }

                setAlarm(alarm)
            }
            
            if(packet.getHeader() == SetAlarmRequest.HEADER())
            {
                //start sync data
                self.syncActivityData()
            }
            
            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER())
            {
                let thispacket = packet.copy() as DailyTrackerInfoNevoPacket
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
                let thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket
                
                savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Steps:\(savedDailyHistory[Int(currentDay)].TotalSteps)")
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly Steps:\(savedDailyHistory[Int(currentDay)].HourlySteps)")
                
                savedDailyHistory[Int(currentDay)].TotalSleepTime = thispacket.getDailySleepTime()
                savedDailyHistory[Int(currentDay)].HourlySleepTime = thispacket.getHourlySleepTime()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Sleep time:\(savedDailyHistory[Int(currentDay)].TotalSleepTime)")
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly Sleep time:\(savedDailyHistory[Int(currentDay)].HourlySleepTime)")
                
                savedDailyHistory[Int(currentDay)].TotalWakeTime = thispacket.getDailyWakeTime()
                savedDailyHistory[Int(currentDay)].HourlyWakeTime = thispacket.getHourlyWakeTime()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Wake time:\(savedDailyHistory[Int(currentDay)].TotalWakeTime)")
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly Wake time:\(savedDailyHistory[Int(currentDay)].HourlyWakeTime)")

                savedDailyHistory[Int(currentDay)].TotalLightTime = thispacket.getDailyLightTime()
                savedDailyHistory[Int(currentDay)].HourlyLightTime = thispacket.getHourlyLightTime()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily light time:\(savedDailyHistory[Int(currentDay)].TotalLightTime)")
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly light time:\(savedDailyHistory[Int(currentDay)].HourlyLightTime)")
                
                savedDailyHistory[Int(currentDay)].TotalDeepTime = thispacket.getDailyDeepTime()
                savedDailyHistory[Int(currentDay)].HourlyDeepTime = thispacket.getHourlyDeepTime()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily deep time:\(savedDailyHistory[Int(currentDay)].TotalDeepTime)")
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly deep time:\(savedDailyHistory[Int(currentDay)].HourlyDeepTime)")
                
                savedDailyHistory[Int(currentDay)].TotalDist = thispacket.getDailyDist()
                savedDailyHistory[Int(currentDay)].TotalCalories = thispacket.getDailyCalories()
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Total Disc (m):\(savedDailyHistory[Int(currentDay)].TotalDist)")
                
                AppTheme.DLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Total Calories (kcal):\(savedDailyHistory[Int(currentDay)].TotalCalories)")

                //save to health kit
                let hk = NevoHKImpl()
                hk.requestPermission()
                
                
                let now:NSDate = NSDate()
                let cal:NSCalendar = NSCalendar.currentCalendar()
                let dd:NSDateComponents = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: now)
                
                let dd2:NSDateComponents = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: savedDailyHistory[Int(currentDay)].Date)
                
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
                            }else{
                                AppTheme.DLog("Save Hourly steps OK")
                            }
                        })
                    }
                }
                
                //save sleep data for every hour.
                //save format: first write wake, then write sleep(light&deep)
                //example 1: 00:00~ 00:59, wake 10, light sleep 40, deep sleep 10
                //wake start at 00:00, wake end at 00:10
                //sleep start at:00:10 sleep end at:00:59
                
                //example 2: start sleep at 23:12, wake 15, sleep 33,total 48
                //wake start at:23:12 ,end at 23:27
                //sleep start at23:27, end at 23:59
             
                for (var i:Int = 0; i<savedDailyHistory[Int(currentDay)].HourlySleepTime.count; i++)
                {
                    let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
                    var startDateWake:NSDate?
                    var endDateWake:NSDate?
                    
                    var startDateSleep:NSDate?
                    var endDateSleep:NSDate?

                    if savedDailyHistory[Int(currentDay)].HourlySleepTime[i] > 0
                    {
                        if(i<=12)
                        {
                            startDateWake = cal.dateBySettingHour(i, minute: 0 , second: 0, ofDate: savedDailyHistory[Int(currentDay)].Date, options: NSCalendarOptions())!
                        }
                        else
                        {
                        startDateWake = cal.dateBySettingHour(i, minute: 60 - savedDailyHistory[Int(currentDay)].HourlySleepTime[i] , second: 0, ofDate: savedDailyHistory[Int(currentDay)].Date, options: NSCalendarOptions())!
                     
                        }
                        
                        if savedDailyHistory[Int(currentDay)].HourlyWakeTime[i] == 60
                        {
                            endDateWake = startDateWake!.dateByAddingTimeInterval( NSTimeInterval((savedDailyHistory[Int(currentDay)].HourlyWakeTime[i] - 1 )*60))
                        }
                        else
                        {
                            endDateWake = startDateWake!.dateByAddingTimeInterval( NSTimeInterval(savedDailyHistory[Int(currentDay)].HourlyWakeTime[i]*60))
                        }
                    
                        AppTheme.DLog("wake startDate:\(GmtNSDate2LocaleNSDate(startDateWake!))")
                        AppTheme.DLog("wake endDate:\(GmtNSDate2LocaleNSDate(endDateWake!))")
                        
                        //save wake time before every hour
                        if savedDailyHistory[Int(currentDay)].HourlyWakeTime[i] > 0{

                        }
                        
                        //save sleep time after wake time, include light/deep sleep time
                        if(savedDailyHistory[Int(currentDay)].HourlySleepTime[i] - savedDailyHistory[Int(currentDay)].HourlyWakeTime[i] > 0){
                            startDateSleep =  endDateWake
                            if savedDailyHistory[Int(currentDay)].HourlySleepTime[i] - savedDailyHistory[Int(currentDay)].HourlyWakeTime[i] == 60
                            {
                                endDateSleep = startDateSleep!.dateByAddingTimeInterval( NSTimeInterval((savedDailyHistory[Int(currentDay)].HourlySleepTime[i] - savedDailyHistory[Int(currentDay)].HourlyWakeTime[i] - 1)*60))
                            }
                            else
                            {
                                endDateSleep = startDateSleep!.dateByAddingTimeInterval( NSTimeInterval((savedDailyHistory[Int(currentDay)].HourlySleepTime[i] - savedDailyHistory[Int(currentDay)].HourlyWakeTime[i])*60))
                            }

                            AppTheme.DLog("sleep startDate:\(GmtNSDate2LocaleNSDate(startDateSleep!))")
                            AppTheme.DLog("sleep endDate:\(GmtNSDate2LocaleNSDate(endDateSleep!))")

                        }
                    }
                }

                let today:NSDate  = NSDate()
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                let currentDateStr:NSString = dateFormatter.stringFromDate(today)

                if(currentDateStr.integerValue == thispacket.getDateTimer()){
                    let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                    if(todaySleepData.count==0){
                        todaySleepData.addObject(dataArray)
                    }else{
                        todaySleepData.insertObject(dataArray, atIndex: 1)
                    }
                }

                if(currentDateStr.integerValue-1 == thispacket.getDateTimer()){
                    let dataArray:[[Int]] = [thispacket.getHourlySleepTime(),thispacket.getHourlyWakeTime(),thispacket.getHourlyLightTime(),thispacket.getHourlyDeepTime()]
                    if(todaySleepData.count==0){
                        todaySleepData.addObject(dataArray)
                    }else{
                        todaySleepData.insertObject(dataArray, atIndex: 0)
                    }
                }

                var daysleepSave:DaySleepSaveModel = DaySleepSaveModel()
                daysleepSave.steps = thispacket.getDailySteps()
                daysleepSave.created = thispacket.getDateTimer()
                daysleepSave.HourlySleepTime = AppTheme.toJSONString(thispacket.getHourlySleepTime())
                daysleepSave.HourlyWakeTime = AppTheme.toJSONString(thispacket.getHourlyWakeTime())
                daysleepSave.HourlyLightTime = AppTheme.toJSONString(thispacket.getHourlyLightTime())
                daysleepSave.HourlyDeepTime = AppTheme.toJSONString(thispacket.getHourlyDeepTime())

                AppTheme.DLog("---------------\(thispacket.getDateTimer())")

                //Query the database is this record
                let quyerModel = DaySleepSaveModel.findFirstByCriteria("WHERE created = \(thispacket.getDateTimer())")
                if(quyerModel != nil){
                    AppTheme.DLog("Data that has been saved····")
                    daysleepSave.update()
                    //Analyzing whether the same data database is not updated if they are equal, otherwise the update the database
                }else{
                    //Don't have any database if the sleep time is zero
                    if(thispacket.getDailySleepTime() != 0){
                        let isSave:Bool = daysleepSave.save()  //If not, save database
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
                    for delegate in mDelegates {
                        delegate.syncFinished()
                    }
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

            //find Phone
           if (TestMode.shareInstance(packet.getPackets()).isTestModel()){
                AppTheme.playSound()
            }
            
            mPacketsbuffer = []
        }
    }
    
    func connectionStateChanged(isConnected : Bool) {
        //send local notification
        if isConnected {
            if(timer.valid){
                timer.invalidate()
            }
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)
        }else {
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
           timer = NSTimer.scheduledTimerWithTimeInterval(3.5, target: self, selector: Selector("BLE_LOST_TITLE_ACTION:"), userInfo: nil, repeats: false)

        }
        
        for delegate in mDelegates {
            delegate.connectionStateChanged(isConnected)
        }
        
        if( isConnected )
        {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
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

    func BLE_LOST_TITLE_ACTION(timer:NSTimer){
        let alert :UIAlertView = UIAlertView(title: NSLocalizedString("BLE_LOST_TITLE", comment: ""), message: NSLocalizedString("BLE_CONNECTION_LOST", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
        alert.show()
    }
    
    /**
    See UIAlertViewDelegate
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        if(buttonIndex==1){
          //GOTO OTA SCREEN
            for delegate in mDelegates {
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
        for delegate in mDelegates {
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
        let mcuver = GET_SOFTWARE_VERSION()
        let blever = GET_FIRMWARE_VERSION()
        
        AppTheme.DLog("Build in software version: \(mcuver), firmware version: \(blever)")
 
        if ((whichfirmware == DfuFirmwareTypes.SOFTDEVICE  && version.integerValue < mcuver)
          || (whichfirmware == DfuFirmwareTypes.APPLICATION  && version.integerValue < blever))
            
        {
            //for tutorial screen, don't popup update dialog
            if !mAlertUpdateFW  && hasLoadHomeController()
            {
            mAlertUpdateFW = true

            let alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: NSLocalizedString("FirmwareAlertMessage", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
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

    /**
    *  See ConnectionController protocol
    *  Receiving the current device signal strength value
    */
    func receivedRSSIValue(number:NSNumber){
        for delegate in mDelegates {
            if delegate is MyNevoController{
                delegate.receivedRSSIValue(number)
            }
        }
    }

    func removeMyNevoDelegate(){
        for(var i:Int = 0; i < mDelegates.count; i++){
            if mDelegates[i] is MyNevoController{
                mDelegates.removeAtIndex(i)
            }
        }
    }

    func connect() {
        self.mConnectionController.connect()
    }
    
    func isConnected() -> Bool{
        return mConnectionController.isConnected()

    }

    func GET_TodaySleepData()->NSArray{
        return todaySleepData;
    }
    
}


protocol SyncControllerDelegate {

    /**
    Called when a packet is received from the device
    */
    func packetReceived(packet: NevoPacket)
    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
    /**
    *  Receiving the current device signal strength value
    */
    func receivedRSSIValue(number:NSNumber)
    /**
    *  Data synchronization is complete callback
    */
    func syncFinished()
}