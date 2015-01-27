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
    let CONTROL_SERVICE : CBUUID = CBUUID(string: "0C50D390-DC8E-436B-8AD0-A36D1B304B18");
    let CONTROL_CHARACTERISTIC : CBUUID = CBUUID(string: "0C50D390-DC8E-436B-8AD0-A36D1B304B18");
    let CALLBACK_CHARACTERISTIC : CBUUID = CBUUID(string: "0C50D390-DC8E-436B-8AD0-A36D1B304B18");
}

//This is a tiger -----> 🐯