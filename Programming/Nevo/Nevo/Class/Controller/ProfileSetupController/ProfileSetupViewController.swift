//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import BRYXBanner
import MRProgress


private let DATEPICKER_TAG:Int = 1280
private let PICKERVIEW_TAG:Int = 1380

class ProfileSetupViewController: UIViewController {

    @IBOutlet weak var email: AutocompleteField!
    @IBOutlet weak var firstNameTextField: AutocompleteField!
    @IBOutlet weak var lastNameTextField: AutocompleteField!
    @IBOutlet weak var password: AutocompleteField!
    @IBOutlet weak var retypePassword: AutocompleteField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var checkBox: M13Checkbox!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var agreeLabel: UILabel!

    fileprivate var nameDictionary:Dictionary<String,AnyObject> = ["first_name":"DroneUser" as AnyObject,"last_name":"User" as AnyObject]
    var account:Dictionary<String,AnyObject> = ["email":"" as AnyObject,"password":"" as AnyObject]

    fileprivate var selectedTextField: AutocompleteField?
    fileprivate var lengthArray:[Int] = []
    fileprivate var weightArray:[Int] = []
    fileprivate var weightFloatArray:[Int] = []
    fileprivate var selectedRow:Int = 0
    fileprivate var selectedRow2:Int = 0

    init() {
        super.init(nibName: "ProfileSetupViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Register", comment: "")
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftCancelAction(_:)))
        self.navigationItem.leftBarButtonItem = leftButton
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.view.backgroundColor = UIColor.getGreyColor()
            signupLabel.textColor = UIColor.white
            email.backgroundColor = UIColor.getLightBaseColor()
            email.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            firstNameTextField.backgroundColor = UIColor.getLightBaseColor()
            firstNameTextField.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            lastNameTextField.backgroundColor = UIColor.getLightBaseColor()
            lastNameTextField.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            password.backgroundColor = UIColor.getLightBaseColor()
            password.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            retypePassword.backgroundColor = UIColor.getLightBaseColor()
            retypePassword.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            termsLabel.textColor = UIColor.getBaseColor()
            agreeLabel.textColor = UIColor.white
            checkBox.tintColor = UIColor.getBaseColor()
            checkBox.setValue(UIColor.getBaseColor(), forKeyPath: "secondaryTintColor")
            checkBox.setValue(UIColor.getBaseColor(), forKeyPath: "secondaryCheckmarkTintColor")
            submitButton.backgroundColor = UIColor.getBaseColor()
            
            email.textColor = UIColor.white
            firstNameTextField.textColor = UIColor.white
            lastNameTextField.textColor = UIColor.white
            password.textColor = UIColor.white
            retypePassword.textColor = UIColor.white
        }
    }

    func leftCancelAction(_ sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewController(animated: true)
        if viewController == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonActionManager(_ sender: AnyObject) {
        
        if AppTheme.isEmail(email!.text!) {
            let banner = MEDBanner(title: NSLocalizedString("The format of your E-mail address seems to be wrong. :(", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 0.6)
            return
        }
        
        if(AppTheme.isNull(email!.text!) || AppTheme.isNull(firstNameTextField!.text!) || AppTheme.isNull(lastNameTextField!.text!) || AppTheme.isPassword(password.text!) || AppTheme.isPassword(retypePassword.text!)) {
            let banner = MEDBanner(title: NSLocalizedString("one_of_the_fields_are_empty", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 0.6)
            
        }else{
            if retypePassword.text! != password.text! {
                let banner = MEDBanner(title: NSLocalizedString("two_password_is_not_the_same", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 0.6)
            }else{
                if checkBox.checkState == .unchecked {
                    // TODO: 字符串本地化
                    let banner = MEDBanner(title: NSLocalizedString("The terms and conditions were not agreed. :(", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 0.6)
                } else {
                    let infoDict:[String:String] = ["email":email!.text!,"first_name":firstNameTextField!.text!,"last_name":lastNameTextField!.text!,"password":password.text!]
                    let infomation:InformationController = InformationController()
                    infomation.registerInfor = infoDict
                    self.navigationController?.pushViewController(infomation, animated: true)
                }
            }
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastNameTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        retypePassword.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if email.isEqual(textField) {
            firstNameTextField.becomeFirstResponder()
        }
        
        if firstNameTextField.isEqual(textField) {
            lastNameTextField.becomeFirstResponder()
        }
        
        if lastNameTextField.isEqual(textField) {
            password.becomeFirstResponder()
        }
        
        if password.isEqual(textField) {
            retypePassword.becomeFirstResponder()
        }
        
        if textField.returnKeyType == UIReturnKeyType.done {
            textField.resignFirstResponder()
        }
        
        return true
    }
}


// MARK: - SYSTEM CALLBACK
extension ProfileSetupViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
