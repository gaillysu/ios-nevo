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
    var mSteps:Int = 3000
    
    override init() {
        super.init()
        type = thistype
    }
    
    init(intensity:GoalIntensity,step:Int)
    {
        super.init()
        goalIntensity = intensity
        type = thistype
        mSteps = step
    }
    func getNumberOfSteps() -> NSInteger {
        //return the number of steps depending on the goal intensity
        NSLog("getNumberOfSteps() return \(mSteps)")
        return NSInteger(mSteps)
    }
    
}

/*
🐾
 🐾
🐾
  🐾
 🐾
*/