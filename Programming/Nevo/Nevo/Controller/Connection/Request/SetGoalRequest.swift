//
//  SetGoalRequest.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Sets a goal to the given value
*/
class SetGoalRequest : NevoRequest {

    var thisGoal : Goal
    
    init (goal : Goal) {
        thisGoal = goal
    }
    
    class func getRawData() -> NSData {
        //Construct the query in different ways
        //Depending on the given goal
        return NSData()
    }
    
}