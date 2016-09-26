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

    @IBOutlet weak var userNameTextField: AutocompleteField!
    @IBOutlet weak var passwordTextField: AutocompleteField!
    @IBOutlet weak var logoinButton: UIButton!
    @IBOutlet weak var registerLabel: ActiveLabel!
    
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
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let user:NSArray = UserProfile.getAll()
        if user.count>0 {
            self.navigationController?.popViewController(animated: true)
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
                let banner = Banner(title: NSLocalizedString("Email is not filled in.", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            if AppTheme.isNull(password) || AppTheme.isPassword(password) {
                let banner = Banner(title: NSLocalizedString("Password is not filled in.", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())

            
            HttpPostRequest.LunaRPostRequest("http://nevo.karljohnchow.com/user/login", data: (["user":["email":userName,"password":password]] as AnyObject) as! Dictionary<String, AnyObject>) { (result) in
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
                
                let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
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
                    self.navigationController?.popViewController(animated: true)
                }else{
                    if self.pErrorNumber>=3{
                        let forgetPassword:UIAlertController = UIAlertController(title: "Forget PassWord?", message: NSLocalizedString("forget_your_password", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("forget", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
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

}
