//
//  MEDBaseModel.swift
//  Nevo
//
//  Created by Cloud on 2016/11/10.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class MEDBaseModel: Object {
    var key:String = ""
    override static func primaryKey() -> String? {
        return "key"
    }
}
