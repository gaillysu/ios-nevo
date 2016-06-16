//
//  LoginController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginController: UIViewController {

    @IBOutlet weak var logoinTableview: UITableView!

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
            clickButton.setTitle("忘记密码?", forState: UIControlState.Normal)
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
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginIdentifier", forIndexPath: indexPath)
            cell.textLabel?.text = "Logoin"
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
    
    
    func forgotPassword(sender:UIButton) {
        
    }
}
