//
//  NotificationController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationController: UIViewController,SelectionTypeDelegate,SyncControllerDelegate,ButtonManagerCallBack {

    private var mSyncController:SyncController?

    @IBOutlet var notificationList: NotificationView!

    private var mNotificationType:NotificationType = NotificationType.CALL
    private var mNotificationSettingArray:[NotificationSetting] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        notificationList.bulidNotificationViewUI(self,navigationItem: self.navigationItem)

        initNotificationSettingArray()
    }

    override func viewDidAppear(animated: Bool) {
//        checkConnection()
        //send request to watch, if there is no connect , it will auto to conncet
        mSyncController?.SetNortification(mNotificationSettingArray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /**
    init the mNotificationSettingArray
    
    :returns:
    */
    func initNotificationSettingArray() {
        var notificationTypeArray:[NotificationType] = [NotificationType.CALL, NotificationType.EMAIL, NotificationType.FACEBOOK, NotificationType.SMS, NotificationType.CALENDAR, NotificationType.WECHAT]
        for notificationType in notificationTypeArray {
            var setting = NotificationSetting(type: notificationType, color: 0)
            NotificationController.refreshNotificationSetting(&setting)
            mNotificationSettingArray.append(setting)
        }
    }
    
    /**
    reresh NotificationSetting
    */
    class func refreshNotificationSetting(inout setting:NotificationSetting) {
        var color = NSNumber(unsignedInt: EnterNotificationController.getLedColor(setting.getType().rawValue))
        var states = EnterNotificationController.getMotorOnOff(setting.getType().rawValue)
        setting.updateValue(color, states: states)
    }
    
    /**
    reresh NotificationSetting Array
    */
    class func refreshNotificationSettingArray(inout settingArray:[NotificationSetting]) {
        for var i=0;i<settingArray.count;i++ {
            NotificationController.refreshNotificationSetting(&settingArray[i])
        }
    }
    
    
    
    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if sender.isEqual(notificationList.animationView?.getNoConnectScanButton()?) {
            NSLog("noConnectScanButton")
            reconnect()
        }
    }

    // MARK: - SyncControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func packetReceived(packet:NevoPacket) {

    }

    /**
    See SyncControllerDelegate
    */
    func connectionStateChanged(isConnected : Bool) {
        //Maybe we just got disconnected, let's check
        checkConnection()
    }

    /**
    Checks if any device is currently connected
    */
    func checkConnection() {
        if mSyncController != nil && !(mSyncController!.isConnected()) {
            //We are currently not connected
            notificationList.addSubview(notificationList.animationView.bulibNoConnectView())
            reconnect()
        } else {
            notificationList.animationView?.endConnectRemoveView()
        }
        
        
    }

    func reconnect() {
        notificationList.animationView.RotatingAnimationObject(notificationList.animationView.getNoConnectImage()!)
        mSyncController?.connect()
    }

    // MARK: - SelectionTypeDelegate
    func onSelectedType(results:Bool,type:NSString){
        NSLog("type===:\(type)")
        NotificationController.refreshNotificationSettingArray(&mNotificationSettingArray)
        notificationList.tableListView.reloadData()
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        return 50.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        mNotificationType = mNotificationSettingArray[indexPath.row].getType()
        self.performSegueWithIdentifier("EnterNotification", sender: self)
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return mNotificationSettingArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = notificationList.NotificationlistCell(indexPath, dataSource: mNotificationSettingArray)
        return cell
    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "EnterNotification"){
            var notficp = segue.destinationViewController as EnterNotificationController
            notficp.mDelegate = self
            
            notficp.mNotificationSettingArray = mNotificationSettingArray
            notficp.mCurrentNotificationSetting = NotificationSetting.indexOfObjectAtType(mNotificationSettingArray, type: mNotificationType)

            for setting in mNotificationSettingArray {
                NSLog(setting.description())
            }
            NSLog("\(mNotificationType.rawValue)")
        }

    }

}
