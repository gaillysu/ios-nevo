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

class SyncController: ConnectionControllerDelegate {
    
    //Let's sync every days
    let SYNC_INTERVAL:NSTimeInterval = 1*60*60 //unit is second in iOS
    
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    
    private var mDelegates:[SyncControllerDelegate]
 
    private let mConnectionController : ConnectionController

    private var mPacketsbuffer:[NSData]
    
    private let mHealthKitStore:HKHealthStore = HKHealthStore()
    
    private var savedDailyHistory:[NevoPacket.DailyHistory]=[]
    private var currentDay:UInt8 = 0
    
    /**
    A classic singelton pattern
    */
    class var sharedInstance : SyncController {
        struct Singleton {
            static let instance = SyncController()
        }
        return Singleton.instance
    }

    
  private init() {
        mDelegates = []
        mPacketsbuffer = []
        mConnectionController = ConnectionControllerImpl.sharedInstance
        mConnectionController.setDelegate(self)
    
    }
    
    func startConnect(forceScan:Bool,delegate:SyncControllerDelegate)
    {
        NSLog("New delegate : \(delegate)")
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
            NSLog("*** Sync started ! ***")
            self.getDailyTrackerInfo()
        }

    }
    
    /**
    When the sync process is finished, le't refresh the date of sync
    */
    func syncFinished() {
        
        NSLog("*** Sync finished ***")
        
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

    func SetNortification(type:NSArray) {
        sendRequest(SetNortificationRequest(typeArray:type))
    }
    
    func SetNortification(settingArray:[NotificationSetting]) {
        NSLog("SetNortification")
        sendRequest(SetNortificationRequest(settingArray: settingArray))
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
                //start sync data
                savedDailyHistory = []
                self.syncActivityData()
            }
            if(packet.getHeader() == ReadDailyTrackerInfo.HEADER())
            {
                var thispacket = packet.copy() as DailyTrackerInfoNevoPacket
                currentDay = 0
                savedDailyHistory = thispacket.getDailyTrackerInfo()
                NSLog("History Total Days:\(savedDailyHistory.count),Today is \(GmtNSDate2LocaleNSDate(NSDate()))")
                self.getDailyTracker(currentDay)
            }
            if(packet.getHeader() == ReadDailyTracker.HEADER())
            {
                var thispacket:DailyTrackerNevoPacket = packet.copy() as DailyTrackerNevoPacket
                
                savedDailyHistory[Int(currentDay)].TotalSteps = thispacket.getDailySteps()
                savedDailyHistory[Int(currentDay)].HourlySteps = thispacket.getHourlySteps()
                
                NSLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Daily Steps:\(savedDailyHistory[Int(currentDay)].TotalSteps)")
                
                NSLog("Day:\(GmtNSDate2LocaleNSDate(savedDailyHistory[Int(currentDay)].Date)), Hourly Steps:\(savedDailyHistory[Int(currentDay)].HourlySteps)")
                
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
                    if savedDailyHistory[Int(currentDay)].HourlySteps[i] > 0
                    {
                    //only today 's current hourly can do update!!!, due to current hourly not end
                    hk.writeDataPoint(HourlySteps(numberOfSteps: savedDailyHistory[Int(currentDay)].HourlySteps[i],date: savedDailyHistory[Int(currentDay)].Date,hour:i,update:dd.hour == i && dd.year == dd2.year && dd.month == dd2.month && dd.day == dd2.day), resultHandler: { (result, error) -> Void in
                        if (result != true) {
                            NSLog("Save Hourly steps error\(i),\(error)")
                        }
                        else
                        {
                            NSLog("Save Hourly steps OK")
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
          
                //record current hourly steps changing in the healthkit
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
        
        for (index, delegate) in enumerate(mDelegates) {
            delegate.connectionStateChanged(isConnected)
        }
        
        if( isConnected )
        {
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.setRTC()
            })
            
        }
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