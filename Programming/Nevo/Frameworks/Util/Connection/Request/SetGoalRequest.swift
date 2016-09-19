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
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x22
    }

    fileprivate var mThisGoal : Goal
    
    init (goal : Goal) {
        mThisGoal = goal
    }
    
    override func getRawDataEx() -> NSArray {
    
       
    let level :UInt8 = mThisGoal.getGoalIntensity().rawValue
    let display:UInt8 = 0  //default is step goal showing
    let goal_dist = 10000 //unit ??cm
  
    let goal_steps = mThisGoal.getType() == NumberOfStepsGoal().getType() ? mThisGoal.getValue() : 0
        
    let goal_carlories = 2000 // unit ??
    let goal_time = 100 //unit ??
    let goal_stroke = 3000 // unit ???
        
    let values1 :[UInt8] = [0x00,SetGoalRequest.HEADER(),level,display,
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
        
    let values2 :[UInt8] = [0xFF,SetGoalRequest.HEADER(),
        UInt8(goal_stroke&0xFF),
        UInt8((goal_stroke>>8)&0xFF),
        UInt8((goal_stroke>>16)&0xFF),
        UInt8((goal_stroke>>24)&0xFF),
        0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
    return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
    
}
