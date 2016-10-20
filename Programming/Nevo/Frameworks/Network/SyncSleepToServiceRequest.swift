//
//  SyncSleepToServiceRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/10/20.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON
import  XCGLogger

let UPDATE_SERVICE_SLEEP_REQUEST:SyncSleepToServiceRequest = SyncSleepToServiceRequest()
class SyncSleepToServiceRequest: NSObject {
    func syncCreateSleepToService(paramsValue:[String:Any],completion:@escaping (_ result:Bool,_ errorid:Int) -> Void) {
        HttpPostRequest.postRequest("sleep/create", data: paramsValue as Dictionary<String, AnyObject>) { (result) in
            let json = JSON(result)
            var message = json["message"].stringValue
            let status = json["status"].intValue
            if status == 1{
                XCGLogger.default.debug("create sleep ok")
                completion(true,status)
            }else{
                completion(true,status);
            }
        }
    }
    
    func syncSleepUpdateToService(paramsValue:[String:Any],completion:@escaping (_ result:Bool,_ errorid:Int) -> Void) {
        HttpPostRequest.postRequest("sleep/update", data: paramsValue as Dictionary<String, AnyObject>) { (result) in
            let json = JSON(result)
            var message = json["message"].stringValue
            let status = json["status"].intValue
            if status == 1{
                XCGLogger.default.debug("update steps ok")
                completion(true,status)
            }else{
                completion(true,status);
            }
        }
    }
}
