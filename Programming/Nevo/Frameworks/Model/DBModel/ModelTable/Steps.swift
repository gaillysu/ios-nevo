//
//  Steps.swift
//  Nevo
//
//  Created by Karl-John Chow on 17/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation
import RealmSwift

class Steps: Object {
    
    dynamic var steps:Int = 0
    
    dynamic var goal:Int = 0
    
    dynamic var distance:Int = 0
    
    dynamic var calories:Double = 0
 
    let hourlySteps = List<HourlyIntData>()
    
    let hourlyDistance = List<HourlyIntData>()
    
    let hourlyCalories = List<HourlyIntData>()
    
    dynamic var inZoneTime:Int = 0;
    
    dynamic var outZoneTime:Int = 0;
    
    dynamic var inactivityTime:Int = 0;
    
    dynamic var goalreach:Double = 0.0;
    
    dynamic var date:NSDate? = nil
    
    dynamic var createDate:String = ""
    
    // Walking
    dynamic var walkingDistance:Int = 0
    
    dynamic var walkingDuration:Int = 0
    
    dynamic var walkingCalories:Int = 0
    
    // Running
    dynamic var runningDistance:Int = 0
    
    dynamic var runningDuration:Int = 0
    
    dynamic var runningCalories:Int = 0
    
    dynamic var validicId:String = ""
    
    func fromStepsModel(userSteps :StepsModel){
        self.steps = userSteps.steps
        self.goal = userSteps.goalsteps
        self.distance = userSteps.distance
        self.calories = userSteps.calories
        for element in userSteps.hourlydistance.hourlyDataListForRealm(){
            self.hourlyDistance.append(element)
        }
        
        for element in userSteps.hourlysteps.hourlyDataListForRealm(){
            self.hourlySteps.append(element)
        }
        
        for element in userSteps.hourlycalories.hourlyDataListForRealm(){
            self.hourlyCalories.append(element)
        }
        
        self.inZoneTime = userSteps.inZoneTime
        self.outZoneTime = userSteps.outZoneTime
        self.inactivityTime = userSteps.inactivityTime
        self.goalreach = userSteps.goalreach
        self.date = NSDate(timeIntervalSince1970: userSteps.date)
        self.createDate = userSteps.createDate
        self.walkingDistance = userSteps.walking_distance
        self.walkingDuration = userSteps.walking_duration
        self.walkingCalories = userSteps.walking_calories
        self.runningDistance = userSteps.running_distance
        self.runningDuration = userSteps.running_duration
        self.runningCalories = userSteps.running_calories
        self.validicId = userSteps.validic_id
    }
}
