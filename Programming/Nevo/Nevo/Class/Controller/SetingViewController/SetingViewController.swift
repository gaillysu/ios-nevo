//
//  SetingViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner

class SetingViewController: UIViewController,SyncControllerDelegate,ButtonManagerCallBack,UIAlertViewDelegate {

    @IBOutlet var notificationList: SetingView!

    private var mNotificationType:NotificationType = NotificationType.CALL
    var sources:NSArray!
    var sourcesImage:[String] = []
    var titleArray:[String] = []
    var titleArrayImage:[String] = []
    var selectedB:Bool = false
    //vibrate and show all color light to find my device, only send one request in 6 sec
    //this action take lot power and we maybe told customer less to use it
    var mFindMydeviceDatetime:NSDate = NSDate(timeIntervalSinceNow: -6)


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Setting", comment: "")

        notificationList.bulidNotificationViewUI(self)

        sources = [NSLocalizedString("Link-Loss Notifications", comment: ""),NSLocalizedString("Notifications", comment: ""),NSLocalizedString("My nevo", comment: ""),NSLocalizedString("Support", comment: ""),NSLocalizedString("Connect to other apps", comment: "")]
        sourcesImage = ["new_iOS_link_icon","new_iOS_notfications_icon","new_iOS_mynevo_iocn","new_iOS_support_icon","new_iOS_link_icon"]
        titleArray = [NSLocalizedString("goals", comment: ""),NSLocalizedString("find_my_watch", comment: ""),NSLocalizedString("forget_watch", comment: "")]
        titleArrayImage = ["new_iOS_goals_icon","new_iOS_findmywatch_icon","forget_watch","iOS_rate"]

