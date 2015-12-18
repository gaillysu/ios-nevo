//
//  SetingViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

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
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)

        notificationList.bulidNotificationViewUI(self)

        sources = [NSLocalizedString("Link-Loss Notifications", comment: ""),NSLocalizedString("Notifications", comment: ""),NSLocalizedString("My nevo", comment: ""),NSLocalizedString("Support", comment: ""),NSLocalizedString("About", comment: "")]
        sourcesImage = ["new_iOS_link_icon","new_iOS_notfications_icon","new_iOS_mynevo_iocn","new_iOS_support_icon","new_iOS_about_icon"]
        titleArray = [NSLocalizedString("Preset-goals", comment: ""),NSLocalizedString("Find device", comment: "")]
        titleArrayImage = ["new_iOS_goals_icon","new_iOS_findmywatch_icon"]
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return 50.0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (indexPath.section){
        case 0:
            if(isEqualString("\(sources.objectAtIndex(indexPath.row))",string2: NSLocalizedString("Notifications", comment: ""))){
                AppTheme.DLog("Notifications")
                let notification:NotificationViewController = NotificationViewController()
                notification.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(notification, animated: true)
            }

            if(isEqualString("\(sources.objectAtIndex(indexPath.row))",string2: NSLocalizedString("My nevo", comment: ""))){
                AppTheme.DLog("My nevo")
                let mynevo:MyNevoController = MyNevoController()
                mynevo.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(mynevo, animated: true)
            }
            break
        case 1:
            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("Find device", comment: ""))){
                AppTheme.DLog("Find device")
                findMydevice()
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("Preset-goals", comment: ""))){
                AppTheme.DLog("Preset-goals")
                let presetView:PresetTableViewController = PresetTableViewController()
                presetView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(presetView, animated: true)
            }
            break
        default: break
        }

    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 2

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch (section){
        case 0:
            return sources.count
        case 1:
            return titleArray.count
        default: return 1;
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            if(indexPath.row == 0){
                return notificationList.LinkLossNotificationsTableViewCell(indexPath, tableView: tableView, title: sources[indexPath.row] as! String ,imageName:sourcesImage[indexPath.row])
            }
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[indexPath.row] as! String ,imageName:sourcesImage[indexPath.row])
        case 1:
            return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row] ,imageName:titleArrayImage[indexPath.row])
        default: return notificationList.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[1] as! String ,imageName:titleArrayImage[indexPath.row]);
        }
    }

    // MARK: - SetingViewController function
    /**
    Check the update
    */
    func  checkUpdateVersion() {
        MBProgressHUD.showMessage(NSLocalizedString("is_checking_the_update",comment: ""))
        AppTheme.getAppStoreVersion({ (stringVersion, version) -> Void in
            MBProgressHUD.hideHUD()
            let loclString:String = (NSBundle.mainBundle().infoDictionary! as NSDictionary).objectForKey("CFBundleShortVersionString") as! String
            let versionString:NSString = loclString.stringByReplacingOccurrencesOfString(".", withString: "")
            let versionNumber:Double = Double(versionString.floatValue)
            if(version>versionNumber){
                let alertView:UIAlertView = UIAlertView(title: NSLocalizedString("Found the new version",comment: ""), message:String(format: "Found New version:(%@)", stringVersion!), delegate:self, cancelButtonTitle: NSLocalizedString("cancel",comment: ""), otherButtonTitles: NSLocalizedString("Enter",comment: ""))
                alertView.show()
            }else{
                MBProgressHUD.showSuccess(NSLocalizedString("nevolatestversion",comment: ""))
            }
        })
    }

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
