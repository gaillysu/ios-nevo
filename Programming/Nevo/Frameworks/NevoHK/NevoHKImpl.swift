//
//  NevoHKImpl.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 24/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import HealthKit

/**
See NevoHK protocol
*/
class NevoHKImpl {
    private let mHealthKitStore = HKHealthStore()
    
    /**
    See NevoHK protocol
    */
    func requestPermission() {
        authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
            }
            else
            {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            ])
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            ])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.nevowatch.nevo", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        mHealthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    /**
    See NevoHK protocol
    */
    func writeDataPoint(data:NevoHKDataPoint) {
        
        let present = isPresent(data)
        
        //We only write this data point if it isn't present in HK
        if( present != false) {
            
            mHealthKitStore.saveObject(data.toHKQuantitySample(), withCompletion: { (success, error) -> Void in
                if( error != nil ) {
                    println("Error saving sample: \(error.localizedDescription)")
                } else {
                    println("New sample saved successfully!")
                }
            })
            
        }
        
    }
    
    /**
    See NevoHK protocol
    */
    func isPresent(NevoHKDataPoint) -> Bool? {
            //TODO by Hugo
            //Check if this data point is present in HK
        return false
    }
}