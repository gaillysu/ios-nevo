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
class ConnectionControllerImpl : ConnectionController, NevoBTDelegate {
    var mNevoBT:NevoBT?
    var mDelegate:ConnectionControllerDelegate?
    var mSavedAddress:NSUUID?
    
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
    private init() {
        
        mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: NevoProfile())
        setOTAMode(false)
    }
    
    /**
    See ConnectionController protocol
    */
    func setDelegate(delegate:ConnectionControllerDelegate) {
        //TODO by Hugo FIND A WAY TO ENSURE THAT WE DON'T LEAVE THE OTA SCREEN STILL IN OTA MODE
        mDelegate = delegate
    }

    /**
    See ConnectionController protocol
    */
    func connect() {
        //TODO by Hugo this is just test code
        //For the test we can try to use scan and conenct or just connect
        mNevoBT?.scanAndConnect()
        //mNevoBT?.connectToAddress(NSUUID(UUIDString: "D9E68ED2-3C2D-71A7-93DE-4DF0AC5F374C")!)
    }
    
    /**
    See NevoBTDelegate
    */
    func scanStopped() {
      //TODO by Hugo smart retry service
        
        if (!mNevoBT!.isConnected()) {
            connect()
        } else {
            //Send the set time querry
        }
    }
    
    /**
    See NevoBTDelegate
    */
    func connectionStateChanged(isConnected : Bool) {
        //TODO by Hugo smart retry
        mDelegate?.connectionStateChanged(isConnected)
        
        if (!isConnected) {
            connect()
        } else {
            //Send the set time querry
        }
        
    }
    
    /**
    See ConnectionController protocol
    */
    func disconnect() {
        //TODO by Hugo
    }
    
    /**
    See ConnectionController protocol
    */
    func forgetSavedAddress() {
        //TODO by Hugo
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
        return true
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
        mDelegate?.packetReceived(packet)
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
