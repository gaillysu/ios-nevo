//
//  Goal.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
This class represents all goals,
being steps count, calorie count etc...
*/

class Goal {
    private var goalIntensity : GoalIntensity
    private let type
    
    struct GoalFactory {
        static func fromCoreData(NSManagedObject) -> Goal{
            //Here, we analyse the Code Data object and return the appropriate Goal object
        }
        
        static func newGoal(type:String) -> Goal{
            if(type=NumberOfStepsGoal().type) {
                return NumberOfStepsGoal()
            }
            
        }
    }
    
    func setGoalIntensity(intensity : GoalIntensity) {
        goalIntensity = intensity
        
    }
    
    func getGoalIntensity() {
        return goalIntensity
    }
    
    class func toCoreData() -> NSManagedObject

}

enum GoalIntensity {
    case LOW, MEDIUM, HIGH
}