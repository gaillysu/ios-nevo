//
//  SettingSectionModel.swift
//  Nevo
//
//  Created by Cloud on 2017/5/24.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import RxDataSources

struct SettingSectionModel {
    var header:String
    var footer:String
    var items: [Item]
}

extension SettingSectionModel: SectionModelType {
    init(original: SettingSectionModel, items: [SettingSectionModelItem]) {
        self = original
        self.items = items
    }
    
    typealias Item = SettingSectionModelItem
}
