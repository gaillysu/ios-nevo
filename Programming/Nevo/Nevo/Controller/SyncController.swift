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
    let SYNC_INTERVAL:NSTimeInterval = 24*60*60*1000
    
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    
    private var mDelegate:SyncControllerDelegate
 
    private let mConnectionController : ConnectionController

    private var mPacketsbuffer:[NSData]
    
    private let mHealthKitStore:HKHealthStore = HKHealthStore()
    
    init(controller : UIViewController,forceScan :Bool, delegate:SyncControllerDelegate) {

        mDelegate = delegate

        mPacketsbuffer = []
        mConnectionController = ConnectionControllerImpl.sharedInstance
        
        mConnectionController.addDelegate(self)
        
        if forceScan
        {
            mConnectionController.forgetSavedAddress()
        }
        mConnectionController.connect()
        syncActivityData()
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
            
            //TODO by Hugo to Gailly
            //Sync process here
            syncStep1()
        
        }
    }
    
    func syncStep1() {
        //TODO by Hugo to Gailly
        //Real sync
        syncStep2()
    }
    
    func syncStep2() {
        //TODO by Hugo to Gailly
        //Real sync

        
        //When the sync is finished, let's simply call the sync Finished function
        syncFinished()
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
        mConnectionController.sendRequest(SetRTCRequest())
    }
    
    func SetProfile() {
        mConnectionController.sendRequest(SetProfileRequest())
    }
    func SetCardio() {
        mConnectionController.sendRequest(SetCardioRequest())
    }
    
    func WriteSetting() {
        mConnectionController.sendRequest(WriteSettingRequest())
    }
    //end functions for connected to Nevo
    
    //below functions by UI
    func setGoal(goal:Goal) {
        mConnectionController.sendRequest(SetGoalRequest(goal: goal))
    }
    
    func setAlarm(alarmhour:Int,alarmmin:Int,alarmenable:Bool) {
        mConnectionController.sendRequest(SetAlarmRequest(hour:alarmhour,min: alarmmin,enable: alarmenable))
    }

    func SetNortification() {
        mConnectionController.sendRequest(SetNortificationRequest())
    }
    //end functions by UI
    
    func packetReceived(packet:RawPacket) {
        
        mPacketsbuffer.append(packet.getRawData())
        if(NSData2Bytes(packet.getRawData())[0] == 0xFF)
        {
            if(NSData2Bytes(packet.getRawData())[1] == 0x01)
            {
                self.SetProfile()
            }
            if(NSData2Bytes(packet.getRawData())[1] == 0x20)
            {
                self.WriteSetting()
            }
            
            if(NSData2Bytes(packet.getRawData())[1] == 0x21)
            {
                self.SetCardio()
            }
            
            mPacketsbuffer = []
        }
    }
    
    func connectionStateChanged(isConnected : Bool) {
        
        NSLog("State changed : \(isConnected) To delegate  : \(mDelegate)")
        
        mDelegate.connectionStateChanged(isConnected)
        
        if( isConnected )
        {
         //  NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("setRTC"), userInfo: nil, repeats: false)
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
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
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
}