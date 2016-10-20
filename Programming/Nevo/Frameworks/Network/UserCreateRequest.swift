//
//  UserCreateRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/10/14.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON
import XCGLogger
import MRProgress

class UserCreateRequest: NSObject {
    func userCreateAction(_ infor:[String:String],completion:@escaping (_ result:Bool) -> Void) {
        let view = MRProgressOverlayView.showOverlayAdded(to: UIApplication.shared.keyWindow, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
        view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
        
        //timeout
        let timeout:Timer = Timer.after(50.seconds, {
            MRProgressOverlayView.dismissAllOverlays(for: UIApplication.shared.keyWindow, animated: true)
        })
        
        HttpPostRequest.postRequest("user/create", data: ["user":infor as AnyObject]) { (result) in
            timeout.invalidate()
            MRProgressOverlayView.dismissAllOverlays(for: UIApplication.shared.keyWindow, animated: true)
            
            let json = JSON(result)
            var message = json["message"].stringValue
            let status = json["status"].intValue
            let user:[String : JSON] = json["user"].dictionaryValue
            
            if(user.count>0) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "y-M-d h:m:s.000000"
                let birthdayJSON = user["birthday"]
                let birthdayBeforeParsed = birthdayJSON!["date"].stringValue
                
                let birthdayDate = dateFormatter.date(from: birthdayBeforeParsed)
                dateFormatter.dateFormat = "y-M-d"
                let birthday = dateFormatter.string(from: birthdayDate!)
                let sex = user["sex"]!.intValue == 1 ? true : false;
                if(status > 0 && UserProfile.getAll().count == 0) {
                    message = NSLocalizedString("register_success", comment: "");
                    let userprofile:UserProfile = UserProfile(keyDict: ["id":user["id"]!.intValue,"first_name":user["first_name"]!.stringValue,"last_name":user["last_name"]!.stringValue,"length":user["length"]!.intValue,"email":user["email"]!.stringValue,"sex": sex, "weight":(user["weight"]?.floatValue)!, "birthday":birthday])
                    userprofile.add({ (id, completion) in
                    })
                    completion(true)
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                }else{
                    
                    switch status {
                    case -1:
                        message = NSLocalizedString("access_denied", comment: "");
                    case -2:
                        message = "";
                    case -3:
                        message = NSLocalizedString("user_exist", comment: "");
                        break
                        
                    default: message = NSLocalizedString("signup_failed", comment: "")
                    }
                    completion(false)
                }
                
            }else{
                if message.isEmpty {
                    message = NSLocalizedString("no_network", comment: "")
                }
                completion(false)
                
            }
            
            let banner = MEDBanner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
        }
    }
}
