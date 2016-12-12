//
//  SetingViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import SwiftEventBus
import XCGLogger

class SetingViewController: UIViewController,ButtonManagerCallBack,UIAlertViewDelegate {

    @IBOutlet var notificationList: SetingView!

    fileprivate var mNotificationType:NotificationType = NotificationType.call
    var sources:NSArray!
    var sourcesImage:[String] = []
    var titleArray:[String] = []
    var titleArrayImage:[String] = []
    var selectedB:Bool = false
    //vibrate and show all color light to find my device, only send one request in 6 sec
    //this action take lot power and we maybe told customer less to use it
    var mFindMydeviceDatetime:Date = Date(timeIntervalSinceNow: -6)


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Setting", comment: "")

        notificationList.bulidNotificationViewUI(self)

        sources = [NSLocalizedString("Link-Loss Notifications", comment: ""),NSLocalizedString("Notifications", comment: ""),NSLocalizedString("My Nevo", comment: ""),NSLocalizedString("Support", comment: "")]
        sourcesImage = ["new_iOS_link_icon","new_iOS_notfications_icon","new_iOS_mynevo_iocn","new_iOS_support_icon"]
        titleArray = [NSLocalizedString("other_settings", comment: ""),NSLocalizedString("find_my_watch", comment: ""),NSLocalizedString("forget_watch", comment: ""),NSLocalizedString("logout", comment: "")]
        titleArrayImage = ["new_iOS_goals_icon","new_iOS_findmywatch_icon","forget_watch","logout"]
        
