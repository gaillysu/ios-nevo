//
//  ForgotPasswordRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/10/14.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON
import XCGLogger
import MRProgress

class ForgotPasswordRequest: NSObject {
    
    func forgotPasswordAction(_ email:String,completion:@escaping (_ result:Bool) -> Void) {
        HttpPostRequest.postRequest("user/request_password_token", data: ["user":["email":email] as AnyObject]) { (result) in
            let json = JSON(result)
            let status:Int = json["status"].intValue
            if status == 1 {
                completion(true)
                let token:String = json["user"].dictionaryValue["password_token"]!.stringValue
                let email:String = json["user"].dictionaryValue["email"]!.stringValue
                let id:Int = json["user"].dictionaryValue["id"]!.intValue
                let alert:ActionSheetView = ActionSheetView(title: "Change Password", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addTextField(configurationHandler: { (newPassword1:UITextField) in
                    newPassword1.placeholder = "News Password"
                    newPassword1.isSecureTextEntry = true
                })
                
                alert.addTextField(configurationHandler: { (newPassword2:UITextField) in
                    newPassword2.placeholder = "Confirm new password"
                    newPassword2.isSecureTextEntry = true
                })
                
                let alertAction:UIAlertAction = UIAlertAction(title: "Change", style: .default, handler: { (action) in
                    let textField:[UITextField] = alert.textFields!
                    if textField[0].text == nil || textField[1].text == nil {
                        let banner = MEDBanner(title: NSLocalizedString("Please enter a new password", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                        return
                    }
                    if textField[0].text! == textField[1].text! {
                        let view = MRProgressOverlayView.showOverlayAdded(to: UIApplication.shared.keyWindow, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
                        view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
                        if !AppTheme.isTargetLunaR_OR_Nevo() {
                            view?.setTintColor(UIColor.getBaseColor())
                        }
                        
                        HttpPostRequest.postRequest("user/forget_password", data: ["user":["password_token":token,"email":email,"password":textField[0].text!,"id":id] as AnyObject], completion: { (result) in
                            MRProgressOverlayView.dismissAllOverlays(for: UIApplication.shared.keyWindow, animated: true)
                            let json = JSON(result)
                            let status:Int = json["status"].intValue
                            if status != -3 {
                                let banner = MEDBanner(title: NSLocalizedString("Password is changed", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                                banner.dismissesOnTap = true
                                banner.show(duration: 1.2)
                                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                                completion(true)
                            }else{
                                completion(false)
                            }
                        })
                    }else{
                        let banner = MEDBanner(title: NSLocalizedString("Passwords don't match", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                        completion(false)
                    }
                })
                alert.addAction(alertAction)
                
                let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                    completion(false)
                })
                alert.addAction(alertAction2)
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                
            }else{
                completion(false)
            }
        }
        
    }
}
