//
//  StepsNetworkController.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class MEDStepsNetworkManager: NSObject {
    
    class func createSteps(uid:Int, steps:String, date:String, activeTime:Int,calories: Int, distance: Double, completion:@escaping ((_ created:Bool) -> Void)){
        MEDNetworkManager.execute(request: MEDStepsCreateRequest(uid: uid, value: steps, date: date, activeTime: activeTime, calories: calories, distance: distance, responseBlock: { (success, optionalJson, optionalError) in
            if success, let _ = optionalJson {
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
    
    class func updateSteps(id:Int, uid:Int, steps:String, date:String, activeTime:Int, calories:Int, distance:Double, completion: @escaping ((_ updated:Bool)->Void)){
        MEDNetworkManager.execute(request: MEDStepsUpdateRequest(id: id, uid: uid, steps: steps, date: date, activeTime: activeTime, calories: calories, distance: distance, responseBlock: { (success, optionalJson, optionalError) in
            if success, let _ = optionalJson{
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
    
    class func stepsForDate(uid:Int, date:Date, completion:@escaping ( _ result:
        (requestSuccess:Bool, databaseSaved:Bool)) -> Void){
        print(date.description)
        let startDateInt = Int(date.beginningOfDay.timeIntervalSince1970)
        print("Start Date \(date.beginningOfDay.description)")
        let endDateInt = Int(date.endOfDay.timeIntervalSince1970)
        print("End Date \(date.endOfDay.description)")
        MEDNetworkManager.execute(request: MEDStepsGetRequest(uid: uid, startDate: startDateInt, endDate: endDateInt, responseBlock: { success, json, error in
            if success, let unpackedJson = json {
                completion(handleResponse(json: unpackedJson))
            }else{
                completion((requestSuccess: false, databaseSaved: false))
            }
        }))
    }
    
    class func stepsForPeriod(uid:Int,startDate:Date, endDate:Date, completion:@escaping ( _ result:
        (requestSuccess:Bool, databaseSaved:Bool)) -> Void){
        let startDateInt = Int(startDate.beginningOfDay.timeIntervalSince1970)
        print("Start Date \(startDate.beginningOfDay.description)")
        let endDateInt = Int(endDate.endOfDay.timeIntervalSince1970)
        print("End Date \(endDate.endOfDay.description)")
        
        MEDNetworkManager.execute(request: MEDStepsGetRequest(uid: uid, startDate: startDateInt, endDate: endDateInt, responseBlock: { success, json, error in
            if success, let unpackedJson = json {
                completion(handleResponse(json: unpackedJson))
            }else{
                completion((requestSuccess: false, databaseSaved: false))
            }
        }))
        
    }
    
    private class func handleResponse(json:JSON) -> (requestSuccess:Bool,databaseSaved:Bool){
        let steps = json["steps"]
        var successSynced = true
        let dateString = steps["date"]["date"].stringValue
        let stepsString = steps["steps"].description
        let cid:Int = steps["id"].intValue
        
        let dateArray = dateString.components(separatedBy: " ")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateArray[0])
        let dateTimerInterval  = date?.beginningOfDay.timeIntervalSince1970
        let stepsArray:[Any] = stepsString.jsonToArray()
            //AppTheme.jsonToArray(stepsString)
        for (hourIndex,hourValue) in stepsArray.enumerated() {
            var seconds:Int = hourIndex*60*60
            for (minuteIndex,minuteValue) in (hourValue as! [Int]).enumerated() {
                if Int(minuteValue)>0 {
                    seconds += (minuteIndex*5)*60
                    let queryArray = MEDUserSteps.getFilter("date == \(Double(dateTimerInterval!+Double(seconds)).toDouble())")
                    if queryArray.count == 0 {
                        let steps:MEDUserSteps = MEDUserSteps()
                        steps.cid = cid
                        steps.totalSteps = Int(minuteValue)
                        steps.distance = 0
                        steps.date = Double(dateTimerInterval!+Double(seconds)).toDouble()
                        if successSynced {
                            successSynced = steps.add()
                        }
                    } else {
                        for (_,value3) in queryArray.enumerated() {
                            let steps:MEDUserSteps = value3 as! MEDUserSteps
                            steps.totalSteps = Int(minuteValue)
                            let realm = try! Realm()
                            try! realm.write {
                                steps.cid = cid
                            }
                        }
                    }
                }
            }
        }
        return (true, successSynced)
    }
}