        notificationList.tableListView.register(UINib(nibName:"SetingLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingLoginIdentifier")
        notificationList.tableListView.register(UINib(nibName:"SetingNotLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingNotLoginIdentifier")
        notificationList.tableListView.register(UINib(nibName:"SetingInfoCell" ,bundle: nil), forCellReuseIdentifier: "SetingInfoIdentifier")
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            self.checkConnection()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().startConnect(false)
        
        notificationList.tableListView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func userProfileAction(_ sender:AnyObject) {
        
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(_ sender:AnyObject){
        if sender.isEqual(notificationList.mSendLocalNotificationSwitchButton){
            XCGLogger.default.debug("setIsSendLocalMsg \(self.notificationList.mSendLocalNotificationSwitchButton.isOn)")
            ConnectionManager.sharedInstance.setIsSendLocalMsg(notificationList.mSendLocalNotificationSwitchButton.isOn)
        }

    }


    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 80
        }
        return 50.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        switch ((indexPath as NSIndexPath).section){
        case 0:
            let users = MEDUserProfile.getAll()
            if users.count == 0 {
                let login:LoginController = LoginController()
                let naviController = UINavigationController(rootViewController: login)
                self.present(naviController, animated: true, completion: nil)
            }else{
                let userprofile:UserProfileController = UserProfileController()
                userprofile.isPushed = true
                userprofile.title = "Profile"
                userprofile.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(userprofile, animated: true)
            }
        case 1:
            if(isEqualString("\(sources.object(at: indexPath.row))",string2: NSLocalizedString("Notifications", comment: ""))){
                XCGLogger.default.debug("Notifications")
                let notification:NotificationViewController = NotificationViewController()
                notification.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(notification, animated: true)
            }

            if(isEqualString("\(sources.object(at: indexPath.row))",string2: NSLocalizedString("My Nevo", comment: ""))){
                if(AppDelegate.getAppDelegate().isConnected()){
                    XCGLogger.default.debug("My nevo")
                    let mynevo:MyNevoController = MyNevoController()
                    mynevo.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(mynevo, animated: true)
                }else{
                    let banner = MEDBanner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.5)
                }
            }

            if(isEqualString("\(sources[indexPath.row])",string2: NSLocalizedString("Support", comment: ""))){
                XCGLogger.default.debug("Support")
                let supportView:SupportViewController = SupportViewController()
                supportView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(supportView, animated: true)
            }
            
            if(isEqualString("\(sources[indexPath.row])",string2: NSLocalizedString("Connect to other apps", comment: ""))){
               
                let users = MEDUserProfile.getAll()
                if users.count == 0 {
                    let logoin:LoginController = LoginController()
                    logoin.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(logoin, animated: true)
                }else{
                    XCGLogger.default.debug("Connect to other apps")
                    let supportView:ConnectOtherAppsController = ConnectOtherAppsController()
                    supportView.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(supportView, animated: true)
                }
            }
            break
        case 2:
            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("find_my_watch", comment: ""))){
                XCGLogger.default.debug("find_my_watch")
                findMydevice()
                let cellView = tableView.cellForRow(at: indexPath)
                if(cellView != nil){
                    for activityView in cellView!.contentView.subviews{
                        if(activityView.isKind(of: UIActivityIndicatorView.classForCoder())) {
                            let activity:UIActivityIndicatorView = activityView as! UIActivityIndicatorView
                            if(!activity.isAnimating){
                                activity.startAnimating()
                                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                                    activity.stopAnimating()
                                })
                            }
                            break
                        }
                    }
                }
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("other_settings", comment: ""))){
                XCGLogger.default.debug("other settings")
                //let presetView:PresetTableViewController = PresetTableViewController()
                //presetView.hidesBottomBarWhenPushed = true
                let otherController:OtherController = OtherController()
                otherController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(otherController, animated: true)
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("forget_watch", comment: ""))){
                XCGLogger.default.debug("forget_watch")
                let actionSheet:ActionSheetView = ActionSheetView(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_your_nevo", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                let alertAction:AlertAction = AlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: { (alert) -> Void in
                    
                })
                alertAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                actionSheet.addAction(alertAction)
                
                let alertAction2:AlertAction = AlertAction(title: NSLocalizedString("forget", comment: ""), style: UIAlertActionStyle.default, handler: { ( alert) -> Void in
                    
                    AppDelegate.getAppDelegate().forgetSavedAddress()
                    
                    //forget watch set wacthid= -1
                    AppDelegate.getAppDelegate().setWatchInfo(-1, model: -1)
                    
                    let tutrorial:TutorialOneViewController = TutorialOneViewController()
                    let nav:UINavigationController = UINavigationController(rootViewController: tutrorial)
                    nav.isNavigationBarHidden = true
                    
                    self.present(nav, animated: true, completion: { 
                        UIApplication.shared.keyWindow?.rootViewController = nav
                    })
                })
                alertAction2.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                actionSheet.addAction(alertAction2)
                
                /// Theme adjust
                alertAction.viewDefaultColorful()
                alertAction2.viewDefaultColorful()
                
                self.present(actionSheet, animated: true, completion: nil)
            }

            if indexPath.row == 3{
                
                let dialogController = ActionSheetView(title: NSLocalizedString("Are you sure you want to log out?", comment: ""), message: nil, preferredStyle: .alert)
                let confirmAction = AlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (_) in
                    let users = MEDUserProfile.getAll()
                    if(users.count>0){
                        let userProfile:MEDUserProfile = users.first as! MEDUserProfile
                        if(userProfile.remove()){
                            let tableViewCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
                            tableViewCell.accessoryType = UITableViewCellAccessoryType.none
                            tableViewCell.textLabel?.text = "Login"
                            tableView.reloadData()
                        }else{
                            let banner = MEDBanner(title: NSLocalizedString("Logout_error", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                            banner.dismissesOnTap = true
                            banner.show(duration: 1.2)
                        }
                    }else{
                        let loginController:LoginController = LoginController()
                        loginController.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(loginController, animated: true)
                    }
                    
                })
                confirmAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                dialogController.addAction(confirmAction)
                
                let cancelAction = AlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                cancelAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                dialogController.addAction(cancelAction)
                
                /// Theme adjust
                confirmAction.viewDefaultColorful()
                cancelAction.viewDefaultColorful()

                self.present(dialogController, animated: true, completion: nil)
            }
            break
        case 3:
            let users = MEDUserProfile.getAll()
            if(users.count>0){
                let userProfile:MEDUserProfile = users.first as! MEDUserProfile
                if(userProfile.remove()){
                    let tableViewCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
                    tableViewCell.accessoryType = UITableViewCellAccessoryType.none
                    tableViewCell.backgroundColor=UIColor(red:129.0/255.0, green: 150.0/255.0, blue: 248.0/255.0, alpha: 1.0)
                    let loginLabel = tableViewCell.contentView.viewWithTag(1900)
                    (loginLabel as! UILabel).text = "Login"
                }else{
                    let loginController:LoginController = LoginController()
                    loginController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(loginController, animated: true)
                }
            }else{
                let loginController:LoginController = LoginController()
                loginController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(loginController, animated: true)
            }
        default: break
        }

    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch (section){
        case 0:
            return 1
        case 1:
            return sources.count
        case 2:
            let users = MEDUserProfile.getAll()
            if users.count>0{
                return titleArray.count
            }else{
                return titleArray.count-1
            }
        case 3:
            return 1
        default: return 1;
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).section){
        case 0:
            let users = MEDUserProfile.getAll()
            if users.count>0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SetingInfoIdentifier", for: indexPath)
                cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
                let users = MEDUserProfile.getAll()
                let userprofile:MEDUserProfile = users[0] as! MEDUserProfile
                (cell as! SetingInfoCell).emailLabel.text = userprofile.email
                (cell as! SetingInfoCell).userName.text = "\(userprofile.first_name) \(userprofile.last_name)"
                
                /// 每次 cell 显示前都给头像先设置成默认图片，不然切换用户时，原 imageView 的 image 因为没有被销毁，还是会显示成上个用户的头像。
                let usericonImage = UIImage(named: "usericon")
                (cell as! SetingInfoCell).avatarImageView.image = usericonImage
                
                if let resultArray = AppTheme.LoadKeyedArchiverName(NevoAllKeys.MEDAvatarKeyAfterSave()) {
                    if let avatar = resultArray as? UIImage {
                        (cell as! SetingInfoCell).avatarImageView.image = avatar
                    }
                }
                
                cell.viewDefaultColorful()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SetingNotLoginIdentifier", for: indexPath)
                cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)

                cell.viewDefaultColorful()
                return cell
            }
            
        case 1:
            if(indexPath.row == 0){
                return notificationList.LinkLossNotificationsTableViewCell(indexPath, tableView: tableView, title: sources[indexPath.row] as! String ,imageName:sourcesImage[indexPath.row])
            }
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[indexPath.row] as! String ,imageName:sourcesImage[indexPath.row])
        case 2:
            let users = MEDUserProfile.getAll()
            var textString:String = NSLocalizedString("log_out", comment: "")
            if(users.count == 0){
                textString = NSLocalizedString("Login", comment: "")
            }
            titleArray[3] = textString
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row] ,imageName:titleArrayImage[indexPath.row])

        default: return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[1] as! String ,imageName:titleArrayImage[indexPath.row]);
        }
    }

    // MARK: - SetingViewController function
    
    func findMydevice(){
        let minDelay:Double = 6
        let offset:Double = (Date().timeIntervalSince1970 - mFindMydeviceDatetime.timeIntervalSince1970)
        XCGLogger.default.debug("findMydevice offset:\(offset)")
        if (offset < minDelay) {
            return
        }

        if AppDelegate.getAppDelegate().getMconnectionController()!.getSoftwareVersion() > 25 {
            AppDelegate.getAppDelegate().sendRequest(FindWatchRequest(ledtype: FindWatchLEDType.allWhiteLED, motorOnOff: true))
        }else{
            AppDelegate.getAppDelegate().sendRequest(LedLightOnOffNevoRequest(ledpattern: 0x3F0000, motorOnOff: true))
        }
        mFindMydeviceDatetime = Date()
    }

    /**
     Checks if any device is currently connected
     */
    func checkConnection() {

        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
            reconnect()
        }
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }


    // MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        if(buttonIndex == 1){
            AppTheme.toOpenUpdateURL()
        }
        if(buttonIndex == 0) {
            AppDelegate.getAppDelegate().forgetSavedAddress()
            let tutrorial:TutorialOneViewController = TutorialOneViewController()
            let nav:UINavigationController = UINavigationController(rootViewController: tutrorial)
            nav.isNavigationBarHidden = true
            self.present(nav, animated: true, completion: nil)
        }
    }

    func isEqualString(_ string1:String,string2:String)->Bool{
        let object1:NSString = NSString(format: "\(string1)" as NSString)
        return object1.isEqual(to: string2)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }

}

extension SetingViewController:UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            transitionContext.containerView.addSubview(self.view)
            toView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            
            UIView.animate(withDuration: 3, animations: {
                self.view.frame = transitionContext.containerView.frame
                toView.frame = UIScreen.main.bounds
                }, completion: { (_) in
                    self.view.removeFromSuperview()
                    transitionContext.containerView.addSubview(toView)
                    transitionContext.completeTransition(true)
            })
        }
    }
}
