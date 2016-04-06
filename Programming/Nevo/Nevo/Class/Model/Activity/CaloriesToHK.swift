//
//  CaloriesToHK.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/21.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import HealthKit

class CaloriesToHK: NevoHKDataPoint {
    
    private var mCalories:Double
    private var mCalories_Date:NSDate
    private var lateNight:NSDate

    init(calories:Double, date:NSDate) {
        mCalories=calories

        mCalories_Date = NSDate().change(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)
        //A daily data point if from 00AM to 23:59:59
        lateNight = NSDate().change(year: date.year, month: date.month, day: date.day, hour: date.hour, minute: 59, second: 59)
    }

    @objc func toHKQuantitySample() -> HKQuantitySample {

        let stepCountQuantity = HKQuantity(unit:HKUnit.kilocalorieUnit(), doubleValue: mCalories)
        return HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            quantity: stepCountQuantity,
            startDate: mCalories_Date, endDate: lateNight)
    }

    @objc func isUpdate()->Bool {return false}
}
