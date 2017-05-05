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
    var watchSettingsArray:[(cellName:String,imageName:String)] = []
    var appSettingsArray:[(cellName:String,imageName:String)] = []
    var otherSettingsArray:[(cellName:String,imageName:String)] = []
    var selectedB:Bool = false
    //vibrate and show all color light to find my device, only send one request in 6 sec
    //this action take lot power and we maybe told customer less to use it
    var mFindMydeviceDatetime:Date = Date(timeIntervalSinceNow: -6)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationList.settingsViewController = self
        self.navigationItem.title = NSLocalizedString("Setting", comment: "")
        
        notificationList.bulidNotificationViewUI(self)
        watchSettingsArray = [
            (NSLocalizedString("My Nevo", comment: ""),"icon_nevo"),
            (NSLocalizedString("Notifications", comment: ""),"icon_bell"),
            (NSLocalizedString("Scan Duration", comment: ""), "icon_bluetooth"),
            (NSLocalizedString("Link-Loss Notifications", comment: ""),"icon_chain"),
            (NSLocalizedString("find_my_watch", comment: ""),"icon_crosshair")]
        
        appSettingsArray = [
            (NSLocalizedString("goals", comment: ""), "icon_goals"),
            (NSLocalizedString("unit", comment: ""), "icon_scale")]
        
        otherSettingsArray = [(NSLocalizedString("Support", comment: ""),"icon_support")]
        
        
        notificationList.tableListView.register(UINib(nibName:"SetingLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingLoginIdentifier")
        notificationList.tableListView.register(UINib(nibName:"SetingNotLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingNotLoginIdentifier")
        notificationList.tableListView.register(UINib(nibName:"SetingInfoCell" ,bundle: nil), forCellReuseIdentifier: "SetingInfoIdentifier")
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            self.checkConnection()
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_BLUETOOTH_STATE_CHANGED) { (notification) in
            self.checkConnection()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().startConnect(false)
        notificationList.tableListView.reloadData()
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
        switch indexPath.section{
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
            switch indexPath.row {
            case 0:
                let myNevoController = MyNevoController()
                myNevoController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myNevoController, animated: true)
                return
            case 1:
                let notificationViewController = NotificationViewController()
                notificationViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(notificationViewController, animated: true)
            case 2:
                if UserDefaults.standard.getFirmwareVersion() >= 40 && UserDefaults.standard.getSoftwareVersion() >= 27{
                    let bluetoothScanDurationViewController = BluetoothScanDurationViewController()
                    bluetoothScanDurationViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(bluetoothScanDurationViewController, animated: true)
                }else{
                    showUpdateNevoAlertView()
                }
                
                break;
            case 4:
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
            default:
                break
            }
            
        case 2:
            switch indexPath.row {
            case 0:
                let presetTableViewController = PresetTableViewController()
                presetTableViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(presetTableViewController, animated: true)
            case 1:
                notificationList.unitTextField?.becomeFirstResponder()
                break
            default:
                break
            }
        case 3:
            UIApplication.shared.openURL(URL(string: "http://support.nevowatch.com/support/home")!)
        default: break
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch (section){
        case 0:
            return 1
        case 1:
            return watchSettingsArray.count
        case 2:
            return appSettingsArray.count
        case 3:
            return otherSettingsArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            let users = MEDUserProfile.getAll()
            if users.count>0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SetingInfoIdentifier", for: indexPath)
                cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
                let users = MEDUserProfile.getAll()
                let userprofile:MEDUserProfile = users[0] as! MEDUserProfile
                (cell as! SetingInfoCell).emailLabel.text = userprofile.email
                (cell as! SetingInfoCell).userName.text = "\(userprofile.first_name) \(userprofile.last_name)"
                if let image = ProfileImageManager.shared.getImage() {
                    (cell as! SetingInfoCell).avatarImageView.image = image
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
            let setting = watchSettingsArray[indexPath.row]
            if(indexPath.row == 3){
                return notificationList.LinkLossNotificationsTableViewCell(indexPath, tableView: tableView, model: setting)
            }
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, model: setting)
        case 2:
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, model: appSettingsArray[indexPath.row])
        case 3:
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, model: otherSettingsArray[indexPath.row])
        default:
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, model: otherSettingsArray[indexPath.row]);
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
        
        if UserDefaults.standard.getSoftwareVersion() > 25 {
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
        notificationList.tableListView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.fade)
        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
            reconnect()
        }
    }
    
    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }
    
    
    func isEqualString(_ string1:String,string2:String)->Bool{
        let object1:NSString = NSString(format: "\(string1)" as NSString)
        return object1.isEqual(to: string2)
    }
    
    func showUpdateNevoAlertView(){
        let alertController = UIAlertController(title: NSLocalizedString("Update", comment: ""), message: "Update your Nevo to use this feature", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { _ in
            
            if AppDelegate.getAppDelegate().isConnected() {
                let otaCont:NevoOtaViewController = NevoOtaViewController()
                let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                self.present(navigation, animated: true, completion: nil)
            }else{
                let banner = MEDBanner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }
            
        }))
        alertController.actions.forEach { action in
            action.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
        }
        self.present(alertController, animated: true, completion: nil)
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
