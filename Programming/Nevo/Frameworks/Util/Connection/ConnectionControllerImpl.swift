//
//  ConnectionControllerImpl.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import XCGLogger
import CoreBluetooth
/*
See ConnectionController
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class ConnectionControllerImpl : NSObject {
    fileprivate var mNevoBT:NevoBT?
    fileprivate var mDelegate:ConnectionControllerDelegate?

    let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
    
    //use this struct for other class to read
    struct Const {
        static let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
    }
    
    /**
    This procedure explain the scan procedure
    Every X sec we will check if the peripheral is connected and retry to connect to it
    X changes depending on how long ago we scaned previously
    For example, we'll retry afetr 1 sec, then 10s, then 10s, then 10s, then 60s sec, 120s etc..
    */
    let SCAN_PROCEDURE:[Double] = [1,10,10,10,
        30,30,30,30,30,30,30,30,30,30,/*5min*/
        60,60,60,60,60,60,60,60,60,60,/*10min*/
        120,120,120,120,120,120,120,120,120,/*20min*/
        240,3600]
    
    /**
    This status is used to search in SCAN_PROCEDURE to know when is the next time we should scan
    */
    fileprivate var mScanProcedureStatus = 0
    
    /**
    This time handles the retry procedure
    */
    fileprivate var mRetryTimer:Timer?
    
    /**
    No initialisation outside of this class, this is a singleton
    */
    override init() {
        super.init()
        let profile:Profile = NevoProfile()
        mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: profile)
        setOTAMode(false,Disconnect:true)
    }
    
    /**
    See ConnectionController protocol
    */
    func setDelegate(_ delegate:ConnectionControllerDelegate) {
        XCGLogger.default.debug("New delegate : \(delegate)")
        
        mDelegate = delegate
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
            
            XCGLogger.default.debug("We have a saved address, let's connect to it directly : \(UserDefaults.standard.object(forKey: self.SAVED_ADDRESS_KEY))")

            mNevoBT?.connectToAddress(
                UUID(uuidString:
                    UserDefaults.standard.object(forKey: SAVED_ADDRESS_KEY) as! String
                    )!
            )

        } else {
            
            XCGLogger.default.debug("We don't have a saved address, let's scan for nearby devices.")

            mNevoBT?.scanAndConnect()
        }

    }
    
    fileprivate func initRetryTimer() {
        if mRetryTimer != nil {
            //If we already have initialised it, no need to continue
            return;
        }
        
        mScanProcedureStatus = 0
        
        mRetryTimer = Timer.scheduledTimer(timeInterval: SCAN_PROCEDURE[mScanProcedureStatus], target: self, selector:#selector(retryTimer), userInfo: nil, repeats: false)
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
            mScanProcedureStatus += 1

            //The retry status is an index on the SCAN_PROCEDURE, so we can't have it too long (array out of bound etc...)
            if mScanProcedureStatus >= SCAN_PROCEDURE.count {
               mScanProcedureStatus = SCAN_PROCEDURE.count - 1
            }
            
            XCGLogger.default.debug("Connection lost detected ! Retrying in : \(self.SCAN_PROCEDURE[self.mScanProcedureStatus])")
        }
        
        
        //Ok, let's launch the retry timer
        mRetryTimer?.invalidate()
        
        mRetryTimer = Timer.scheduledTimer(timeInterval: SCAN_PROCEDURE[mScanProcedureStatus], target: self, selector:#selector(retryTimer), userInfo: nil, repeats: false)
        
    }
    
    func getOTAMode() -> Bool {
        if let profile = mNevoBT?.getProfile() {
            return profile is NevoOTAControllerProfile || profile is NevoOTAModeProfile
        }
        return false
    }
}

// MARK: - NevoBTDelegate
extension ConnectionControllerImpl:NevoBTDelegate {

