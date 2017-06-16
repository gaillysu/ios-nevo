//
//  AlarmSectionModel.swift
//  Nevo
//
//  Created by Cloud on 2017/5/24.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import RxDataSources

struct AlarmSectionModel {
    var header:String
    var items: [Item]
}

extension AlarmSectionModel: SectionModelType {
    init(original: AlarmSectionModel, items: [AlarmSectionModelItem]) {
        self = original
        self.items = items
    }
    
    typealias Item = AlarmSectionModelItem
}

