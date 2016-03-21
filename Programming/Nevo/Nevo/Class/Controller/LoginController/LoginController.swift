//
//  LoginController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!

    init() {
        super.init(nibName: "LoginController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Nevo Login"
        userNameTextField.text = "1508496092@qq.com"
        passwordTextField.text = "123456"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButtonAction(sender: AnyObject) {
        if(self.passwordTextField.text == "" || self.userNameTextField.text == "" ){
            self.showMessage("E-mail or password is empty", type: .Error, options: [.HideOnTap(true),
                .AutoHide(true)])
            return;
        }
        //let dict:Dictionary = Dictionary(dictionaryLiteral: ("user",["uid":"gaillysu"]),("access_token","b85dcb3b85e925200f3fd4cafe6dce92295f449d9596b137941de7e9e2c3e7ae"),("pin","5234274"))
        /**http://api.nevowatch.com/api/account/login "https://api.validic.com/v1/organizations/56d3b075407e010001000000/authorization/new_user"*/
        var dict:[String : AnyObject] = [:]
        dict["password"] = self.passwordTextField.text
        dict["user"] = self.userNameTextField.text

        HttpPostRequest.postRequest("http://api.nevowatch.com/api/account/login", data: dict) { (result) -> Void in
            let error:String? = String(result["error"])
            if let tempErrorCode = error {
                // TODO please unwrap this, I dont get it. lol.
                if(tempErrorCode == "Optional(-12)"){
                    self.showMessage("Invalid E-mail", type: .Error, options: [.HideOnTap(true),.AutoHide(true)])
                }else if(tempErrorCode == "Optional(1)" && result["state"] as! String == "success" && result.objectForKey("uid") != nil){
                    self.showMessage("User logged in", type: .Success, options: [.HideOnTap(true),.AutoHide(true)])
                    self.delay(1.3) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }

                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(true, forKey: "User_Logged_In")
                    defaults.setValue(result["uid"], forKey: "User_Logged_In_UID")
                    defaults.setValue(result["token"], forKey: "User_Logged_In_Token")
                }
            }
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
    
}
