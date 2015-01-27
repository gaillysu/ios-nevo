//
//  Goal.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreData

/*
This class represents all goals,
being steps count, calorie count etc...
*/

class Goal { /*
    private var goalIntensity : GoalIntensity
    private let type : String
    
    struct GoalFactory {
        static func fromCoreData(NSManagedObject) -> Goal{
            //Here, we analyse the Code Data object and return the appropriate Goal object
        }
        
        static func newGoal(aType:String, intensity:GoalIntensity) -> Goal{
            if (aType== (NumberOfStepsGoal()).type ) {
                return NumberOfStepsGoal(intensity)
            }
            
        }
    }
    
    private init() {
        //This is an abstract class, we should'nt init it
    }
    
    func setGoalIntensity(intensity : GoalIntensity) {
        goalIntensity = intensity
        
    }
    
    func getGoalIntensity() -> GoalIntensity{
        return goalIntensity
    }
    
    class func toCoreData() -> NSManagedObject{
        
    }*/

}

enum GoalIntensity {
    case LOW, MEDIUM, HIGH
}