//
//  ValidicRequest.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/14.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import XCGLogger

let ValidicOrganizationID = "56d3b075407e010001000000"
let OrganizationAccessToken = "b85dcb3b85e925200f3fd4cafe6dce92295f449d9596b137941de7e9e2c3e7ae"
let ValidicAuthorizedKey = "Nevo_ValidicAuthorized"

let UPDATE_VALIDIC_REQUEST:ValidicRequest = ValidicRequest()

class ValidicRequest: NSObject {

    // MARK: - Request func
    class func validicPostJSONRequest(url: String, data:Dictionary<String,AnyObject>, completion:(result:NSDictionary) -> Void){
        debugPrint("accessData:\(data)")
        Alamofire.request(.POST, url, parameters: data ,encoding: .JSON, headers: ["Content-Type":"application/json"]).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                completion(result: response.result.value! as! NSDictionary)
            }else if (response.result.isFailure){
                if response.result.value != nil {
                    completion(result: response.result.value! as! NSDictionary)
                }else{
                    completion(result: NSDictionary(dictionary: ["code": 500,"message": "Authorized",]))
                }
            }
        }
    }
    
    class func deleteValidicRequest(url: String, data:Dictionary<String,AnyObject>, completion:(result:NSDictionary) -> Void){
        //debugPrint("accessData:\(data)")
        Alamofire.request(.DELETE, url, parameters: data ,encoding: .JSON, headers: ["Content-Type":"application/json"]).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                completion(result: response.result.value! as! NSDictionary)
            }else if (response.result.isFailure){
                if response.result.value != nil {
                    completion(result: response.result.value! as! NSDictionary)
                }else{
                    completion(result: NSDictionary(dictionary: ["code": 500,"message": "Authorized",]))
                }
            }
        }
    }
    
    // MARK: - Instantiation function
    /**
     Instantiation function,Upload the update user steps
     
     - parameter array: <#array description#>
     */
    func updateToValidic(array:NSArray?) {
        var stepsArray:NSArray = NSArray()
        if array == nil {
            stepsArray = UserSteps.getAll()
        }else{
            stepsArray = array!.copy() as! NSArray
        }
        
        var array:[[String : AnyObject]] = []
        let timeZone: Int = NSTimeZone.systemTimeZone().secondsFromGMT/3600
        
        for steps in stepsArray{
            let userSteps:UserSteps = steps as! UserSteps
            let hourlySteps = AppTheme.jsonToArray(userSteps.hourlysteps)
            let hourlyCalories = AppTheme.jsonToArray(userSteps.hourlycalories)
            let hourlyDistance = AppTheme.jsonToArray(userSteps.hourlydistance)
            var stepsValue:Int = 0
            var distanceValue:Int = 0
            var caloriesValue:Int = 0
            for (index,value) in hourlySteps.enumerate() {
                if (value as! NSNumber).integerValue != 0 {
                    stepsValue += (value as! NSNumber).integerValue
                    distanceValue += (hourlyDistance[index] as! NSNumber).integerValue
                    caloriesValue += (hourlyCalories[index] as! NSNumber).integerValue
                }
            }
            
            let timeInterval = userSteps.date
            var detail:[String : AnyObject] = [:]
            detail["timestamp"] = ValidicRequest.formatterDate(NSDate(timeIntervalSince1970: timeInterval))
            if timeZone>0{
                if "\(timeZone)".lengthOfBytesUsingEncoding(NSUTF8StringEncoding)==1 {
                    detail["utc_offset"] = "+0\(timeZone):00"
                }else{
                    detail["utc_offset"] = "+\(timeZone):00"
                }
                
            }else{
                if "\(timeZone)".lengthOfBytesUsingEncoding(NSUTF8StringEncoding)==2 {
                    var string:String = "\(timeZone):00"
                    string.insert("0", atIndex: string.startIndex.advancedBy(1))
                    detail["utc_offset"] = string
                }else{
                    detail["utc_offset"] = "\(timeZone):00"
                }
            }
            detail["steps"] = stepsValue
            detail["distance"] = distanceValue
            detail["floors"] = 0
            detail["elevation"] = 0
            detail["calories_burned"] = caloriesValue
            detail["activity_id"] = "\(timeInterval)"
            array.append(detail)
        }
        
        var _id:String = " "
        var URL = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey(ValidicAuthorizedKey) != nil {
            _id = "\((NSUserDefaults.standardUserDefaults().objectForKey(ValidicAuthorizedKey) as! NSDictionary).objectForKey("_id")!)"
            URL = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users/\(_id)/routine.json"
        }else{
            //If there is validic no authorization is not upload data
            return;
        }
        
        //create steps network global queue
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        
        for object in array{
            dispatch_group_async(group, queue, {
                let data = ["routine":object,"access_token":"\(OrganizationAccessToken)"]
                self.updateValidicData(URL,data: data as! Dictionary<String, AnyObject>, completion: { (result) in
                    XCGLogger.defaultInstance().debug("updateValidicData: \(result)")
                })
            })
        }
        
        dispatch_group_notify(group, queue, {
            XCGLogger.defaultInstance().debug("create steps completed")
        })
    }
    
    private func updateValidicData(URL:String,data:Dictionary<String,AnyObject>,completion:(result:NSDictionary) -> Void)  {
        
        ValidicRequest.validicPostJSONRequest(URL, data: data) { (result) in
            completion(result: result)
        }
    }
    
    class func formatterDate(date:NSDate)->String {
        let dateArray = "\(date.beginningOfDay)".componentsSeparatedByString(" ")
        let startIndex = dateArray[2].startIndex.advancedBy(0)
        let endIndex = dateArray[2].startIndex.advancedBy(3)
        let dateString = dateArray[0]+"T"+dateArray[1]+dateArray[2].substringWithRange(Range(startIndex..<endIndex))
        return dateString+":"+"00"
    }
    
    func deleteValidicUser(uid:String) {
        let URL = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users.json"
        let data = ["uid":uid,"access_token":"\(OrganizationAccessToken)"]
        ValidicRequest.deleteValidicRequest(URL,data: data, completion: { (result) in
            XCGLogger.defaultInstance().debug("deleteValidic User: \(result)")
        })
    }
}
