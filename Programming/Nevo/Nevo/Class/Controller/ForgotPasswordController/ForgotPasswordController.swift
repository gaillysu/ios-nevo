//
//  ForgotPasswordController.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import SwiftyJSON
import BRYXBanner
import MRProgress

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var emailTextField: AutocompleteField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var userEmail:String = ""
    
    init() {
        super.init(nibName: "ForgotPasswordController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = userEmail
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(leftCancelAction(_:)))
        self.navigationItem.leftBarButtonItem = leftButton
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leftCancelAction(sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewControllerAnimated(true)
        if viewController == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func buttonAction(sender: AnyObject) {
        self.forgotPasswordRequest()
    }
    
    func forgotPasswordRequest() {
        let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        view.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
        
        HttpPostRequest.LunaRPostRequest("http://nevo.karljohnchow.com/user/request_password_token", data: ["user":["email":emailTextField.text!]]) { (result) in
            MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            
            let json = JSON(result)
            let status:Int = json["status"].intValue
            if status == 1 {
                let token:String = json["user"].dictionaryValue["password_token"]!.stringValue
                let email:String = json["user"].dictionaryValue["email"]!.stringValue
                let id:Int = json["user"].dictionaryValue["id"]!.intValue
                let alert:UIAlertController = UIAlertController(title: "Change Password", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addTextFieldWithConfigurationHandler({ (newPassword1:UITextField) in
                    newPassword1.placeholder = "News Password"
                    newPassword1.secureTextEntry = true
                })
                
                alert.addTextFieldWithConfigurationHandler({ (newPassword2:UITextField) in
                    newPassword2.placeholder = "Confirm new password"
                    newPassword2.secureTextEntry = true
                })
                
                let alertAction:UIAlertAction = UIAlertAction(title: "Change", style: .Default, handler: { (action) in
                    let textField:[UITextField] = alert.textFields!
                    if textField[0].text == nil || textField[1].text == nil {
                        let banner = Banner(title: NSLocalizedString("Please enter a new password", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                        return
                    }
                    if textField[0].text! == textField[1].text! {
                        let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
                        view.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
                        HttpPostRequest.postRequest("http://nevo.karljohnchow.com/user/forget_password", data: ["user":["password_token":token,"email":email,"password":textField[0].text!,"id":id]], completion: { (result) in
                            MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                            let json = JSON(result)
                            let status:Int = json["status"].intValue
                            if status != -3 {
                                let banner = Banner(title: NSLocalizedString("Password is changed", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                                banner.dismissesOnTap = true
                                banner.show(duration: 1.2)
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        })
                    }else{
                        let banner = Banner(title: NSLocalizedString("Passwords don't match", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                    }
                })
                alert.addAction(alertAction)
                
                let alertAction2:UIAlertAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
                    
                })
                alert.addAction(alertAction2)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }

}
