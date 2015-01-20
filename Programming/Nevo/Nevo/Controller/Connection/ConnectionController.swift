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
    class func connect()
    class func disconnect()
    class func isConnected()
    
    class func forgetCurrentlySavedDevice()
    
    class func sendRequest(Request)
}

protocol ConnectionControllerDelegate {
    class func packetReceived(RawPacket)
}
