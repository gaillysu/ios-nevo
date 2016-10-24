//
//  LoginRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/10/14.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON
import XCGLogger

let LOGIN_NEVO_SERVICE_REQUEST:LoginRequest = LoginRequest()
class LoginRequest: NSObject {
    /**
     login Request function
     
     :userName: user request name
     :password: user request password
     :completion: request result(Bool)-> true: login success, false:login error
     */
    func loginAction(_ userName:String,password:String,completion:@escaping (_ result:Bool,_ status:Int) -> Void) {
        HttpPostRequest.postRequest("user/login", data: (["user":["email":userName,"password":password]] as AnyObject) as! Dictionary<String, AnyObject>) { (result) in
            
            let json = JSON(result)
            var message = json["message"].stringValue
            let status = json["status"].intValue
            
            switch status {
            case 1: message = NSLocalizedString("login_success", comment: "")
            case -1:message = NSLocalizedString("login_error", comment: "");
            case -2:break;
            case -3:message = NSLocalizedString("access_denied", comment: "");
            default:break;
            }
            
            let banner = MEDBanner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
            
            //status > 0 login success or login fail
            if(status > 0 && UserProfile.getAll().count == 0) {
                let user = json["user"]
                let jsonBirthday = user["birthday"];
                let dateString: String = jsonBirthday["date"].stringValue
                var birthday:String = ""
                if !jsonBirthday.isEmpty || !dateString.isEmpty {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "y-M-d h:m:s.000000"
                    let birthdayDate = dateFormatter.date(from: dateString)
                    dateFormatter.dateFormat = "y-M-d"
                    birthday = dateFormatter.string(from: birthdayDate!)
                }
                
                let userprofile:UserProfile = UserProfile()
                userprofile.id = user["id"].intValue
                userprofile.first_name = user["first_name"].stringValue
                userprofile.last_name = user["last_name"].stringValue
                userprofile.birthday = birthday
                userprofile.length = user["length"].intValue
                userprofile.email = user["email"].stringValue
                userprofile.weight = user["weight"].intValue
                userprofile.add({ (id, completion) in
                    XCGLogger.default.debug("Added? id = \(id)")
                })
                completion(true,status)
            }else{
                completion(false,status)
            }
            
        }
    }
}
