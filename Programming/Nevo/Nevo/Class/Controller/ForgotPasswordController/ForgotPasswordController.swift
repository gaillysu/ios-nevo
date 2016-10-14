//
//  ForgotPasswordController.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import MRProgress
import SwiftyJSON

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var emailTextField: AutocompleteField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var userEmail:String = ""
    
    init() {
        super.init(nibName: "ForgotPasswordController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = userEmail
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftCancelAction(_:)))
        self.navigationItem.leftBarButtonItem = leftButton
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leftCancelAction(_ sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewController(animated: true)
        if viewController == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func buttonAction(_ sender: AnyObject) {
        self.forgotPasswordRequest()
    }
    
    func forgotPasswordRequest() {
        let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
        view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
        
        HttpPostRequest.postRequest("user/request_password_token", data: ["user":["email":emailTextField.text!] as AnyObject]) { (result) in
            MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            
            let json = JSON(result)
            let status:Int = json["status"].intValue
            if status == 1 {
                let token:String = json["user"].dictionaryValue["password_token"]!.stringValue
                let email:String = json["user"].dictionaryValue["email"]!.stringValue
                let id:Int = json["user"].dictionaryValue["id"]!.intValue
                let alert:UIAlertController = UIAlertController(title: NSLocalizedString("change_password", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                alert.addTextField(configurationHandler: { (newPassword1:UITextField) in
                    newPassword1.placeholder = NSLocalizedString("new_password", comment: "")
                    newPassword1.isSecureTextEntry = true
                })
                
                alert.addTextField(configurationHandler: { (newPassword2:UITextField) in
                    newPassword2.placeholder = NSLocalizedString("new_password_confirm", comment: "")
                    newPassword2.isSecureTextEntry = true
                })
                
                let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: .default, handler: { (action) in
                    let textField:[UITextField] = alert.textFields!
                    if textField[0].text == nil || textField[1].text == nil {
                        let banner = MEDBanner(title: NSLocalizedString("Please enter a new password", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                        return
                    }
                    if textField[0].text! == textField[1].text! {
                        let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
                        view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
                        HttpPostRequest.postRequest("user/forget_password", data: ["user":["password_token":token,"email":email,"password":textField[0].text!,"id":id] as AnyObject], completion: { (result) in
                            MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                            let json = JSON(result)
                            let status:Int = json["status"].intValue
                            if status != -3 {
                                let banner = MEDBanner(title: NSLocalizedString("Password is changed", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                                banner.dismissesOnTap = true
                                banner.show(duration: 1.2)
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }else{
                        let banner = MEDBanner(title: NSLocalizedString("two_password_is_not_the_same", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                    }
                })
                alert.addAction(alertAction)
                
                let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) in
                })
                alert.addAction(alertAction2)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

}
