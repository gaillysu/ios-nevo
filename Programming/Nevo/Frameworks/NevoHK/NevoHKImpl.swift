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
    func writeDataPoint(data:NevoHKDataPoint,resultHandler:((result:Bool?,error:NSError?) -> Void)) {

        isPresent(data, handler:  { (present,object) -> Void in
            
            //We only write this data point if it isn't present in HK
            if( present != true) {
                
                self.mHealthKitStore.saveObject(data.toHKQuantitySample(), withCompletion: { (success, error) -> Void in
                    if( error != nil ) {
                        println("Error saving sample: \(error.localizedDescription)")
                        resultHandler(result: false,error: error as NSError)
                    } else {
                        println("Saved in Health Kit : \(data.toHKQuantitySample())")
                        resultHandler(result: true,error: nil)
                    }
                })
                
            } else {
                
                if data.isUpdate()
                {
                self.mHealthKitStore.deleteObject(object! as HKQuantitySample, withCompletion: { (success, error) -> Void in
                    if( error != nil ) {
                        println("Error delete sample: \(error.localizedDescription)")
                        
                    } else {
                        println("Success delete in Health Kit : \(object! as HKQuantitySample)")
                    }
                })
                
                self.mHealthKitStore.saveObject(data.toHKQuantitySample(), withCompletion: { (success, error) -> Void in
                    if( error != nil ) {
                        println("Error saving sample: \(error.localizedDescription)")
                        resultHandler(result: false,error: error as NSError)
                    } else {
                        println("Saved in Health Kit : \(data.toHKQuantitySample())")
                        resultHandler(result: true,error: nil)
                    }
                })
                }
                else
                {
                resultHandler(result:false,error:NSError(domain:"Can't save Health Kit. Already present or Health Kit autorisation wasn't given : \(data.toHKQuantitySample())" , code: 404, userInfo: nil))
                }

            }
            
        })

        
    }
    
    /**
    See NevoHK protocol
    */
    func isPresent(data:NevoHKDataPoint, handler:( (Bool?,HKQuantitySample?) -> Void) ) {
        let sample = data.toHKQuantitySample()
        //Check if this data point is present in HK

        let datePredicate = HKQuery.predicateForSamplesWithStartDate(sample.startDate,
            endDate: sample.endDate, options: .None)
        
        let sourcePredicate:NSPredicate = HKQuery.predicateForObjectsFromSource(HKSource.defaultSource());
        
        let dateAndSourcePredicate = NSCompoundPredicate.andPredicateWithSubpredicates([datePredicate,sourcePredicate])
        
        let query = HKSampleQuery(sampleType: sample.quantityType, predicate: dateAndSourcePredicate,
            limit: 1, sortDescriptors: nil, resultsHandler: {
                (query, results, error) in
                
                if error != nil {
                    //In case of error, it probably means that we don't have the autorisation to access HK
                    //Or that we are not in a HK capable device
                    handler(nil,nil)
                    return;
                }
                
                else {
                    //If there's no error, if we have a result, then the data is present, if we don't it's absent
                    handler( results != nil && results.count >= 1 ,(results != nil && results.count >= 1) ?results[0] as? HKQuantitySample:nil)
                    return;

                }

        })
        
        mHealthKitStore.executeQuery(query)
        
    }
}