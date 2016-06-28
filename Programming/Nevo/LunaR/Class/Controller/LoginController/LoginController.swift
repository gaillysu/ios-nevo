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

class LoginController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var logoinTableview: UITableView!
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
        self.navigationItem.title = "Nevo Login"
        //userNameTextField.text = "1508496092@qq.com"
        //passwordTextField.text = "123456"
        logoinTableview.registerNib(UINib(nibName:"SetingLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingLoginIdentifier")
        logoinTableview.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "LoginIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        return 50.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (indexPath.section){
        case 0:
            break
        case 1:
            loginRequest()
            break
        case 2:
            
            break
        case 3:
            break
        default: break
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 60
        }
        return 30
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }
        return 20
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView {
        if section == 1 {
            let clickButton:UIButton = UIButton(type: UIButtonType.System)
            clickButton.frame = CGRectMake(0, 0, 120, 40)
            clickButton.setTitle("Forgot password?", forState: UIControlState.Normal)
            clickButton.titleLabel?.textAlignment = NSTextAlignment.Left
            clickButton.addTarget(self, action: #selector(forgotPassword(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            return clickButton
        }
        return UILabel(frame: CGRectMake(0,0,120,40))
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("SetingLoginIdentifier", forIndexPath: indexPath)
            (cell as! SetingLoginCell).userEmail.delegate = self
            (cell as! SetingLoginCell).userPassword.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginIdentifier", forIndexPath: indexPath)
            cell.textLabel?.text = "Login"
            cell.textLabel?.textColor = AppTheme.NEVO_SOLAR_YELLOW()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginIdentifier", forIndexPath: indexPath)
            cell.textLabel?.text = "Create a new Nevo account"
            cell.textLabel?.textColor = AppTheme.NEVO_SOLAR_YELLOW()
            return cell
        default:
            return UITableViewCell()
        }
    }

    @IBAction func registerButtonAction(sender: AnyObject) {
        let registerController =  RegisterController()
        self.navigationController?.pushViewController(registerController, animated: true);
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
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 1500 {
            if !textField.text!.isEmpty {
                userName = textField.text!
            }
        }
        
        if textField.tag == 1600 {
            if !textField.text!.isEmpty {
                password = textField.text!
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        NSLog("textField Did BeginEditing:\(textField.text)")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        NSLog("textField Change:\(textField.text)")
        if textField.tag == 1500 {
            if !textField.text!.isEmpty {
                userName = textField.text!
            }
        }
        
        if textField.tag == 1600 {
            if !textField.text!.isEmpty {
                password = textField.text!
            }
        }
        return true
    }
    
    func forgotPassword(sender:UIButton) {
        
    }
    
    func loginRequest() {
        let usercell:SetingLoginCell = (logoinTableview.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!) as! SetingLoginCell
            userName = usercell.userEmail!.text!
            password = usercell.userPassword!.text!
        if AppDelegate.getAppDelegate().network!.isReachable {
            XCGLogger.defaultInstance().debug("有网络")
            if(AppTheme.isNull(userName) || !AppTheme.isEmail(userName)) {
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

            
            HttpPostRequest.postRequest("http://nevo.karljohnchow.com/user/login", data: ["user":["email":userName,"password":password]]) { (result) in
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
