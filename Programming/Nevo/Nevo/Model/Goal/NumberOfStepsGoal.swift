//
//  NumberOfStepsGoal.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class NumberOfStepsGoal : Goal {
    private let mThistype = "NUMBER_OF_STEPS"
    private var mSteps:Int = 3000
    
    override init() {
        super.init()
        mType = mThistype
    }
    
    init(intensity:GoalIntensity,step:Int)
    {
        super.init()
        mGoalIntensity = intensity
        mType = mThistype
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