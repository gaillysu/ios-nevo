//
//  ValidicRequest.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/14.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Alamofire

let ValidicOrganizationID = "56d3b075407e010001000000"
let OrganizationAccessToken = "b85dcb3b85e925200f3fd4cafe6dce92295f449d9596b137941de7e9e2c3e7ae"
let ValidicAuthorizedKey = "Nevo_ValidicAuthorized"

let UPDATE_VALIDIC_REQUEST:ValidicRequest = ValidicRequest()

class ValidicRequest: NSObject {
    var index:Int = 1
    var sleepIndex:Int = 1
    
    // MARK: - Request func
    class func validicPostJSONRequest(_ url: String, data:Dictionary<String,AnyObject>, completion:@escaping (_ result:NSDictionary) -> Void){
        debugPrint("accessData:\(data)")
        let urls = URL(string: url)!
        let parameters: Parameters = data
        let encode:ParameterEncoding = JSONEncoding.default
        
        Alamofire.request(urls, method: .post, parameters: parameters, encoding: encode, headers: ["Content-Type":"application/json"]).responseJSON { (response) in
            if response.result.isSuccess {
                completion(response.result.value! as! NSDictionary)
            }else if (response.result.isFailure){
                if response.result.value != nil {
                    completion(response.result.value! as! NSDictionary)
                }else{
                    completion(NSDictionary(dictionary: ["code": 500,"message": "Authorized",]))
                }
            }
        }

    }
    
    class func deleteValidicRequest(_ url: String, data:Dictionary<String,AnyObject>, completion:@escaping (_ result:NSDictionary) -> Void){
        //debugPrint("accessData:\(data)")
        let urls = URL(string: url)!
        let parameters: Parameters = data
        let encode:ParameterEncoding = JSONEncoding.default
        
        Alamofire.request(urls, method: .delete, parameters: parameters, encoding: encode, headers: ["Content-Type":"application/json"]).responseJSON { (response) in
            if response.result.isSuccess {
                completion(response.result.value! as! NSDictionary)
            }else if (response.result.isFailure){
                if response.result.value != nil {
                    completion(response.result.value! as! NSDictionary)
                }else{
                    completion(NSDictionary(dictionary: ["code": 500,"message": "Authorized",]))
                }
            }
        }
    }
    
    
    class func getValidicRequest(_ url: String, data:Dictionary<String,AnyObject>?, completion:@escaping (_ result:NSDictionary) -> Void){
        //debugPrint("accessData:\(data)")
        let urls = URL(string: url)!
        let parameters: Parameters = data!
        let encode:ParameterEncoding = JSONEncoding.default
        
        Alamofire.request(urls, method: .get, parameters: parameters, encoding: encode, headers: ["Content-Type":"application/json"]).responseJSON { (response) in
            if response.result.isSuccess {
                completion(response.result.value! as! NSDictionary)
            }else if (response.result.isFailure){
                if response.result.value != nil {
                    completion(response.result.value! as! NSDictionary)
                }else{
                    completion(NSDictionary(dictionary: ["code": 500,"message": "Authorized",]))
                }
            }
        }
    }
    
    class func formatterDate(_ date:Date)->String {
        let dateArray = "\(date.beginningOfDay)".components(separatedBy: " ")
        let startIndex = dateArray[2].characters.index(dateArray[2].startIndex, offsetBy: 0)
        let endIndex = dateArray[2].characters.index(dateArray[2].startIndex, offsetBy: 3)
        let dateString = dateArray[0]+"T"+dateArray[1]+dateArray[2].substring(with: Range(startIndex..<endIndex))
        return dateString+":"+"00"
    }
    
