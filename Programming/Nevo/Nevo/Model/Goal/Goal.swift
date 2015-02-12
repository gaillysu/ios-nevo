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

class Goal {
    
    //how to make goalIntensity & type is invisible in other class (exclude sub class), it is bad idea expose these variable，we should avoid this case.
    
    var goalIntensity : GoalIntensity?
    var type : String  = "UNKNOWN"
    
    struct GoalFactory {
        static func fromCoreData(NSManagedObject) -> Goal{
            //Here, we analyse the Code Data object and return the appropriate Goal object
            return Goal()
        }
        
        static func newGoal(aType:String, intensity:GoalIntensity) -> Goal{
            if (aType == (NumberOfStepsGoal()).getType()) {
                return NumberOfStepsGoal(intensity: intensity)
            }
            return Goal()
        }
    }
    
    init() {
        //This is an abstract class, we should'nt init it
    }
    
    func getType() ->NSString
    {
        return  type
    }
    
    func setGoalIntensity(intensity : GoalIntensity) {
        goalIntensity = intensity
        
    }
    
    func getGoalIntensity() -> GoalIntensity{
        return goalIntensity!
    }
    
    class func toCoreData() -> NSManagedObject{
        return NSManagedObject()
    }

}

enum GoalIntensity:UInt8 {
    case LOW, MEDIUM, HIGH
}