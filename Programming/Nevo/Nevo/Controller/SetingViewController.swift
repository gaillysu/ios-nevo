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

        sources = [NSLocalizedString("Notifications", comment: ""),NSLocalizedString("Link-Loss Notifications", comment: ""),NSLocalizedString("My nevo", comment: ""),NSLocalizedString("Find device", comment: "")]
        //NSLocalizedString("Firmware Upgrade", comment: "")
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()
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
        if sender.isEqual(notificationList.animationView?.getNoConnectScanButton()) {
            NSLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(notificationList.backButton) {
           self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if sender is UISwitch {
            var switchButton = sender as! UISwitch
            if switchButton.isEqual(notificationList.mSendLocalNotificationSwitchButton){
                NSLog("setIsSendLocalMsg \(switchButton.on)")
                ConnectionManager.sharedInstance.setIsSendLocalMsg(switchButton.on)
            }
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
            var isView:Bool = false
            for view in notificationList.subviews {
                let anView:UIView = view as! UIView
                if anView.isEqual(notificationList.animationView.bulibNoConnectView()) {
                    isView = true
                }
            }
            if !isView {
                notificationList.addSubview(notificationList.animationView.bulibNoConnectView())
                reconnect()
            }
        } else {

            notificationList.animationView.endConnectRemoveView()
        }
        self.view.bringSubviewToFront(notificationList.titleBgView)
    }

    func reconnect() {
        notificationList.animationView.RotatingAnimationObject(notificationList.animationView.getNoConnectImage()!)
        mSyncController?.connect()
    }

    // MARK: - SwitchActionDelegate
    func onSwitch(results:Bool ,sender:UISwitch){
        let indexPath:NSIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        var cell:TableListCell = notificationList.tableListView.cellForRowAtIndexPath(indexPath) as! TableListCell
        if(results){
            cell.round.hidden = false
        }else{
            cell.round.hidden = true
        }

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
    func deleteRowsAtIndexPaths(tableView:UITableView, indexPath:NSIndexPath){
        allCellTextColor(tableView)

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
    }

    func insertRowsAtIndexPaths(tableView:UITableView,indexPath:NSIndexPath){
        allCellTextColor(tableView)

        var soures:[NSIndexPath] = []
        var indexPathRow:NSIndexPath!
        for var index:Int = 0 ; index < mNotificationSettingArray.count ; index++ {
            indexPathRow = NSIndexPath(forRow:index + 1, inSection: 0)
            soures.append(indexPathRow)
        }
        selectedB = true
        tableView.insertRowsAtIndexPaths(soures, withRowAnimation: UITableViewRowAnimation.Bottom)
    }

    func didSelectTableViewCell(tableView:UITableView,didIndexPath:NSIndexPath) {
        allCellTextColor(tableView)
        var indexPathRow:NSIndexPath!
        indexPathRow = NSIndexPath(forRow:0, inSection: didIndexPath.section)
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPathRow)!
//        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.selected = true
    }

    func allCellTextColor(tableView:UITableView) {
        var allCell = tableView.indexPathsForVisibleRows()
        for cell in allCell! {
            let seletedCell:UITableViewCell = tableView.cellForRowAtIndexPath(cell as! NSIndexPath)!
            //cell as UITableViewCell
            seletedCell.textLabel?.textColor = UIColor.blackColor()
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section == 0 {
            if !selectedB {
                insertRowsAtIndexPaths(tableView, indexPath: indexPath)
            }else{
                if indexPath.row == 0 {

                    deleteRowsAtIndexPaths(tableView, indexPath: indexPath)
                }else{
                    //didSelectTableViewCell(tableView, didIndexPath: indexPath)
                    mNotificationType = mNotificationSettingArray[indexPath.row-1].getType()
                    self.performSegueWithIdentifier("EnterNotification", sender: self)
                }
            }
        }else if indexPath.section == 1 {
            NSLog("\(indexPath)")
        }else{
            //didSelectTableViewCell(tableView, didIndexPath: indexPath)

            if selectedB {
                deleteRowsAtIndexPaths(tableView, indexPath: indexPath)
            }

            if indexPath.section == 2{
                //self.performSegueWithIdentifier("Setting_nevoOta", sender: self)
                self.performSegueWithIdentifier("Seting_Mynevo", sender: self)
            }else if indexPath.section == 3{
                findMydevice()
            }
        }
    }

    //vibrate and show all color light to find my device, only send one request in 6 sec
    //this action take lot power and we maybe told customer less to use it
    var mFindMydeviceDatetime:NSDate = NSDate(timeIntervalSinceNow: -6)
    func findMydevice(){
        var minDelay:Double = 6
        var offset:Double = (NSDate().timeIntervalSince1970 - mFindMydeviceDatetime.timeIntervalSince1970)
        NSLog("findMydevice offset:\(offset)")
        if (offset < minDelay) {
            return
        }
        mSyncController?.SetLedOnOffandVibrator(0x3F0000, motorOnOff: true)
        mFindMydeviceDatetime = NSDate()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return sources.count

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if selectedB && section==0 {
            NSLog("count:\(sources.count + mNotificationSettingArray.count)")
            return 1 + mNotificationSettingArray.count
        }
        return 1
        //return mNotificationSettingArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let endCell = notificationList.NotificationSwicthCell(indexPath)
            return endCell
        }

        if indexPath.row == 0 {
            var endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SetingCell", forIndexPath: indexPath) as! UITableViewCell
            endCell.selectedBackgroundView = UIImageView(image: UIImage(named:"selectedButton"))
            endCell.textLabel?.text = sources.objectAtIndex(indexPath.section) as? String
            endCell.layer.borderWidth = 0.5;
            endCell.layer.borderColor = UIColor.grayColor().CGColor;
            return endCell
        }
        let cell:TableListCell = notificationList.NotificationlistCell(indexPath, dataSource: mNotificationSettingArray) as! TableListCell
        cell.mSwitchDelegate = self
        return cell

    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "EnterNotification"){
            var notficp = segue.destinationViewController as! EnterNotificationController
            notficp.mDelegate = self
            
            notficp.mNotificationSettingArray = mNotificationSettingArray
            notficp.mCurrentNotificationSetting = NotificationSetting.indexOfObjectAtType(mNotificationSettingArray, type: mNotificationType)

            for setting in mNotificationSettingArray {


            }
        }

    }

}
