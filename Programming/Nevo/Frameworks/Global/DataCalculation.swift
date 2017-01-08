//
//  DataCalculation.swift
//  Nevo
//
//  Created by Cloud on 2016/12/28.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class DataCalculation: NSObject {

    /// 根据活动时间、步数来计算走的距离和消耗的卡路里
    ///
    /// - Parameters:
    ///   - activeTimer: 活动时间
    ///   - steps: 步数
    ///   - completionData: (_ miles:计算完成后回调距离值,_ calories:计算完成后回调消耗卡路里值)
    class func calculationData(_ activeTimer:Int,steps:Int,completionData:((_ miles:Double,_ calories:Double) -> Void)) {
        let profiles = MEDUserProfile.getAll()
        var userProfile:MEDUserProfile?
        var strideLength:Double = 0
        var userWeight:Double = 0
        if profiles.count>0 {
            userProfile = profiles.first as? MEDUserProfile
            strideLength = Double(userProfile!.length)*0.415/100
            userWeight = Double(userProfile!.weight)
        }else{
            strideLength = Double(170)*0.415/100
            userWeight = 65
        }
        
        let miles:Double = strideLength*Double(steps)/1000
        let calories:Double = (2.0*userWeight*3.5)/200*Double(activeTimer)
        completionData(miles, calories)
    }
    
}
