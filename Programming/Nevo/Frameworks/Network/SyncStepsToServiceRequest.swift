//
//  SyncStepsToServiceRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/10/20.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON
import  XCGLogger

let UPDATE_SERVICE_STEPS_REQUEST:SyncStepsToServiceRequest = SyncStepsToServiceRequest()
class SyncStepsToServiceRequest: NSObject {

    func syncStepsToService(paramsValue:[String:Any],completion:@escaping (_ result:Bool,_ errorid:Int) -> Void) {
        HttpPostRequest.postRequest("steps/create", data: paramsValue as Dictionary<String, AnyObject>) { (result) in
            let json = JSON(result)
            var message = json["message"].stringValue
            let status = json["status"].intValue
            if status == 1{
                XCGLogger.default.debug("create steps ok")
                completion(true,status)
            }else{
                completion(true,status);
            }
        }
    }
    
    func syncStepsToUpdateService(paramsValue:[String:Any],completion:@escaping (_ result:Bool,_ errorid:Int) -> Void) {
        HttpPostRequest.postRequest("steps/update", data: paramsValue as Dictionary<String, AnyObject>) { (result) in
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
