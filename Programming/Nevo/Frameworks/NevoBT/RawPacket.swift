//
//  RawPacket.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth

/*
Implementation of the NevoBT Protocol
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol RawPacket {
    
    /**
    The service and Char that sent packet
    */
    func getSourceProfile() -> Profile
    
    /**
    The raw packet data
    */
    func getRawData() -> NSData
}

class RawPacketImpl : RawPacket {
    private var mData:NSData
    private var mProfile:Profile
    
    
    init( data:NSData, profile:Profile ) {
        mData=data
        mProfile=profile
    }
    
    func getSourceProfile() -> Profile {
        return mProfile
    }
    
    func getRawData() -> NSData {
        return mData
    }
    
}