//
//  Int+Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

extension String {
    func toInt() -> Int {
        return NSString(format: "%@", self).integerValue
    }
    
    func length() ->Int {
        return NSString(format: "%@", self).length
    }
    
    func hourlyDataListForRealm() -> [HourlyIntData]{
        if self == "" {
            return []
        }
        let json = JSON.parse(self)
        var list:[HourlyIntData] = []
        for element in json {
            let data = HourlyIntData()
            data.hourlyIntData = element.0.toInt()
            list.append(data)
        }
        return list
    }
}
