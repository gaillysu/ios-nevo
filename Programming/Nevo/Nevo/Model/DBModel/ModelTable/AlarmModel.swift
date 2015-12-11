//
//  AlarmModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmModel: UserDatabaseHelper {
    var timer:NSTimeInterval = 0.0
    var label:String = ""
    var status:Bool = false
    var repeatStatus:Bool = false

    override init() {

    }

}
