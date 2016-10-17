//
//  Migratable.swift
//  Nevo
//
//  Created by Karl-John Chow on 17/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
protocol Migratable {
    func migrate (oldModel:UserDatabaseHelper) -> Object
}
