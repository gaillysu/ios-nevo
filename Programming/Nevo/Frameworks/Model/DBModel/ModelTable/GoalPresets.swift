//
//  Sleep.swift
//  Nevo
//
//  Created by Karl-John Chow on 17/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class GoalPresets: Object {

    dynamic var steps:Int = 0
    
    dynamic var name:String = ""
    
    dynamic var enabled:Bool = false
    
    func fromGoalModel(presetsModel:PresetsModel){
        self.name = presetsModel.label
        self.enabled = presetsModel.status
        self.steps = presetsModel.steps
    }
}
