//
//  HealthModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class HealthModel: UserDatabaseHelper {
    var userId:Int = 0
    var date:NSDate = NSDate()
    var createdDate:NSDate = NSDate()
    var maxHRM:Int = 0
    var avgHRM:Int = 0

    override init() {

    }
}
