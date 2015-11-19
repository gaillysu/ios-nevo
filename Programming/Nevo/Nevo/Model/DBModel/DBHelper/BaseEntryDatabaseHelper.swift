//
//  BaseEntryDatabaseHelper.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import Foundation

protocol BaseEntryDatabaseHelper {
    func add()->Bool
    func update()->Bool
    func remove()->Bool
    func get(criteria:String)->NSArray
    func getAll()->NSArray
}
