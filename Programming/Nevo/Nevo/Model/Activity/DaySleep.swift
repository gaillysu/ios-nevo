//
//  DailySteps.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 24/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import HealthKit

/**
This class contains a data point  of how many steps was done at a particular day
*/
class DaySleep : NevoHKDataPoint {
    
    private var mNumberOfSleeps:Int
    private var mDate:NSDate
    private var lateNight:NSDate
    private var mIsAsleep:Bool
    
    init(isAsleep:Bool, numberOfSleeps:Int, startDate:NSDate,endDate:NSDate) {
        mNumberOfSleeps=numberOfSleeps
        //Here, we normalise the date
        //It's a daily data point, so we normalise it to midnight
        mDate = startDate
        //A daily data point if from 00AM to 23:59:59
        lateNight = endDate

        mIsAsleep = isAsleep;
    }

    @objc func toHKQuantitySample() -> HKQuantitySample {
        return HKQuantitySample()
    }
    @objc func isUpdate()->Bool {return false}

    @objc func toHKCategorySample()-> HKCategorySample {
        //(HKCategoryValueSleepAnalysis.Asleep) : (HKCategoryValueSleepAnalysis.InBed)
        let sleepType = mIsAsleep ? 0 : 1

        let categoryType:HKCategoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        let sleepSample:HKCategorySample = HKCategorySample(type: categoryType, value: sleepType, startDate: mDate, endDate: lateNight);
        return sleepSample
    }
}