        let userProfile:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(userProfileAction(_:)))
        self.navigationItem.rightBarButtonItem = userProfile
        
        notificationList.tableListView.registerNib(UINib(nibName:"SetingLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingLoginIdentifier")
        notificationList.tableListView.registerNib(UINib(nibName:"SetingNotLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingNotLoginIdentifier")
    }
    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func userProfileAction(sender:AnyObject) {
        let userprofile:UserProfileController = UserProfileController()
        userprofile.title = "UserProfile"
        userprofile.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(userprofile, animated: true)
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if sender.isEqual(notificationList.mSendLocalNotificationSwitchButton){
            AppTheme.DLog("setIsSendLocalMsg \(notificationList.mSendLocalNotificationSwitchButton.on)")
            ConnectionManager.sharedInstance.setIsSendLocalMsg(notificationList.mSendLocalNotificationSwitchButton.on)
        }

    }

    // MARK: - SyncControllerDelegate
    func receivedRSSIValue(number:NSNumber){

    }

    func packetReceived(packet:NevoPacket) {

    }

    func connectionStateChanged(isConnected : Bool) {
        //Maybe we just got disconnected, let's check
        checkConnection()
    }

    func syncFinished(){

    }


    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        return 50.0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (indexPath.section){
        case 0:
            let logoin:LoginController = LoginController()
            logoin.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(logoin, animated: true)
            break
        case 1:
            if(isEqualString("\(sources.objectAtIndex(indexPath.row))",string2: NSLocalizedString("Notifications", comment: ""))){
                AppTheme.DLog("Notifications")
                let notification:NotificationViewController = NotificationViewController()
                notification.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(notification, animated: true)
            }

            if(isEqualString("\(sources.objectAtIndex(indexPath.row))",string2: NSLocalizedString("My nevo", comment: ""))){
                if(AppDelegate.getAppDelegate().isConnected()){
                    AppTheme.DLog("My nevo")
                    let mynevo:MyNevoController = MyNevoController()
                    mynevo.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(mynevo, animated: true)
                }else{
                    let banner = Banner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.5)
                }
            }

            if(isEqualString("\(sources[indexPath.row])",string2: NSLocalizedString("Support", comment: ""))){
                AppTheme.DLog("Support")
                let supportView:SupportViewController = SupportViewController()
                supportView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(supportView, animated: true)
            }
            
            if(isEqualString("\(sources[indexPath.row])",string2: NSLocalizedString("Connect to other apps", comment: ""))){
                AppTheme.DLog("Connect to other apps")
                let supportView:ConnectOtherAppsController = ConnectOtherAppsController()
                supportView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(supportView, animated: true)
            }
            break
        case 2:
            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("find_my_watch", comment: ""))){
                AppTheme.DLog("find_my_watch")
                findMydevice()
                let cellView = tableView.cellForRowAtIndexPath(indexPath)
                if(cellView != nil){
                    for activityView in cellView!.contentView.subviews{
                        if(activityView.isKindOfClass(UIActivityIndicatorView.classForCoder())) {
                            let activity:UIActivityIndicatorView = activityView as! UIActivityIndicatorView
                            if(!activity.isAnimating()){
                                activity.startAnimating()
                                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
                                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                                    activity.stopAnimating()
                                })
                            }
                            break
                        }
                    }
                }
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("goals", comment: ""))){
                AppTheme.DLog("Preset-goals")
                let presetView:PresetTableViewController = PresetTableViewController()
                presetView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(presetView, animated: true)
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("forget_watch", comment: ""))){
                AppTheme.DLog("forget_watch")
                if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){

                    let actionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_your_nevo", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()

                    let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: { (alert) -> Void in

                    })
                    actionSheet.addAction(alertAction)

                    let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("forget", comment: ""), style: UIAlertActionStyle.Default, handler: { ( alert) -> Void in
                        AppDelegate.getAppDelegate().forgetSavedAddress()
                        let tutrorial:HomeTutorialController = HomeTutorialController()
                        let nav:UINavigationController = UINavigationController(rootViewController: tutrorial)
                        nav.navigationBarHidden = true
                        self.presentViewController(nav, animated: true, completion: nil)
                    })
                    actionSheet.addAction(alertAction2)

                    self.presentViewController(actionSheet, animated: true, completion: nil)
                }else{
                    let actionSheet:UIAlertView = UIAlertView(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_your_nevo", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("forget", comment: ""))
                    actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
                    actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    actionSheet.show()
                }
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("Rate", comment: ""))){
                if(AppDelegate.getAppDelegate().getNetworkState()) {
                    iRate.sharedInstance().openRatingsPageInAppStore()
                }else{
                    let banner = Banner(title: NSLocalizedString("Not Internet", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.redColor())
                    banner.dismissesOnTap = true
                    banner.show(duration: 0.6)
                }
            }
            break
        case 3:
            let user:NSArray = UserProfile.getAll()
            if(user.count>0){
                let userProfile:UserProfile = user.objectAtIndex(0) as! UserProfile
                if(userProfile.remove()){
                    let indexPath = NSIndexPath(forRow: 0, inSection: 2)
                    let tableViewCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
                    tableViewCell.accessoryType = UITableViewCellAccessoryType.None
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 4
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch (section){
        case 0:
            return 1
        case 1:
            return sources.count
        case 2:
            return titleArray.count
        case 3:
            return 1
        default: return 1;
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            let user:NSArray = UserProfile.getAll()
            if user.count>0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SetingLoginIdentifier", forIndexPath: indexPath)
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("SetingNotLoginIdentifier", forIndexPath: indexPath)
                return cell
            }
            
        case 1:
            if(indexPath.row == 0){
                return notificationList.LinkLossNotificationsTableViewCell(indexPath, tableView: tableView, title: sources[indexPath.row] as! String ,imageName:sourcesImage[indexPath.row])
            }
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[indexPath.row] as! String ,imageName:sourcesImage[indexPath.row])
        case 2:
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row] ,imageName:titleArrayImage[indexPath.row])
        case 3:
            let cell = notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title:"" ,imageName:"")
            cell.accessoryType = UITableViewCellAccessoryType.None

            var loginLabel = cell.contentView.viewWithTag(1900)
            if(loginLabel == nil){
                loginLabel = UILabel(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,cell.frame.size.height))
                loginLabel?.backgroundColor = UIColor.clearColor()
                loginLabel?.tag = 1900
                (loginLabel as! UILabel).textColor = UIColor.whiteColor()
                (loginLabel as! UILabel).textAlignment = NSTextAlignment.Center
                (loginLabel as! UILabel).text = "Login"
                cell.contentView.addSubview(loginLabel!)
                cell.backgroundColor=UIColor(red:129.0/255.0, green: 150.0/255.0, blue: 248.0/255.0, alpha: 1.0)
            }
            let user:NSArray = UserProfile.getAll()
            if(user.count>0){
                (loginLabel as! UILabel).text = "Logout"
                cell.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
            }
            return cell

        default: return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[1] as! String ,imageName:titleArrayImage[indexPath.row]);
        }
    }

    // MARK: - SetingViewController function
    
    func findMydevice(){
        let minDelay:Double = 6
        let offset:Double = (NSDate().timeIntervalSince1970 - mFindMydeviceDatetime.timeIntervalSince1970)
        AppTheme.DLog("findMydevice offset:\(offset)")
        if (offset < minDelay) {
            return
        }
        AppDelegate.getAppDelegate().SetLedOnOffandVibrator(0x3F0000, motorOnOff: true)
        mFindMydeviceDatetime = NSDate()
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
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex == 1){
            AppTheme.toOpenUpdateURL()
        }
        if(buttonIndex == 0) {
            AppDelegate.getAppDelegate().forgetSavedAddress()
            let tutrorial:TutorialOneViewController = TutorialOneViewController()
            let nav:UINavigationController = UINavigationController(rootViewController: tutrorial)
            nav.navigationBarHidden = true
            self.presentViewController(nav, animated: true, completion: nil)
        }
    }

    func isEqualString(string1:String,string2:String)->Bool{
        let object1:NSString = NSString(format: "\(string1)")
        return object1.isEqualToString(string2)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }

}