    class func formatterUTCOffset(_ timeZone:Int)->String {
        if timeZone>0{
            if "\(timeZone)".lengthOfBytes(using: String.Encoding.utf8)==1 {
                return "+0\(timeZone):00"
            }else{
                return "+\(timeZone):00"
            }
            
        }else{
            if "\(timeZone)".lengthOfBytes(using: String.Encoding.utf8)==2 {
                var string:String = "\(timeZone):00"
                string.insert("0", at: string.characters.index(string.startIndex, offsetBy: 1))
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
        if UserDefaults.standard.object(forKey: ValidicAuthorizedKey) != nil {
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
            UserDefaults.standard.removeObject(forKey: ValidicAuthorizedKey)
        }
    }
    
    // MARK: - Instantiation function
    /**
     Instantiation function,Upload the update user steps
     
     - parameter array: <#array description#>
     */
    func updateToValidic(_ array:NSArray?) {
        var stepsArray:NSArray = NSArray()
        if array == nil {
            stepsArray = UserSteps.getAll()
        }else{
            stepsArray = array!.copy() as! NSArray
        }
        
        var array:[[String : AnyObject]] = []
        let timeZone: Int = NSTimeZone.system.secondsFromGMT()/3600
        //TimeZone.secondsFromGMT(<#T##TimeZone#>)
        
        for steps in stepsArray{
            let userSteps:UserSteps = steps as! UserSteps
            let hourlySteps = AppTheme.jsonToArray(userSteps.hourlysteps)
            let hourlyCalories = AppTheme.jsonToArray(userSteps.hourlycalories)
            let hourlyDistance = AppTheme.jsonToArray(userSteps.hourlydistance)
            var stepsValue:Int = 0
            var distanceValue:Int = 0
            var caloriesValue:Int = 0
            for (index,value) in hourlySteps.enumerated() {
                if (value as! NSNumber).intValue != 0 {
                    stepsValue += (value as! NSNumber).intValue
                    distanceValue += (hourlyDistance[index] as! NSNumber).intValue
                    caloriesValue += (hourlyCalories[index] as! NSNumber).intValue
                }
            }
            
            let timeInterval = userSteps.date
            var detail:[String : AnyObject] = [:]
            detail["timestamp"] = ValidicRequest.formatterDate(Date(timeIntervalSince1970: timeInterval)) as AnyObject?
            detail["utc_offset"] = ValidicRequest.formatterUTCOffset(timeZone) as AnyObject?
            detail["steps"] = stepsValue as AnyObject?
            detail["distance"] = distanceValue as AnyObject?
            detail["floors"] = 0 as AnyObject?
            detail["elevation"] = 0 as AnyObject?
            detail["calories_burned"] = caloriesValue as AnyObject?
            detail["activity_id"] = "\(timeInterval)" as AnyObject?
            array.append(detail)
        }
        
        var _id:String = " "
        var URL = ""
        
        if ValidicRequest.isValidicAuthorization() {
            _id = "\((UserDefaults.standard.object(forKey: ValidicAuthorizedKey) as! NSDictionary).object(forKey: "_id")!)"
            URL = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users/\(_id)/routine.json"
        }else{
            //If there is validic no authorization is not upload data
            return;
        }
        
        //create steps network global queue
        let queue:DispatchQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let group = DispatchGroup()
        
        for object in array{
            queue.async(group: group, execute: {
                let data = ["routine":object,"access_token":"\(OrganizationAccessToken)"] as [String : Any]
                self.updateValidicData(URL,data: data as Dictionary<String, AnyObject>, completion: { (result) in
                    XCGLogger.defaultInstance().debug("updateValidicData: \(result)")
                })
            })
        }
        
        group.notify(queue: queue, execute: {
            XCGLogger.defaultInstance().debug("create steps completed")
            self.updateSleepDataToValidic(nil)
        })
    }
    
    func updateSleepDataToValidic(_ array:NSArray?) {
        var sleepArray:NSArray = NSArray()
        if array == nil {
            sleepArray = UserSleep.getAll()
        }else{
            sleepArray = array!.copy() as! NSArray
        }
        
        var array:[[String : AnyObject]] = []
        let timeZone: Int = NSTimeZone.system.secondsFromGMT()/3600

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
            
            for (index,value) in hourlySleep.enumerated() {
                if (value as! NSNumber).intValue != 0 {
                    totalSleep += (value as! NSNumber).intValue
                    awake = (hourlyWakeTime[index] as! NSNumber).intValue
                    deep = (hourlyDeepTime[index] as! NSNumber).intValue
                    light = (hourlyLightTime[index] as! NSNumber).intValue
                }
            }
            let timeInterval = userSleep.date
            var detail:[String : AnyObject] = [:]
            detail["timestamp"] = ValidicRequest.formatterDate(Date(timeIntervalSince1970: timeInterval)) as AnyObject?
            detail["utc_offset"] = ValidicRequest.formatterUTCOffset(timeZone) as AnyObject?
            detail["awake"] = awake as AnyObject?
            detail["deep"] = deep as AnyObject?
            detail["light"] = light as AnyObject?
            detail["rem"] = 0 as AnyObject?
            detail["times_woken"] = 0 as AnyObject?
            detail["total_sleep"] = "\(totalSleep)" as AnyObject?
            detail["activity_id"] = "\(timeInterval)" as AnyObject?
            detail["validated"] = false as AnyObject?
            detail["device"] = "" as AnyObject?
            array.append(detail)
        }
        
        var _id:String = " "
        var URL = ""
        
        if ValidicRequest.isValidicAuthorization() {
            _id = "\((UserDefaults.standard.object(forKey: ValidicAuthorizedKey) as! NSDictionary).object(forKey: "_id")!)"
            URL = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users/\(_id)/sleep.json"
        }else{
            //If there is validic no authorization is not upload data
            return;
        }
        
        //create steps network global queue
        let queue:DispatchQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let group = DispatchGroup()
        
        for object in array{
            queue.async(group: group, execute: {
                let data = ["routine":object,"access_token":"\(OrganizationAccessToken)"] as [String : Any]
                self.updateValidicData(URL,data: data as Dictionary<String, AnyObject>, completion: { (result) in
                    XCGLogger.defaultInstance().debug("updateValidicData: \(result)")
                })
            })
        }
        
        group.notify(queue: queue, execute: {
            XCGLogger.defaultInstance().debug("create steps completed")
        })
    }
    
