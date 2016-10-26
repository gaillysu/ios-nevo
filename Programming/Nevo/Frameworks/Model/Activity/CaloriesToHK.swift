//
//  CaloriesToHK.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/21.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import HealthKit
import Timepiece

class CaloriesToHK: NevoHKDataPoint {
    
    fileprivate var mCalories:Double
    fileprivate var mCalories_Date:Date
    fileprivate var lateNight:Date

    init(calories:Double, date:Date) {
        mCalories=calories

        mCalories_Date = Date().change(year:date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)
        //A daily data point if from 00AM to 23:59:59
        lateNight = Date().change(year:date.year, month: date.month, day: date.day, hour: date.hour, minute: 59, second: 59)
    }

    @objc func toHKQuantitySample() -> HKQuantitySample {

        let stepCountQuantity = HKQuantity(unit:HKUnit.kilocalorie(), doubleValue: mCalories)
        return HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            quantity: stepCountQuantity,
            start: mCalories_Date, end: lateNight)
    }

    @objc func isUpdate()->Bool {return false}
}
