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
        mNevoBT?.scanAndConnect()
    }
    
    /**
    See NevoBTDelegate
    */
    func scanStopped() {
      //TODO smart retry service
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
    
    func sendRequest(request:Request) {
        mNevoBT?.sendRequest(request)
    }
    
    /**
    See NevoBTDelegate
    */
    func packetReceived(packet:RawPacket) {
        mDelegate.packetReceived(packet)
    }
    
}