    func bluetoothEnabled(_ enabled:Bool){
        mDelegate?.bluetoothEnabled(enabled)
    }
    
    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID!,isFirstPair:Bool) {
        mDelegate?.connectionStateChanged(isConnected, fromAddress : fromAddress,isFirstPair:isFirstPair)
        if (!isConnected) {
            connect()
        } else {
            mNevoBT?.stopScan()
            //Let's save this address
            if let address = fromAddress?.uuidString {
                self.savedWatchAddress(address)
            }
        }
    }
    
    /**
     See NevoBTDelegate
     */
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Int) {
        mDelegate?.firmwareVersionReceived(whichfirmware, version: version)
    }
    
    /**
     Receiving the current device signal strength value
     
     :param: number, Signal strength value
     */
    func receivedRSSIValue(_ number:NSNumber){
        //AppTheme.DLog("Red RSSI Value:\(number)")
        mDelegate?.receivedRSSIValue(number)
    }
    
    /**
     See NevoBTDelegate
     */
    func packetReceived(_ packet:RawPacket, fromAddress : UUID) {
        mDelegate?.packetReceived(packet)
    }
    
    func scanAndConnect(){
        mDelegate?.scanAndConnect()
    }
}

// MARK: - mNevoBT
extension ConnectionControllerImpl:ConnectionController {
    func stopScan(){
        mNevoBT?.stopScan()
    }
    /**
     See ConnectionController protocol
     */
    func disconnect() {
        mNevoBT?.disconnect()
        
        mRetryTimer?.invalidate()
        
        mRetryTimer = nil
    }
    
    /**
     See ConnectionController protocol
     */
    func forgetSavedAddress() {
        if hasSavedAddress() {
            UserDefaults.standard.removeObject(forKey: SAVED_ADDRESS_KEY);
            UserDefaults.standard.synchronize()
        }
    }
    /**
     See ConnectionController protocol
     */
    func savedWatchAddress(_ uuidString:String) {
        let userDefaults = UserDefaults.standard;
        if userDefaults.object(forKey: SAVED_ADDRESS_KEY) == nil {
            userDefaults.set(uuidString,forKey:SAVED_ADDRESS_KEY)
            userDefaults.synchronize()
        }
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
    
    // 如果没有该key,返回false; 如果有该key,但值为空字符串,返回false
    func hasSavedAddress() -> Bool {
        
        if UserDefaults.standard.object(forKey: SAVED_ADDRESS_KEY) != nil {
            return true
        }
        return false
    }
    
    /**
     See ConnectionController
     */
    func setOTAMode(_ OTAMode:Bool,Disconnect:Bool) {
        
        //No need to change the mode if we are already in OTA Mode
        if getOTAMode() == OTAMode {
            return;
        }
        if Disconnect
        {
            //cancel reconnect timer, make sure OTA can do connect by OTAcontroller
            disconnect()
        }
        
        //We don't set the profile on the NevoBT, because it could create too many issues
        //So we destroy the previous instance and recreate one
        if(OTAMode) {
            let profile:Profile = NevoOTAModeProfile()
            if Disconnect
            { mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: profile)}
            else
            { mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: NevoOTAControllerProfile())}
        } else {
            let profile:Profile = NevoProfile()
            mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: profile)
        }
        
    }

    /**
     See ConnectionController protocol
     */
    func sendRequest(_ request:Request) {
        mNevoBT?.sendRequest(request)
    }
    
    func isBluetoothEnabled() -> Bool {
        if let enabled = mNevoBT?.isBluetoothEnabled() {
            return enabled
        }
        return false
    }
    
    //Get to hold the UUID returns whether pairing，true = pairing ,false = not pairing
    func isPairingPeripheral() -> Bool{
        let profile = mNevoBT?.isPairingPeripheral(UUID(uuidString:
            UserDefaults.standard.object(forKey: SAVED_ADDRESS_KEY) as! String
            )!)
        return profile!
    }
    
    func getBLECentralManager() -> CBCentralManager? {
        return mNevoBT?.getBLECentralManager()
    }
}
