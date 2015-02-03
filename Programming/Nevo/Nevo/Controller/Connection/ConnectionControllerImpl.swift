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
    let mNevoBT:NevoBT?
    let mDelegate:ConnectionControllerDelegate
    
    init(delegate:ConnectionControllerDelegate) {
        
        mDelegate = delegate

        mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: NevoProfile())
    }
    
    /**
    Connects to the previously known device and/or searchs for a new one
    */
    func connect() {
        //TODO this is just test code
        //For the test we can try to use scan and conenct or just connect
        mNevoBT?.scanAndConnect()
        //mNevoBT?.connectToAddress(NSUUID(UUIDString: "D9E68ED2-3C2D-71A7-93DE-4DF0AC5F374C")!)
    }
    
    /**
    See NevoBTDelegate
    */
    func scanStopped() {
      //TODO smart retry service
        
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
        //TODO smart retry
        
        if (!isConnected) {
            connect()
        } else {
            //Send the set time querry
        }
        
        mDelegate.connectionStateChanged(isConnected)
    }
    
    func disconnect() {
        //TODO
    }
    

    
    func forgetCurrentlySavedDevice() {
        //TODO
    }
    
    func isConnected() -> Bool {
        return mNevoBT!.isConnected()
    }
    
    func hasSavedAddress() -> Bool {
        return true
    }
    
    func sendRequest(request:Request) {
        mNevoBT?.sendRequest(request)
    }
    
    /**
    See NevoBTDelegate
    */
    func packetReceived(packet:RawPacket, fromAddress : NSUUID) {
        mDelegate.packetReceived(packet)
    }
    
}
