//
//  Request.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Protocol that defines what's a Request.
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol Request {
    class func getTargetProfile() -> Profile
    class func getRawData() -> NSData
}