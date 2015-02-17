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

    private var mThisGoal : Goal
    
    init (goal : Goal) {
        mThisGoal = goal
    }
    
    override func getRawDataEx() -> NSArray {
    
       
    var level :UInt8 = mThisGoal.getGoalIntensity().rawValue
    var display:UInt8 = 0  //default is step goal showing
    var goal_dist = 10000 //unit ??cm
  
    var goal_steps = mThisGoal.getType() == "NUMBER_OF_STEPS" ? (mThisGoal as NumberOfStepsGoal).getNumberOfSteps() : 0
        
    var goal_carlories = 2000 // unit ??
    var goal_time = 100 //unit ??
    var goal_stroke = 3000 // unit ???
        
    var values1 :[UInt8] = [0x00,0x22,level,display,
        UInt8(goal_dist&0xFF),
        UInt8((goal_dist>>8)&0xFF),
        UInt8((goal_dist>>16)&0xFF),
        UInt8((goal_dist>>24)&0xFF),
        UInt8(goal_steps&0xFF),
        UInt8((goal_steps>>8)&0xFF),
        UInt8((goal_steps>>16)&0xFF),
        UInt8((goal_steps>>24)&0xFF),
        UInt8(goal_carlories&0xFF),
        UInt8((goal_carlories>>8)&0xFF),
        UInt8((goal_carlories>>16)&0xFF),
        UInt8((goal_carlories>>24)&0xFF),
        UInt8(goal_time&0xFF),
        UInt8((goal_time>>8)&0xFF),
        UInt8((goal_time>>16)&0xFF),
        UInt8((goal_time>>24)&0xFF)
        ]
        
    var values2 :[UInt8] = [0xFF,0x22,
        UInt8(goal_stroke&0xFF),
        UInt8((goal_stroke>>8)&0xFF),
        UInt8((goal_stroke>>16)&0xFF),
        UInt8((goal_stroke>>24)&0xFF),
        0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
    return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
    
}