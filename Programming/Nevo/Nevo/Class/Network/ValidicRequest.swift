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
    var index:Int = 1
    var sleepIndex:Int = 1
    
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
    
    
    class func getValidicRequest(url: String, data:Dictionary<String,AnyObject>?, completion:(result:NSDictionary) -> Void){
        //debugPrint("accessData:\(data)")
        Alamofire.request(.GET, url, parameters: data ,encoding: .JSON).responseJSON { (response) -> Void in
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
    
    class func formatterDate(date:NSDate)->String {
        let dateArray = "\(date.beginningOfDay)".componentsSeparatedByString(" ")
        let startIndex = dateArray[2].startIndex.advancedBy(0)
        let endIndex = dateArray[2].startIndex.advancedBy(3)
        let dateString = dateArray[0]+"T"+dateArray[1]+dateArray[2].substringWithRange(Range(startIndex..<endIndex))
        return dateString+":"+"00"
    }
    
    class func formatterUTCOffset(timeZone:Int)->String {
        if timeZone>0{
            if "\(timeZone)".lengthOfBytesUsingEncoding(NSUTF8StringEncoding)==1 {
                return "+0\(timeZone):00"
            }else{
                return "+\(timeZone):00"
            }
            
        }else{
            if "\(timeZone)".lengthOfBytesUsingEncoding(NSUTF8StringEncoding)==2 {
                var string:String = "\(timeZone):00"
                string.insert("0", atIndex: string.startIndex.advancedBy(1))
                return string
            }else{
                return "\(timeZone):00"
            }
        }
    }
    
    /**
     If there is validic no authorization is not upload data
     
     - returns: authorization state
     */
    class func isValidicAuthorization()->Bool {
        if NSUserDefaults.standardUserDefaults().objectForKey(ValidicAuthorizedKey) != nil {
            return true
        }else{
            return false
        }
    }
    
    /**
     Cancel validic the authorization
     */
    class func cancelAuthorization() {
        if ValidicRequest.isValidicAuthorization() {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(ValidicAuthorizedKey)
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
            detail["utc_offset"] = ValidicRequest.formatterUTCOffset(timeZone)
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
        
        if ValidicRequest.isValidicAuthorization() {
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
    
    func updateSleepDataToValidic(array:NSArray?) {
        var sleepArray:NSArray = NSArray()
        if array == nil {
            sleepArray = UserSleep.getAll()
        }else{
            sleepArray = array!.copy() as! NSArray
        }
        
        var array:[[String : AnyObject]] = []
        let timeZone: Int = NSTimeZone.systemTimeZone().secondsFromGMT/3600
        
        for steps in sleepArray{
            let userSleep:UserSleep = steps as! UserSleep
            let hourlySleep = AppTheme.jsonToArray(userSleep.hourlySleepTime)
            let hourlyWakeTime = AppTheme.jsonToArray(userSleep.hourlyWakeTime)
            let hourlyLightTime = AppTheme.jsonToArray(userSleep.hourlyLightTime)
            let hourlyDeepTime = AppTheme.jsonToArray(userSleep.hourlyDeepTime)
            
            var awake:Int = 0
            var deep:Int = 0
            var light:Int = 0
            var totalSleep:Int = 0
            
            for (index,value) in hourlySleep.enumerate() {
                if (value as! NSNumber).integerValue != 0 {
                    totalSleep += (value as! NSNumber).integerValue
                    awake = (hourlyWakeTime[index] as! NSNumber).integerValue
                    deep = (hourlyDeepTime[index] as! NSNumber).integerValue
                    light = (hourlyLightTime[index] as! NSNumber).integerValue
                }
            }
            let timeInterval = userSleep.date
            var detail:[String : AnyObject] = [:]
            detail["timestamp"] = ValidicRequest.formatterDate(NSDate(timeIntervalSince1970: timeInterval))
            detail["utc_offset"] = ValidicRequest.formatterUTCOffset(timeZone)
            detail["awake"] = awake
            detail["deep"] = deep
            detail["light"] = light
            detail["rem"] = 0
            detail["times_woken"] = 0
            detail["total_sleep"] = "\(totalSleep)"
            detail["activity_id"] = "\(timeInterval)"
            detail["validated"] = false
            detail["device"] = ""
            array.append(detail)
        }
        
        var _id:String = " "
        var URL = ""
        
        if ValidicRequest.isValidicAuthorization() {
            _id = "\((NSUserDefaults.standardUserDefaults().objectForKey(ValidicAuthorizedKey) as! NSDictionary).objectForKey("_id")!)"
            URL = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users/\(_id)/sleep.json"
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
    
    func downloadValidicData() {
        if ValidicRequest.isValidicAuthorization() {
            let _id:String = "\((NSUserDefaults.standardUserDefaults().objectForKey(ValidicAuthorizedKey) as! NSDictionary).objectForKey("_id")!)"
            let startDate:NSDate = NSDate(timeIntervalSince1970: NSDate().beginningOfDay.timeIntervalSince1970-365*86400)
            let endDate:NSDate = NSDate().endOfDay
            let URL:String = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users/\(_id)/routine/latest.json?access_token=\(OrganizationAccessToken)&start_date=\(ValidicRequest.formatterDate(startDate))&end_date=\(ValidicRequest.formatterDate(endDate))&limit=200&page=\(index)"
            
            ValidicRequest.getValidicRequest(URL, data: nil) { (result) in
                let json = JSON(result)
                let routineArray:[JSON] = json["routine"].arrayValue
                if routineArray.count>0 {
                    for value in routineArray {
                        self.analyticalData(value)
                    }
                    self.downloadValidicData()
                }else{
                    self.index = 1
                    self.downloadValidicSleepData()
                }
            }
            index += 1
        }
    }
    
    func downloadValidicSleepData() {
        if ValidicRequest.isValidicAuthorization() {
            let _id:String = "\((NSUserDefaults.standardUserDefaults().objectForKey(ValidicAuthorizedKey) as! NSDictionary).objectForKey("_id")!)"
            let startDate:NSDate = NSDate(timeIntervalSince1970: NSDate().beginningOfDay.timeIntervalSince1970-365*86400)
            let endDate:NSDate = NSDate().endOfDay
            let URL:String = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users/\(_id)/sleep/latest.json?access_token=\(OrganizationAccessToken)&start_date=\(ValidicRequest.formatterDate(startDate))&end_date=\(ValidicRequest.formatterDate(endDate))&limit=200&page=\(index)"
            
            ValidicRequest.getValidicRequest(URL, data: nil) { (result) in
                let json = JSON(result)
                let routineArray:[JSON] = json["sleep"].arrayValue
                if routineArray.count>0 {
                    for value in routineArray {
                        self.analyticalSleepData(value)
                    }
                    self.downloadValidicSleepData()
                }else{
                    self.sleepIndex = 1
                }
            }
            sleepIndex += 1
        }
    }
    
    func deleteValidicUser(uid:String) {
        let URL = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users.json"
        let data = ["uid":uid,"access_token":"\(OrganizationAccessToken)"]
        ValidicRequest.deleteValidicRequest(URL,data: data, completion: { (result) in
            XCGLogger.defaultInstance().debug("deleteValidic User: \(result)")
        })
    }
    
    func analyticalData(object:JSON) {
        XCGLogger.defaultInstance().debug("\(object)")
        var timer = object["timestamp"].stringValue.stringByReplacingOccurrencesOfString("T", withString: " ")
        timer = timer.stringByReplacingOccurrencesOfString("+00:00", withString: "")
        let date = GmtNSDate2LocaleNSDate(timer.dateFromFormat("yyyy-MM-dd HH:mm:ss'UTC'")!)
        var steps:[String:AnyObject] = [:]
        steps["steps"] = object["steps"].intValue
        steps["hourlysteps"] = "[0,0,0,0,0,0,0,0,\(object["steps"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
        steps["distance"] = object["distance"].intValue
        steps["hourlydistance"] = "[0,0,0,0,0,0,0,0,\(object["distance"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
        steps["calories"] = object["calories_burned"].doubleValue
        steps["hourlycalories"] = "[0,0,0,0,0,0,0,0,\(object["calories_burned"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
        steps["date"] = date.timeIntervalSince1970
        steps["createDate"] = date.stringFromFormat("yyyyMMdd")
        steps["validic_id"] = object["_id"].stringValue
        let userSteps:NSArray = UserSteps.getCriteria("WHERE createDate = \(steps["createDate"]!)")
        if userSteps.count == 0 {
            let userSteps:UserSteps = UserSteps(keyDict: steps)
            userSteps.add { (id, completion) in
                
            }
        }
    }
    
    func analyticalSleepData(object:JSON) {
        XCGLogger.defaultInstance().debug("\(object)")
        var timer = object["timestamp"].stringValue.stringByReplacingOccurrencesOfString("T", withString: " ")
        timer = timer.stringByReplacingOccurrencesOfString("+00:00", withString: "")
        let date = GmtNSDate2LocaleNSDate(timer.dateFromFormat("yyyy-MM-dd HH:mm:ss'UTC'")!)
        
        let awakeSleep:Int = object["awake"].intValue
        let awakeDeep:Int = object["deep"].intValue
        let lightSleep:Int = object["light"].intValue
        
        var sleep:[String:AnyObject] = [:]
        sleep["_id"] = object["_id"].stringValue
        sleep["date"] = date.timeIntervalSince1970
        sleep["totalSleepTime"] = object["total_sleep"].intValue
        sleep["hourlySleepTime"] = "[0,\(object["total_sleep"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
        sleep["totalWakeTime"] = awakeSleep
        sleep["hourlyWakeTime"] = "[0,\(awakeSleep),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
        sleep["totalLightTime"] = lightSleep
        sleep["hourlyLightTime"] = "[0,\(lightSleep),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
        sleep["totalDeepTime"] = awakeDeep
        sleep["hourlyDeepTime"] = "[0,\(awakeDeep),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"
        let userSteps:NSArray = UserSleep.getCriteria("WHERE createDate = \(sleep["createDate"]!)")
        if userSteps.count == 0 {
            let userSteps:UserSleep = UserSleep(keyDict: sleep)
            userSteps.add { (id, completion) in
                
            }
        }
    }
}
