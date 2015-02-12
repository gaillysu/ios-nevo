//
//  NumberOfStepsGoal.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class NumberOfStepsGoal : Goal {
    internal let thistype = "NUMBER_OF_STEPS"
    
    override init() {
        super.init()
        type = thistype
    }
    
    init(intensity:GoalIntensity)
    {
        super.init()
        goalIntensity = intensity
        type = thistype
    }
    func getNumberOfSteps() -> NSInteger {
        //return the number of steps depending on the goal intensity
        NSLog("getNumberOfSteps() return 1000")
        return 1000
    }
    
}

/*
🐾
 🐾
🐾
  🐾
 🐾
*/