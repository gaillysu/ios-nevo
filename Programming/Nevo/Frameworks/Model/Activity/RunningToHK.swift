//
//  RunningToHK.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/21.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import HealthKit
 

class RunningToHK: NevoHKDataPoint {
    
    fileprivate var mRunning_Distance:Double
    fileprivate var mRunning_Date:Date
    fileprivate var lateNight:Date

    init(distance:Double, date:Date) {
        mRunning_Distance=distance

        mRunning_Date = date
        //A daily data point if from 00AM to 23:59:59
        lateNight = Date().change(year:date.year, month: date.month, day: date.day, hour: date.hour, minute: 59, second: 59)
    }

    @objc func toHKQuantitySample() -> HKQuantitySample {

        let stepCountQuantity = HKQuantity(unit:HKUnit.meter(), doubleValue: mRunning_Distance)
        return HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            quantity: stepCountQuantity,
            start: mRunning_Date, end: lateNight)
    }
    
    @objc func isUpdate()->Bool {return false}
}
