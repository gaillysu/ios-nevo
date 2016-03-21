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
    
    private var mRunning_Distance:Double
    private var mRunning_Date:NSDate
    private var lateNight:NSDate

    init(distance:Double, date:NSDate) {
        mRunning_Distance=distance

        mRunning_Date = NSDate().change(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)
        //A daily data point if from 00AM to 23:59:59
        lateNight = NSDate().change(year: date.year, month: date.month, day: date.day, hour: 23, minute: 59, second: 59)
    }

    @objc func toHKQuantitySample() -> HKQuantitySample {

        let stepCountQuantity = HKQuantity(unit:HKUnit.countUnit(), doubleValue: mRunning_Distance)
        return HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            quantity: stepCountQuantity,
            startDate: mRunning_Date, endDate: lateNight)
    }
    
    @objc func isUpdate()->Bool {return false}
}
