//
//  HourlySteps.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 24/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import HealthKit

class HourlySteps : NevoHKDataPoint {
    
    private var mNumberOfSteps:Int
    private var mDate:NSDate
    private var mHour:Int
    
    init(numberOfSteps:Int, date:NSDate,hour:Int) {
        mNumberOfSteps=numberOfSteps
        mHour = hour
        
        //Here, we normalise the date
        //It's a daily data point, so we normalise it to midnight
        
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        
        mDate = cal.dateBySettingHour(mHour, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
        
    }
    
    func toHKQuantitySample() -> HKQuantitySample {
        
        let stepCountQuantity = HKQuantity(unit:HKUnit.countUnit(), doubleValue: Double(mNumberOfSteps))
        
        
        //A hourly data point if from hh:00:00 to hh:59:59
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        
        let lateNight = cal.dateBySettingHour(0, minute: 59, second: 59, ofDate: mDate, options: NSCalendarOptions())!
        
        return HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            quantity: stepCountQuantity,
            startDate: mDate, endDate: lateNight)
    }
    
}