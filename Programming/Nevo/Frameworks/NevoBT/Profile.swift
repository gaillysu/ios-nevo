//
//  NevoProtocol.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
A Profile is a set of GATT values that defines a device
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/

protocol Profile {
    let CONTROL_SERVICE : CBUUID
    let CONTROL_CHARACTERISTIC : CBUUID
    let CALLBACK_CHARACTERISTIC : CBUUID
}