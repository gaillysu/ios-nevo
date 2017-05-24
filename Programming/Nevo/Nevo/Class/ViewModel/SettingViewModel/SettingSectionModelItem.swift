//
//  SettingSectionModelItem.swift
//  Nevo
//
//  Created by Cloud on 2017/5/24.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

struct SettingSectionModelItem {
    var label: String
    var type:SetingType
    var iconName:String
    
    init(label:String,type:SetingType,name:String) {
        self.label = label
        self.type = type
        self.iconName = name
    }
}
