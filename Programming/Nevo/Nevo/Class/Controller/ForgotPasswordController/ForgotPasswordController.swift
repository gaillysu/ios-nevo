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
    
    func leftCancelAction(_ sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewController(animated: true)
        if viewController == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func buttonAction(_ sender: AnyObject) {
        self.forgotPasswordRequest()
    }
}

// MARK: - Network
extension ForgotPasswordController {
    func forgotPasswordRequest() {
        let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
        view?.setTintColor(UIColor.baseColor)
        
        MEDUserNetworkManager.requestPassword(email: emailTextField.text!) { (success:Bool, token:String, id:Int) in
            MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            
            if success {
                let alert:MEDAlertController = MEDAlertController(title: NSLocalizedString("change_password", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.view.tintColor = UIColor.baseColor
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
                        let banner = MEDBanner(title: NSLocalizedString("Please enter a new password", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.baseColor)
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                        return
                    }
                    if textField[0].text! == textField[1].text! {
                        let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
                        view?.setTintColor(UIColor.baseColor)
                        
                        MEDUserNetworkManager.forgetPassword(email: self.emailTextField.text!, password: textField[0].text!, id: id, token: token, completion: { (changeSuccess: Bool) in
                            MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                            if changeSuccess {
                                let banner = MEDBanner(title: NSLocalizedString("Password has been changed", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.baseColor)
                                banner.dismissesOnTap = true
                                banner.show(duration: 1.2)
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        })
                    }else{
                        let banner = MEDBanner(title: NSLocalizedString("two_password_is_not_the_same", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.baseColor)
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
