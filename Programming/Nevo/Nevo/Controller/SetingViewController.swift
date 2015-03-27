//
//  SetingViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetingViewController: UIViewController,SelectionTypeDelegate,SyncControllerDelegate,ButtonManagerCallBack,SwitchActionDelegate {

    private var mSyncController:SyncController?

    @IBOutlet var notificationList: SetingView!

    private var mNotificationType:NotificationType = NotificationType.CALL
    private var mNotificationSettingArray:[NotificationSetting] = []
    var sources:NSArray!
    var selectedB:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        notificationList.bulidNotificationViewUI(self)

        initNotificationSettingArray()

        sources = ["Notifications"]
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()
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
            SetingViewController.refreshNotificationSetting(&setting)
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
            SetingViewController.refreshNotificationSetting(&settingArray[i])
        }
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if sender.isEqual(notificationList.animationView?.getNoConnectScanButton()?) {
            NSLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(notificationList.backButton) {
           self.dismissViewControllerAnimated(true, completion: nil)
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

    // MARK: - SwitchActionDelegate
    func onSwitch(results:Bool ,sender:UISwitch){
        mNotificationType = mNotificationSettingArray[sender.tag-1].getType()
        var notSetting:NotificationSetting = NotificationSetting.indexOfObjectAtType(mNotificationSettingArray, type: mNotificationType)!
        EnterNotificationController.setMotorOnOff(NSString(string: notSetting.typeName), motorStatus: results)
        SetingViewController.refreshNotificationSettingArray(&mNotificationSettingArray)
        //send request to watch
        mSyncController?.SetNortification(mNotificationSettingArray)
    }

    // MARK: - SelectionTypeDelegate
    func onSelectedType(results:Bool,type:NSString){
        NSLog("type===:\(type)")
        SetingViewController.refreshNotificationSettingArray(&mNotificationSettingArray)
        notificationList.tableListView.reloadData()
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){

        if !selectedB {
            let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.textLabel?.textColor = UIColor.whiteColor()

            var soures:[NSIndexPath] = []
            var indexPathRow:NSIndexPath!
            for var index:Int = 0 ; index < mNotificationSettingArray.count ; index++ {
                indexPathRow = NSIndexPath(forRow:index + 1, inSection: 0)
                soures.append(indexPathRow)
            }
            selectedB = true
            tableView.insertRowsAtIndexPaths(soures, withRowAnimation: UITableViewRowAnimation.Bottom)
        }else{
            if indexPath.row == 0 {
                let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.selected = false
                var soures:[NSIndexPath] = []
                var indexPathRow:NSIndexPath!
                for var index:Int = 0 ; index < mNotificationSettingArray.count ; index++ {
                    indexPathRow = NSIndexPath(forRow:index + 1, inSection: 0)
                    soures.append(indexPathRow)
                }
                selectedB = false
                tableView.deleteRowsAtIndexPaths(soures, withRowAnimation: UITableViewRowAnimation.Bottom)
            }else{
                var indexPathRow = NSIndexPath(forRow:0, inSection: 0)
                let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPathRow)!
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.selected = true
                mNotificationType = mNotificationSettingArray[indexPath.row-1].getType()
                self.performSegueWithIdentifier("EnterNotification", sender: self)
            }
        }

    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if selectedB {
            NSLog("count:\(sources.count + mNotificationSettingArray.count)")
            return sources.count + mNotificationSettingArray.count
        }
        return sources.count
        //return mNotificationSettingArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SetingCell", forIndexPath: indexPath) as UITableViewCell
            endCell.selectedBackgroundView = UIImageView(image: UIImage(named:"selectedButton"))
            endCell.textLabel?.text = sources.objectAtIndex(indexPath.row) as? String
            endCell.layer.borderWidth = 0.5;
            endCell.layer.borderColor = UIColor.grayColor().CGColor;
            return endCell
        }
        let cell:TableListCell = notificationList.NotificationlistCell(indexPath, dataSource: mNotificationSettingArray) as TableListCell
        cell.mSwitchDelegate = self
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
