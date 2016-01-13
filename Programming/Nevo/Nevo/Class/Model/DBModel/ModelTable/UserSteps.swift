//
//  UserSteps.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSteps: NSObject,BaseEntryDatabaseHelper {
    var id:Int = 0
    var steps:Int = 0
    var goalsteps:Int = 0
    var distance:Int = 0
    var hourlysteps:String = ""
    var hourlydistance:String = ""
    var calories:Double = 0
    var hourlycalories:String = ""
    var inZoneTime:Int = 0;
    var outZoneTime:Int = 0;
    var inactivityTime:Int = 0;
    var goalreach:Double = 0.0;
    var date:NSTimeInterval = 0
    var createDate:String = ""
    var walking_distance:Int = 0
    var walking_duration:Int = 0
    var walking_calories:Int = 0
    var running_distance:Int = 0
    var running_duration:Int = 0
    var running_calories:Int = 0
    private var stepsModel:StepsModel = StepsModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) -> Void in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        stepsModel.steps = steps
        stepsModel.goalsteps = goalsteps
        stepsModel.distance = distance
        stepsModel.hourlysteps = hourlysteps
        stepsModel.hourlydistance = hourlydistance
        stepsModel.calories = calories
        stepsModel.hourlycalories = hourlycalories
        stepsModel.inZoneTime = inZoneTime
        stepsModel.outZoneTime = outZoneTime
        stepsModel.inactivityTime = inactivityTime
        stepsModel.goalreach = goalreach
        stepsModel.date = date
        stepsModel.createDate = createDate
        stepsModel.walking_distance = walking_distance
        stepsModel.walking_duration = walking_duration
        stepsModel.walking_calories = walking_calories
        stepsModel.running_distance = running_distance
        stepsModel.running_duration = running_duration
        stepsModel.running_calories = running_calories

        stepsModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        stepsModel.id = id
        stepsModel.steps = steps
        stepsModel.goalsteps = goalsteps
        stepsModel.distance = distance
        stepsModel.hourlysteps = hourlysteps
        stepsModel.hourlydistance = hourlydistance
        stepsModel.calories = calories
        stepsModel.hourlycalories = hourlycalories
        stepsModel.inZoneTime = inZoneTime
        stepsModel.outZoneTime = outZoneTime
        stepsModel.inactivityTime = inactivityTime
        stepsModel.goalreach = goalreach
        stepsModel.date = date
        stepsModel.createDate = createDate
        stepsModel.walking_distance = walking_distance
        stepsModel.walking_duration = walking_duration
        stepsModel.walking_calories = walking_calories
        stepsModel.running_distance = running_distance
        stepsModel.running_duration = running_duration
        stepsModel.running_calories = running_calories
        return stepsModel.update()
    }

    func remove()->Bool{
        stepsModel.id = id
        return stepsModel.remove()
    }

    class func removeAll()->Bool{
        return StepsModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = StepsModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let presets:UserSteps = UserSteps(keyDict: [
                "id":stepsModel.id,
                "steps":stepsModel.steps,
                "goalsteps":stepsModel.goalsteps,
                "distance":stepsModel.distance,
                "hourlysteps":stepsModel.hourlysteps,
                "hourlydistance":stepsModel.hourlydistance,
                "calories":stepsModel.calories ,
                "hourlycalories":stepsModel.hourlycalories,
                "inZoneTime":stepsModel.inZoneTime,
                "outZoneTime":stepsModel.outZoneTime,
                "inactivityTime":stepsModel.inactivityTime,
                "goalreach":stepsModel.goalreach,
                "date":stepsModel.date,
                "createDate":stepsModel.createDate,
                "walking_distance":stepsModel.walking_distance,
                "walking_duration":stepsModel.walking_duration,
                "walking_calories":stepsModel.walking_calories,
                "running_distance":stepsModel.running_distance,
                "running_duration":stepsModel.running_duration, "running_calories":stepsModel.running_calories])
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = StepsModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let presets:UserSteps = UserSteps(keyDict: [
                "id":stepsModel.id,
                "steps":stepsModel.steps,
                "goalsteps":stepsModel.goalsteps,
                "distance":stepsModel.distance,
                "hourlysteps":stepsModel.hourlysteps,
                "hourlydistance":stepsModel.hourlydistance,
                "calories":stepsModel.calories ,
                "hourlycalories":stepsModel.hourlycalories,
                "inZoneTime":stepsModel.inZoneTime,
                "outZoneTime":stepsModel.outZoneTime,
                "inactivityTime":stepsModel.inactivityTime,
                "goalreach":stepsModel.goalreach,
                "date":stepsModel.date,
                "createDate":stepsModel.createDate,
                "walking_distance":stepsModel.walking_distance,
                "walking_duration":stepsModel.walking_duration,
                "walking_calories":stepsModel.walking_calories,
                "running_distance":stepsModel.running_distance,
                "running_duration":stepsModel.running_duration, "running_calories":stepsModel.running_calories])
            allArray.addObject(presets)
        }
        return allArray
    }
}
