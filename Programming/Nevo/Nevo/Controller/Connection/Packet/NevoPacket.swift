//
//  NevoPacket.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Represents a series of packets concatenated together to form the response from the watch
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoPacket {
    private var mPackets:[NSData]=[]
    private var mHeader:UInt8 = 0
    let endFlag:UInt8 = 0xFF
    
    init(packets:[NSData])
    {
        if(packets.count >= 2)
        {
        mPackets = packets
        mHeader = NSData2Bytes(mPackets[0])[0]
        }
    }
    
    func getHeader() ->UInt8
    {
        return mHeader
    }
    class func isLastPacket(packet:RawPacket) ->Bool
    {
        return (NSData2Bytes(packet.getRawData())[0] == 0xFF)
    }
    
}