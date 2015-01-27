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
    The address of the peripheral that sent this packet
    Warning, this address is not a MAC address and my change in time
    */
    func getPeripheralAddress() -> NSUUID
    
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
    private var mAddress:NSUUID
    private var mProfile:Profile
    
    
    init( data:NSData, address:NSUUID, profile:Profile ) {
        mData=data
        mAddress=address
        mProfile=profile
    }
    
    func getPeripheralAddress() -> NSUUID {
        return mAddress
    }
    
    func getSourceProfile() -> Profile {
        return mProfile
    }
    
    func getRawData() -> NSData {
        return mData
    }
    
}