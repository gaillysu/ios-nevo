//
//  NumberOfStepsGoal.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class NumberOfStepsGoal : Goal {
    internal let type = "NUMBER_OF_STEPS"
    
    override init() {
        
    }
    
    func getNumberOfSteps() -> NSInteger {
        //return the number of steps depending on the goal intensity
        return 6
    }
    
}

/*
🐾
 🐾
🐾
  🐾
 🐾
*/