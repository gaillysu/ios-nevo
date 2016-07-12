//
//  LoginController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON
import MRProgress
import BRYXBanner
import XCGLogger
import LTNavigationBar
import UIColor_Hex_Swift
import AutocompleteField
import ActiveLabel

class LoginController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: AutocompleteField!
    @IBOutlet weak var passwordTextField: AutocompleteField!
    @IBOutlet weak var logoinButton: UIButton!
    @IBOutlet weak var registerLabel: ActiveLabel!
    
    var userName:String = ""
    var password:String = ""

    init() {
        super.init(nibName: "LoginController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor(rgba: "#54575a"))
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(title: "Skip Login", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(rightAction(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        registerLabel.addGestureRecognizer(tap)
        
    }
    
    func tapAction(sender:UITapGestureRecognizer) {
        let register:ProfileSetupViewController = ProfileSetupViewController()
        self.navigationController?.pushViewController(register, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func rightAction(sender:UIBarButtonItem) {
        let register:ProfileSetupViewController = ProfileSetupViewController()
        self.navigationController?.pushViewController(register, animated: true)
    }

    @IBAction func buttonAction(sender: AnyObject) {
        if sender.isEqual(logoinButton) {
            self.loginRequest()
        }else{
            let register:ProfileSetupViewController = ProfileSetupViewController()
            self.navigationController?.pushViewController(register, animated: true)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func loginRequest() {
            userName = userNameTextField!.text!
            password = passwordTextField!.text!
        if AppDelegate.getAppDelegate().network!.isReachable {
            XCGLogger.defaultInstance().debug("有网络")
            if(AppTheme.isNull(userName) || AppTheme.isEmail(userName)) {
                let banner = Banner(title: NSLocalizedString("Email is not filled in.", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            if AppTheme.isNull(password) || AppTheme.isPassword(password) {
                let banner = Banner(title: NSLocalizedString("Password is not filled in.", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            view.setTintColor(UIColor.getBaseColor())

            
            HttpPostRequest.LunaRPostRequest("http://lunar.karljohnchow.com/user/login", data: ["user":["email":userName,"password":password]]) { (result) in
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                
                let json = JSON(result)
                let message = json["message"].stringValue.isEmpty ? NSLocalizedString("not_login", comment: ""):json["message"].stringValue
                let status = json["status"].intValue
                
                let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor: status > 0 ? UIColor.getBaseColor():UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                
                //status > 0 login success or login fail
                if(status > 0 && UserProfile.getAll().count == 0) {
                    let user = json["user"]
                    let jsonBirthday = user["birthday"];
                    let dateString: String = jsonBirthday["date"].stringValue
                    var birthday:String = ""
                    if !jsonBirthday.isEmpty || !dateString.isEmpty {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "y-M-d h:m:s.000000"
                        
                        let birthdayDate = dateFormatter.dateFromString(dateString)
                        dateFormatter.dateFormat = "y-M-d"
                        birthday = dateFormatter.stringFromDate(birthdayDate!)
                    }
                    
                    let userprofile:UserProfile = UserProfile(keyDict: ["id":user["id"].intValue,"first_name":user["first_name"].stringValue,"last_name":user["last_name"].stringValue,"birthday":birthday,"length":user["length"].intValue,"email":user["email"].stringValue, "weight":user["weight"].floatValue])
                    userprofile.add({ (id, completion) in
                        XCGLogger.defaultInstance().debug("Added? id = \(id)")
                    })
                    self.navigationController?.popViewControllerAnimated(true)
                }
               
            }
        }else{
            
            XCGLogger.defaultInstance().debug("没有网络")
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.Cross, animated: true)
            view.setTintColor(UIColor.getBaseColor())
        }
        
    }

}
