//
//  NevoProfile.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
This is the OTA Controller Profile
It is used to send and receive responses from the watch while doing an OTA
It controls the OTA process
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoOTAControllerProfile : Profile {
    
    var CONTROL_SERVICE:CBUUID {
        return CBUUID(string: "????DFU SERVICE????");
    }
    
    var CONTROL_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "???DFU CONTROLLER?????");
    }
    
    var CALLBACK_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "????DFU CONTROLLER????");
    }
}