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
import RealmSwift

class LoginController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var userNameTextField: AutocompleteField!
    @IBOutlet weak var passwordTextField: AutocompleteField!
    @IBOutlet weak var logoinButton: UIButton!
    @IBOutlet weak var registerLabel: ActiveLabel!
    @IBOutlet weak var platformLabel: UILabel!
 
    var userName:String = ""
    var password:String = ""
    fileprivate var pErrorNumber:Int = 0

    init() {
        super.init(nibName: "LoginController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - View's Lifecycle
extension LoginController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Login", comment: "")
        let rightButton:UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Skip Login", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(skipButtonClick(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonClick(_:)))
        self.navigationItem.leftBarButtonItem = leftButton
        
        let judgeRootViewController = UIApplication.shared.keyWindow?.rootViewController?.isKind(of: UITabBarController.classForCoder())
        
        if judgeRootViewController! {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        registerLabel.addGestureRecognizer(tap)
        
        if AppTheme.GET_IS_iPhone5S()||AppTheme.GET_IS_iPhone4S() {
            logoinButton.titleLabel?.font = UIFont(name: "Raleway", size: 20)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clear)
        navigationItem.title = nil
        
        navigationController?.navigationBar.subviewsSatisfy(theCondition: { (v) -> (Bool) in
            return v.frame.height == 0.5
        }, do: { (v) in
            v.isHidden = true
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let email_pw = UserDefaults.standard.object(forKey: InformationController.MED_kISFromRegisterController) as? [String : String] {
            userNameTextField.text = email_pw["email"]!
            passwordTextField.text = email_pw["password"]!
            
            UserDefaults.standard.set(nil, forKey: InformationController.MED_kISFromRegisterController)
            loginRequest()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.userNameTextField.text = ""
        // when back from the forgot-password controller, the passwordTextField is supposed to be empty. though, if want the field be filled with the new password, it would be ok.
        self.passwordTextField.text = ""
    }
}


// MARK: - Touch Event
extension LoginController {
    
    func tapAction(_ sender:UITapGestureRecognizer) {
        let register:ProfileSetupViewController = ProfileSetupViewController()
        let naviController:UINavigationController = UINavigationController(rootViewController: register)
        
        self.present(naviController, animated: true, completion: nil)
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
    
    @IBAction func skipButtonClick(_ sender: AnyObject) {
        let naviController:UINavigationController = UINavigationController(rootViewController: TutorialOneViewController())
        naviController.isNavigationBarHidden = true
        
        UIApplication.shared.keyWindow?.rootViewController = naviController
    }
    
    @objc fileprivate func backButtonClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Network
extension LoginController {
    func loginRequest() {
        userName = userNameTextField!.text!
        password = passwordTextField!.text!
        if MEDNetworkManager.manager.networkState {
            XCGLogger.default.debug("有网络")
            if(AppTheme.isNull(userName) || AppTheme.isEmail(userName)) {
                let banner = MEDBanner(title: NSLocalizedString("Email is not filled in", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.baseColor)
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            if AppTheme.isNull(password) || AppTheme.isPassword(password) {
                let banner = MEDBanner(title: NSLocalizedString("Password is not filled in", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.baseColor)
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(UIColor.baseColor)
            
            MEDUserNetworkManager.login(email: userName, password: password, completion: { (loggedIn: Bool, user: MEDUserProfile?) in
                
                let message: String = loggedIn ? NSLocalizedString("login_success", comment: "") : NSLocalizedString("login_error", comment: "")
                let banner = MEDBanner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                
                if loggedIn {
                    _ = user?.add()
                    
                    let dayDate:Date = Date()
                    let stepsArray = MEDUserSteps.getFilter("date > \(dayDate.beginningOfWeek.timeIntervalSince1970-864000*30) AND date < \(dayDate.endOfWeek.timeIntervalSince1970)")
                    let sleepArray = MEDUserSleep.getFilter("date > \(dayDate.beginningOfWeek.timeIntervalSince1970-864000*30) AND date < \(dayDate.endOfWeek.timeIntervalSince1970)")
                    
                    for stepsValue in stepsArray {
                        let stepsModel:MEDUserSteps = stepsValue as! MEDUserSteps
                        let profile:MEDUserProfile = user!
                        let dateString:String = Date(timeIntervalSince1970: stepsModel.date).stringFromFormat("yyy-MM-dd")
                        var caloriesValue:Int = 0
                        var milesValue:Double = 0
                        DataCalculation.calculationData((stepsModel.walking_duration+stepsModel.running_duration), steps: stepsModel.totalSteps, completionData: { (miles, calories) in
                            caloriesValue = Int(calories)
                            milesValue = miles
                        })
                        
                        //                        let value:[String:Any] = ["steps":["uid":profile.id,"steps":stepsModel.hourlysteps,"date":dateString,"calories":caloriesValue,"active_time":stepsModel.walking_duration+stepsModel.running_duration,"distance":milesValue]]
                        let activeTime: Int = stepsModel.walking_duration+stepsModel.running_duration
                        MEDStepsNetworkManager.createSteps(uid: profile.uid, steps: stepsModel.hourlysteps, date: dateString, activeTime: activeTime, calories: caloriesValue, distance: milesValue, completion: { (success: Bool) in
                            if success {
                                let realm = try! Realm()
                                try! realm.write {
                                    stepsModel.isUpload = true
                                }
                            }
                        })
                    }
                    
                    for sleepValue in sleepArray {
                        let sleepModel:MEDUserSleep = sleepValue as! MEDUserSleep
                        let profile:MEDUserProfile = user!
                        let dateString:String = Date(timeIntervalSince1970: sleepModel.date).stringFromFormat("yyy-MM-dd")
                        
                        if !sleepModel.isUpload {
                            MEDSleepNetworkManager.createSleep(uid: profile.uid, deepSleep: sleepModel.hourlyDeepTime, lightSleep: sleepModel.hourlyLightTime, wakeTime: sleepModel.hourlyWakeTime, date: dateString, completion: { (success:Bool) in
                                let realm = try! Realm()
                                try! realm.write {
                                    sleepModel.isUpload = true
                                }
                            })
                        }
                    }
                    
                    let judgeRootViewController = UIApplication.shared.keyWindow?.rootViewController?.isKind(of: UITabBarController.classForCoder())
                    
                    if judgeRootViewController! {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let naviController:UINavigationController = UINavigationController(rootViewController: TutorialOneViewController())
                        naviController.isNavigationBarHidden = true
                        self.present(naviController, animated: true, completion: nil)
                    }
                    
                } else {
                    if self.pErrorNumber>=3{
                        let forgetPassword:MEDAlertController = MEDAlertController(title: NSLocalizedString("forget_your_password", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        forgetPassword.view.tintColor = UIColor.baseColor
                        
                        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
                            let forget:ForgotPasswordController = ForgotPasswordController()
                            forget.userEmail = self.userName
                            let nav:UINavigationController = UINavigationController(rootViewController: forget)
                            self.present(nav, animated: true, completion: nil)
                        })
                        
                        forgetPassword.addAction(alertAction)
                        
                        let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                        })
                        forgetPassword.addAction(alertAction2)
                        
                        self.present(forgetPassword, animated: true, completion: nil)
                    }
                    self.pErrorNumber += 1
                }
            })
        }else{
            
            XCGLogger.default.debug("没有网络")
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.baseColor)
            Timer.after(1, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
    }
}
