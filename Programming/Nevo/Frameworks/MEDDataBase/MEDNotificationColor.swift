//
//   MEDNotificationColor.swift
//  Nevo
//
//  Created by Quentin on 6/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import RealmSwift

class MEDNotificationColor: MEDBaseModel {
    dynamic var name: String = ""
    // #ffffff
    dynamic var color: String = ""
    
    dynamic var key:String = NSUUID().uuidString
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    class func factory(name: String, color: String) -> MEDNotificationColor {
        let model = self.init()
        model.name = name
        model.color = color
        return model
    }
}
