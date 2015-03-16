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
    //end functions by UI
    
    func sendRequest(r:Request) {
        SyncQueue.sharedInstance.post( { (Void) -> (Void) in

                self.mConnectionController.sendRequest(r)
            
            } )
    }
    
    func packetReceived(packet:RawPacket) {
        
        for (index, delegate) in enumerate(mDelegates) {
            delegate.packetReceived(packet)
        }

        mPacketsbuffer.append(packet.getRawData())
        if(NSData2Bytes(packet.getRawData())[0] == 0xFF)
        {
            //We just received a full response, so we can safely send the next request
            SyncQueue.sharedInstance.next()
            
            if(NSData2Bytes(packet.getRawData())[1] == 0x01)
            {
                //setp2:start set user profile
                self.SetProfile()
            }
            if(NSData2Bytes(packet.getRawData())[1] == 0x20)
            {
                //step3:cmd 0x21
                self.WriteSetting()
            }
            
            if(NSData2Bytes(packet.getRawData())[1] == 0x21)
            {
                //step4:cmd 0x23
                self.SetCardio()
            }
            if(NSData2Bytes(packet.getRawData())[1] == 0x23)
            {
                //start sync data
                savedDailyHistory = []
                self.syncActivityData()
            }
            if(NSData2Bytes(packet.getRawData())[1] == 0x24)
            {
                var packet:NevoPacket = NevoPacket(packets:mPacketsbuffer)
                currentDay = 0
                savedDailyHistory = packet.getDailyTrackerInfo()
                NSLog("History Total Days:\(savedDailyHistory.count)")
                self.getDailyTracker(currentDay)
            }
            if(NSData2Bytes(packet.getRawData())[1] == 0x25)
            {
                var packet:NevoPacket = NevoPacket(packets:mPacketsbuffer)
                
                savedDailyHistory[Int(currentDay)].TotalSteps = packet.getDailySteps()
                savedDailyHistory[Int(currentDay)].HourlySteps = packet.getHourlySteps()
                
                NSLog("Day:\(savedDailyHistory[Int(currentDay)].Date), Daily Steps:\(savedDailyHistory[Int(currentDay)].TotalSteps)")
                
                NSLog("Day:\(savedDailyHistory[Int(currentDay)].Date), Hourly Steps:\(savedDailyHistory[Int(currentDay)].HourlySteps)")
                
                //save to health kit
                 var hk = NevoHKImpl()
                hk.requestPermission()
                
                hk.writeDataPoint(DailySteps(numberOfSteps: savedDailyHistory[Int(currentDay)].TotalSteps,date: savedDailyHistory[Int(currentDay)].Date), resultHandler: { (result, error) -> Void in
                    if (result != true) {
                    NSLog("Saved Daily steps error:\(error),Day:\(self.savedDailyHistory[Int(self.currentDay)].Date), Daily Steps:\(self.savedDailyHistory[Int(self.currentDay)].TotalSteps)")
                    }
                })
                
                for (var i:Int = 0; i<24; i++)
                {
                    hk.writeDataPoint(HourlySteps(numberOfSteps: savedDailyHistory[Int(currentDay)].TotalSteps,date: savedDailyHistory[Int(currentDay)].Date,hour:i), resultHandler: { (result, error) -> Void in
                        if (result != true) {
                            NSLog("Save Hourly steps error\(i),\(error)")
                        }
                    })
                }

                //end save
                currentDay++
                if(currentDay < UInt8(savedDailyHistory.count))
                {
                    self.getDailyTracker(currentDay)
                }
                else
                {
                   self.syncFinished()
                }
            }
            

            if(NSData2Bytes(packet.getRawData())[1] == 0x26)
            {
                //write the daily steps to healthkit
                //Data format: 0x00 ,0x26, daily steps (4B,LSB mode), goal steps (4B,LSB mode)
                
                var dailySteps:Int = Int(NSData2Bytes(mPacketsbuffer[0])[2] )
                dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[3] )<<8
                dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[4] )<<16
                dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[5] )<<24
                
                NSLog("get Daily Steps is: \(dailySteps), now write it to healthkit")
                /* //remove real time count steps
                var hk = NevoHKImpl()
                hk.requestPermission()
                
                hk.writeDataPoint(RealTimeCountSteps(numberOfSteps: dailySteps - RealTimeCountSteps.getLastNumberOfSteps(),date: RealTimeCountSteps.getLastDate()), resultHandler: { (result, error) -> Void in
                    if (result != true) {
                         NSLog("\(error)")
                    }
                    RealTimeCountSteps.setLastNumberOfSteps(dailySteps)
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
    func packetReceived(RawPacket)
    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
}