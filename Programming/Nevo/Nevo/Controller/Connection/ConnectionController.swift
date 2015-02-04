//
//  SyncController.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
The connection controller handles all the high level connection related tasks
It will reconnect the device, keep searching if it doesn't find it the first time
It also memorise the first device connected and automatically connects to it
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol ConnectionController {

    /**
    Sets the current  connection controller's delegate
    */
    func setDelegate(ConnectionControllerDelegate)
    
    /**
    Tries to connect to a Nevo
    Myabe it will scan for nearby nevo, maybe it will simply connect to a known nevo
    */
    func connect()
    
    /**
    Checks if there's a device currently connected
    */
    func isConnected() -> Bool
    
    /**
    Checks if there is a preffered device.
    If the answer is yes, then we will systematically connect to this device.
    If it is no, then we will scan for a new device
    */
    func hasSavedAddress() -> Bool
    
    /**
    Forgets the currently saved address.
    Next time connect is called, we will have to scan for nearby devices
    */
    func forgetSavedAddress()
    
    /**
    Tries to send a request, you can't be sure that it will effectively be sent
    */
    func sendRequest(Request)
    
    /**
    Enters the OTA mode. In this mode, it searchs for OTA enabled Nevo
    It won't connect to other Nevo and will stop sending regular nevo querries
    */
    func setOTAMode(Bool)

    /**
    Checks whether the connection controller is in OTA mode
    While in OTA mode, the ConnectionController will stop responding to normal commands
    */
    func getOTAMode() -> Bool
}

protocol ConnectionControllerDelegate {
    
    /**
    Called when a packet is received from the device
    */
    func packetReceived(RawPacket)
    
    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
}
