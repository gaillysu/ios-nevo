//
//  ConnectionControllerImpl.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
See ConnectionController
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class ConnectionControllerImpl : NSObject, ConnectionController, NevoBTDelegate {
    private var mNevoBT:NevoBT?
    private var mDelegates:[ConnectionControllerDelegate]=[]

    let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
    
    /**
    This procedure explain the scan procedure
    Every X sec we will check if the peripheral is connected and retry to connect to it
    X changes depending on how long ago we scaned previously
    For example, we'll retry afetr 1 sec, then 10s, then 10s, then 10s, then 60s sec, 120s etc..
    */
    let SCAN_PROCEDURE:[Double] = [1,10,10,10,60,120,240,3600]
    
    /**
    This status is used to search in SCAN_PROCEDURE to know when is the next time we should scan
    */
    private var mScanProcedureStatus = 0
    
    /**
    This time handles the retry procedure
    */
    private var mRetryTimer:NSTimer?
    
    /**
    A classic singelton pattern
    */
    class var sharedInstance : ConnectionControllerImpl {
        struct Singleton {
            static let instance = ConnectionControllerImpl()
        }
        return Singleton.instance
    }
    
    /**
    No initialisation outside of this class, this is a singleton
    */
    private override init() {
        super.init()
        
        mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: NevoProfile())
        setOTAMode(false)
    }
    
    /**
    See ConnectionController protocol
    */
    func addDelegate(delegate:ConnectionControllerDelegate) {
        NSLog("New delegate : \(delegate)")
        
        mDelegates.append(delegate)
    }

    /**
    See ConnectionController protocol
    */
    func connect() {
        
        initRetryTimer()

        //If we're already connected, no need to reconnect
        if isConnected() {
            
            return;
        }
        
        //We're not connected, let's connect
        if hasSavedAddress() {
            
            NSLog("We have a saved address, let's connect to it directly : \(NSUserDefaults.standardUserDefaults().objectForKey(SAVED_ADDRESS_KEY))")

            mNevoBT?.connectToAddress(
                NSUUID(UUIDString:
                    NSUserDefaults.standardUserDefaults().objectForKey(SAVED_ADDRESS_KEY) as String
                    )!
            )

        } else {
            
            NSLog("We don't have a saved address, let's scan for nearby devices.")

            mNevoBT?.scanAndConnect()
        }

    }
    
    /**
    See NevoBTDelegate
    */
    func connectionStateChanged(isConnected : Bool, fromAddress : NSUUID!) {

        for (index, delegate) in enumerate(mDelegates) {
            delegate.connectionStateChanged(isConnected)
        }
        
        if (!isConnected) {
            connect()
        } else {
            //Let's save this address
            
            if let address = fromAddress?.UUIDString {
                
                let userDefaults = NSUserDefaults.standardUserDefaults();
                
                userDefaults.setObject(address,forKey:SAVED_ADDRESS_KEY)
                
                userDefaults.synchronize()
                
            }
            
        }
        
    }
    
    /**
    See ConnectionController protocol
    */
    func disconnect() {
        mNevoBT!.disconnect()
        
        mRetryTimer?.invalidate()
        
        mRetryTimer = nil
    }
    
    /**
    See ConnectionController protocol
    */
    func forgetSavedAddress() {

        let userDefaults = NSUserDefaults.standardUserDefaults();

        userDefaults.setObject("",forKey:SAVED_ADDRESS_KEY)
        
        userDefaults.synchronize()

    }
    
    /**
    See ConnectionController protocol
    */
    func isConnected() -> Bool {
        return mNevoBT!.isConnected()
    }
    
    /**
    See ConnectionController protocol
    */
    func hasSavedAddress() -> Bool {
        
        if let saved = NSUserDefaults.standardUserDefaults().objectForKey(SAVED_ADDRESS_KEY) as? String {
            return !saved.isEmpty
        }
        
        return false
    }
    
    /**
    See ConnectionController protocol
    */
    func sendRequest(request:Request) {
        if(getOTAMode() && request.getTargetProfile().CONTROL_SERVICE != NevoOTAControllerProfile().CONTROL_SERVICE) {
            
            NSLog("ERROR ! The ConnectionController is in OTA mode, impossible to send a normal nevo request !")
            
        } else if (!getOTAMode() && request.getTargetProfile().CONTROL_SERVICE != NevoProfile().CONTROL_SERVICE) {
            
            NSLog("ERROR ! The ConnectionController is NOT in OTA mode, impossible to send an OTA nevo request !")
            
        }
        mNevoBT?.sendRequest(request)
    }
    
    /**
    See NevoBTDelegate
    */
    func packetReceived(packet:RawPacket, fromAddress : NSUUID) {
        for (index, delegate) in enumerate(mDelegates) {
            delegate.packetReceived(packet)
        }
    }
    
    /**
    See ConnectionController
    */
    func setOTAMode(OTAMode:Bool) {
        
        //No need to change the mode if we are already in OTA Mode
        if getOTAMode() == OTAMode {
            return;
        }
        
        mNevoBT?.disconnect()
        
        //We don't set the profile on the NevoBT, because it could create too many issues
        //So we destroy the previous instance and recreate one
        if(OTAMode) {
            mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: NevoOTAControllerProfile())
        } else {
            mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: NevoProfile())
        }

    }
    
    private func initRetryTimer() {
        if mRetryTimer != nil {
            //If we already have initialised it, no need to continue
            return;
        }
        
        mScanProcedureStatus = 0
        
        mRetryTimer = NSTimer.scheduledTimerWithTimeInterval(SCAN_PROCEDURE[mScanProcedureStatus], target: self, selector:Selector("retryTimer"), userInfo: nil, repeats: false)
        
    }
    
    func retryTimer() {
        
        //The retry timer will follow a certain procedure to retry connecting
        //First, we check if we are currently connected
        if isConnected() {
            //We are connected, so we'll run this rety time in 1 sec, to see if it is still the case
            //This corresponds to the status "0" of the procedure
            
            mScanProcedureStatus = 0

        } else {
            
            //We are currently not connected. First, let's try to connect
            connect()
            
            //Then, let's reschedule a retry, to do so, let's increase the procedure status
            mScanProcedureStatus++
            
            //The retry status is an index on the SCAN_PROCEDURE, so we can't have it too long (array out of bound etc...)
            if mScanProcedureStatus >= SCAN_PROCEDURE.count {
                
               mScanProcedureStatus = SCAN_PROCEDURE.count - 1
                
            }
            
            NSLog("Connection lost detected ! Retrying in : \(SCAN_PROCEDURE[mScanProcedureStatus])")
        }
        
        
        //Ok, let's launch the retry timer
        mRetryTimer?.invalidate()
        
        mRetryTimer = NSTimer.scheduledTimerWithTimeInterval(SCAN_PROCEDURE[mScanProcedureStatus], target: self, selector:Selector("retryTimer"), userInfo: nil, repeats: false)
        
    }
    
    func getOTAMode() -> Bool {
        if let profile = mNevoBT?.getProfile() {
            return profile is NevoOTAControllerProfile
        }
        return false
    }
    
    func isBluetoothEnabled() -> Bool {
        if let enabled = mNevoBT?.isBluetoothEnabled() {
            return enabled
        }
        return false
    }
    
}