    fileprivate func updateValidicData(_ URL:String,data:Dictionary<String,AnyObject>,completion:@escaping (_ result:NSDictionary) -> Void)  {
        ValidicRequest.validicPostJSONRequest(URL, data: data) { (result) in
            completion(result)
        }
    }
    
    func downloadValidicData() {
        if ValidicRequest.isValidicAuthorization() {
            let _id:String = "\((UserDefaults.standard.object(forKey: ValidicAuthorizedKey) as! NSDictionary).object(forKey: "_id")!)"
            let startDate:Date = Date(timeIntervalSince1970: Date().beginningOfDay.timeIntervalSince1970-365*86400)
            let endDate:Date = Date().endOfDay
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
            let _id:String = "\((UserDefaults.standard.object(forKey: ValidicAuthorizedKey) as! NSDictionary).object(forKey: "_id")!)"
            let startDate:Date = Date(timeIntervalSince1970: Date().beginningOfDay.timeIntervalSince1970-365*86400)
            let endDate:Date = Date().endOfDay
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
    
    func deleteValidicUser(_ uid:String) {
        let URL = "https://api.validic.com/v1/organizations/\(ValidicOrganizationID)/users.json"
        let data = ["uid":uid,"access_token":"\(OrganizationAccessToken)"]
        ValidicRequest.deleteValidicRequest(URL,data: data as Dictionary<String, AnyObject>, completion: { (result) in
            XCGLogger.defaultInstance().debug("deleteValidic User: \(result)")
        })
    }
    
    func analyticalData(_ object:JSON) {
        XCGLogger.defaultInstance().debug("\(object)")
        var timer = object["timestamp"].stringValue.replacingOccurrences(of: "T", with: " ")
        timer = timer.replacingOccurrences(of: "+00:00", with: "")
        let date = GmtNSDate2LocaleNSDate(timer.dateFromFormat("yyyy-MM-dd HH:mm:ss'UTC'")!)
        var steps:[String:AnyObject] = [:]
        steps["steps"] = object["steps"].intValue as AnyObject?
        steps["hourlysteps"] = "[0,0,0,0,0,0,0,0,\(object["steps"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" as AnyObject?
        steps["distance"] = object["distance"].intValue as AnyObject?
        steps["hourlydistance"] = "[0,0,0,0,0,0,0,0,\(object["distance"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" as AnyObject?
        steps["calories"] = object["calories_burned"].doubleValue as AnyObject?
        steps["hourlycalories"] = "[0,0,0,0,0,0,0,0,\(object["calories_burned"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" as AnyObject?
        steps["date"] = date.timeIntervalSince1970 as AnyObject?
        steps["createDate"] = date.stringFromFormat("yyyyMMdd") as AnyObject?
        steps["validic_id"] = object["_id"].stringValue as AnyObject?
        let userSteps:NSArray = UserSteps.getCriteria("WHERE createDate = \(steps["createDate"]!)")
        if userSteps.count == 0 {
            let userSteps:UserSteps = UserSteps(keyDict: steps as NSDictionary)
            userSteps.add { (id, completion) in
                
            }
        }
    }
    
    func analyticalSleepData(_ object:JSON) {
        XCGLogger.defaultInstance().debug("\(object)")
        var timer = object["timestamp"].stringValue.replacingOccurrences(of: "T", with: " ")
        timer = timer.replacingOccurrences(of: "+00:00", with: "")
        let date = GmtNSDate2LocaleNSDate(timer.dateFromFormat("yyyy-MM-dd HH:mm:ss'UTC'")!)
        
        let awakeSleep:Int = object["awake"].intValue
        let awakeDeep:Int = object["deep"].intValue
        let lightSleep:Int = object["light"].intValue
        
        var sleep:[String:AnyObject] = [:]
        sleep["_id"] = object["_id"].stringValue as AnyObject?
        sleep["date"] = date.timeIntervalSince1970 as AnyObject?
        sleep["totalSleepTime"] = object["total_sleep"].intValue as AnyObject?
        sleep["hourlySleepTime"] = "[0,\(object["total_sleep"].intValue),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" as AnyObject?
        sleep["totalWakeTime"] = awakeSleep as AnyObject?
        sleep["hourlyWakeTime"] = "[0,\(awakeSleep),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" as AnyObject?
        sleep["totalLightTime"] = lightSleep as AnyObject?
        sleep["hourlyLightTime"] = "[0,\(lightSleep),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" as AnyObject?
        sleep["totalDeepTime"] = awakeDeep as AnyObject?
        sleep["hourlyDeepTime"] = "[0,\(awakeDeep),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]" as AnyObject?
        let userSteps:NSArray = UserSleep.getCriteria("WHERE createDate = \(sleep["createDate"]!)")
        if userSteps.count == 0 {
            let userSteps:UserSleep = UserSleep(keyDict: sleep as NSDictionary)
            userSteps.add { (id, completion) in
                
            }
        }
    }
}
