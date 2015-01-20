//
//  NevoBT.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
NevoBT should do one thing : control the Core Bluetooth classes.
Out of this class, there should be no reference to the CB classes.
This class is rather low level, it doesn't handle timeout, disconnections etc...
It only can connect to one peripheral at a time
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
//This is a cat -----> 🐱
protocol NevoBT {
    let SCANNING_DURATION : NSTimeInterval
    
    class func scanAndConnect(acceptableDevice : Profile)
    class func connectToAddress(peripheralAddress : CBUUID)
    class func disconnect()
    
    class func sendRequest(Request)
    
    class func isConnected() -> Boolean
}

protocol NevoBTDelegate {
    class func connectionStateChanged(isConnected : Boolean)
    class func packetReceived(RawPacket)
}