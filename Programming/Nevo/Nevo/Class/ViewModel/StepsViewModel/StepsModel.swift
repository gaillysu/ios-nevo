//
//  StepsModel.swift
//  Nevo
//
//  Created by Cloud on 2017/5/24.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import RxDataSources

struct StepsModel {
    var items: [Item]
}

extension StepsModel: SectionModelType {
    init(original: StepsModel, items: [StepsModelItem]) {
        self = original
        self.items = items
    }
    
    typealias Item = StepsModelItem
}
