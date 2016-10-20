//
//  LoginController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import MRProgress
import BRYXBanner
import LTNavigationBar
import UIColor_Hex_Swift
import ActiveLabel
import XCGLogger
import SwiftyJSON

class LoginController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var userNameTextField: AutocompleteField!
    @IBOutlet weak var passwordTextField: AutocompleteField!
    @IBOutlet weak var logoinButton: UIButton!
    @IBOutlet weak var registerLabel: ActiveLabel!
    @IBOutlet weak var platformLabel: UILabel!
    
    @IBOutlet weak var skipButton: UIButton!
    
//    fileprivate var backButton;
    
    var userName:String = ""
    var password:String = ""
    fileprivate var pErrorNumber:Int = 0

    init() {
        super.init(nibName: "LoginController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Login", comment: "")
        let rightButton:UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Skip Login", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightAction(_:)))
        self.navigationItem.rightBarButtonItem = rightButton

        // Skip Login
        self.skipButton.setTitle(NSLocalizedString("Skip Login", comment: ""), for: .normal)
        self.skipButton.sizeToFit()
        
        let judgeRootViewController = NSStringFromClass((UIApplication.shared.keyWindow?.rootViewController?.classForCoder)!) == "Nevo.MainTabBarController"
        self.skipButton.isHidden = judgeRootViewController
        
        if judgeRootViewController {
            navigationController?.isNavigationBarHidden = false
            AppTheme.navigationbar(navigationController)
            let backButton:UIButton = UIButton()
            backButton.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
            backButton.sizeToFit()
            backButton.addTarget(self, action: #selector(backButtonClick(_:)), for: .touchUpInside)
            view.addSubview(backButton)
        }
        
        for controllers:UIViewController in self.navigationController!.viewControllers {
            if controllers.isKind(of: SetingViewController.self) {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        registerLabel.addGestureRecognizer(tap)
        
        if AppTheme.GET_IS_iPhone5S()||AppTheme.GET_IS_iPhone4S() {
            logoinButton.titleLabel?.font = UIFont(name: "Raleway", size: 20)
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            iconImage.image = UIImage(named: "lunar_logo")
            self.view.backgroundColor = UIColor.getGreyColor()
            logoinButton.backgroundColor = UIColor.getBaseColor()
            platformLabel.textColor = UIColor.white
            userNameTextField.backgroundColor = UIColor.getLightBaseColor()
            passwordTextField.backgroundColor = UIColor.getLightBaseColor()
            userNameTextField.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            passwordTextField.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")

            registerLabel.textColor = UIColor.getBaseColor()
            
            userNameTextField.textColor = UIColor.white
            passwordTextField.textColor = UIColor.white
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let user:NSArray = UserProfile.getAll()
        if user.count>0 {
            let judgeRootViewController = NSStringFromClass((UIApplication.shared.keyWindow?.rootViewController?.classForCoder)!) == "Nevo.MainTabBarController"
            
            if judgeRootViewController {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            }
        }
    }
    
    func tapAction(_ sender:UITapGestureRecognizer) {
        let register:ProfileSetupViewController = ProfileSetupViewController()
        self.present(UINavigationController(rootViewController: register), animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func rightAction(_ sender:UIBarButtonItem) {
        let register:ProfileSetupViewController = ProfileSetupViewController()
        self.navigationController?.pushViewController(register, animated: true)
    }

    @IBAction func buttonAction(_ sender: AnyObject) {
        if sender.isEqual(logoinButton) {
            self.loginRequest()
        }else{
            let register:ProfileSetupViewController = ProfileSetupViewController()
            self.present(UINavigationController(rootViewController: register), animated: true, completion: nil)
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func loginRequest() {
            userName = userNameTextField!.text!
            password = passwordTextField!.text!
        if AppDelegate.getAppDelegate().network!.isReachable {
            XCGLogger.default.debug("有网络")
            if(AppTheme.isNull(userName) || AppTheme.isEmail(userName)) {
                let banner = MEDBanner(title: NSLocalizedString("Email is not filled in", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            if AppTheme.isNull(password) || AppTheme.isPassword(password) {
                let banner = MEDBanner(title: NSLocalizedString("Password is not filled in", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())

            HttpPostRequest.postRequest("user/login", data: (["user":["email":userName,"password":password]] as AnyObject) as! Dictionary<String, AnyObject>) { (result) in
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                
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
                    
                    let userprofile:UserProfile = UserProfile(keyDict: ["id":user["id"].intValue,"first_name":user["first_name"].stringValue,"last_name":user["last_name"].stringValue,"birthday":birthday,"length":user["length"].intValue,"email":user["email"].stringValue, "weight":user["weight"].floatValue])
                    userprofile.add({ (id, completion) in
                        XCGLogger.default.debug("Added? id = \(id)")
                    })
                    
                    let judgeRootViewController = NSStringFromClass((UIApplication.shared.keyWindow?.rootViewController?.classForCoder)!) == "Nevo.MainTabBarController"
                    
                    if judgeRootViewController {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    }
                }else{
                    if self.pErrorNumber>=3{
                        let forgetPassword:UIAlertController = UIAlertController(title: NSLocalizedString("forget_your_password", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        forgetPassword.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                        
                        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
                            let forget:ForgotPasswordController = ForgotPasswordController()
                            forget.userEmail = self.userName
                            let nav:UINavigationController = UINavigationController(rootViewController: forget)
                            self.present(nav, animated: true, completion: nil)
                        })
                        forgetPassword.addAction(alertAction)
                        
                        let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                            
                        })
                        forgetPassword.addAction(alertAction2)
                        
                        self.present(forgetPassword, animated: true, completion: nil)
                    }
                    self.pErrorNumber += 1
                }
               
            }
        }else{
            
            XCGLogger.default.debug("没有网络")
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(1, { 
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
        
    }

    @IBAction func skipButtonClick(_ sender: AnyObject) {
        let naviController:UINavigationController = UINavigationController(rootViewController: TutorialOneViewController())
        naviController.isNavigationBarHidden = true
        
        UIApplication.shared.keyWindow?.rootViewController = naviController
    }
    
    fileprivate func backButtonClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
