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

let ValidicOrganizationID = "56d3b075407e010001000000"
let OrganizationAccessToken = "b85dcb3b85e925200f3fd4cafe6dce92295f449d9596b137941de7e9e2c3e7ae"
let ValidicAuthorizedKey = "Nevo_ValidicAuthorized"

let UPDATE_VALIDIC_REQUEST:ValidicRequest = ValidicRequest()

class ValidicRequest: NSObject {

    class func validicPostJSONRequest(url: String, data:Dictionary<String,AnyObject>, completion:(result:NSDictionary) -> Void){
        
        debugPrint("accessData:\(data)")
        Alamofire.request(.POST, url, parameters: data ,encoding: .JSON, headers: ["Content-Type":"application/json"]).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                NSLog("getJSON: \(response.result.value!)")
                completion(result: response.result.value! as! NSDictionary)
            }else if (response.result.isFailure){
                if response.result.value != nil {
                    NSLog("getJSON: \(response.result.value!)")
                    completion(result: response.result.value! as! NSDictionary)
                }else{
                    completion(result: NSDictionary(dictionary: ["code": 500,"message": "Authorized",]))
                }
                
            }
        }
    }
    
    func updateValidicData(data:Dictionary<String,AnyObject>,completion:(result:NSDictionary) -> Void)  {
        ValidicRequest.validicPostJSONRequest("", data: data) { (result) in
            
        }
    }
    
    class func formatterDate(date:NSDate)->String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-mm-ddThh:mm:sszzz"
        let dateString = "\(formatter.stringFromDate(date))"
        return dateString
    }
}
