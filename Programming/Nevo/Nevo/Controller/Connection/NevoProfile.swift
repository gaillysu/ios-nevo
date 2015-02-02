//
//  NevoProfile.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth


class NevoProfile : Profile {

    var CONTROL_SERVICE:CBUUID {
        return CBUUID(string: "F0BA3011-6CAC-4C99-9089-4B0A1DF45002");
    }

    var CONTROL_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "0C50D390-DC8E-436B-8AD0-A36D1B304B18");
    }

    var CALLBACK_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "0C50D390-DC8E-436B-8AD0-A36D1B304B18");
    }
}

//This is a tiger -----> 🐯