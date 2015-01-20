//
//  RawPacket.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Implementation of the NevoBT Protocol
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol RawPacket {
    class func getPeripheralAddress() -> CBUUID
    class func getSourceProfile() -> Profile
    class func getRawData() -> NSData
}