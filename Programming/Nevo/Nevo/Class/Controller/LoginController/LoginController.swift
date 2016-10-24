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

            LOGIN_NEVO_SERVICE_REQUEST.loginAction(userName, password: password, completion: { (result, status) in
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                if result {
                    
                    let dayDate:Date = Date()
                    let stepsArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(Date().beginningOfWeek.timeIntervalSince1970-864000*30) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
                    let sleepArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(Date().beginningOfWeek.timeIntervalSince1970-864000*30) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
                    let login:NSArray = UserProfile.getAll()
                    if login.count>0 {
                        for stepsValue in stepsArray{
                            let stepsModel:UserSteps = stepsValue as! UserSteps
                            let profile:UserProfile = login[0] as! UserProfile
                            let dateString:String = Date(timeIntervalSince1970: stepsModel.date).stringFromFormat("yyy-MM-dd")
                            var caloriesValue:Int = 0
                            var milesValue:Int = 0
                            StepGoalSetingController.calculationData((stepsModel.walking_duration+stepsModel.running_duration), steps: stepsModel.steps, completionData: { (miles, calories) in
                                caloriesValue = Int(calories)
                                milesValue = Int(miles)
                            })
                            
                            let value:[String:Any] = ["steps":["uid":profile.id,"steps":stepsModel.hourlysteps,"date":dateString,"calories":caloriesValue,"active_time":stepsModel.walking_duration+stepsModel.running_duration,"distance":milesValue]]
                            stepsModel.isUpload = true
                            UPDATE_SERVICE_STEPS_REQUEST.syncStepsToService(paramsValue: value, completion: { (result, status) in
                                
                            })
                        }
                        
                        for sleepValue in sleepArray{
                            let sleepModel:UserSleep = sleepValue as! UserSleep
                            let profile:UserProfile = login[0] as! UserProfile
                            let dateString:String = Date(timeIntervalSince1970: sleepModel.date).stringFromFormat("yyy-MM-dd")
                            let value:[String:Any] = ["sleep":["uid":profile.id,"deep_sleep":sleepModel.hourlyDeepTime,"light_sleep":sleepModel.hourlyLightTime,"wake_time":sleepModel.hourlyWakeTime,"date":dateString]]
                            
                            if !sleepModel.isUpload {
                                sleepModel.isUpload = true
                                UPDATE_SERVICE_SLEEP_REQUEST.syncCreateSleepToService(paramsValue:value,completion:{(result,errorid) in
                                    
                                })
                                _ = sleepModel.update()
                            }
                        }
                        
                    }
                    
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
            })

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
    
}
