//
//  EnterNotificationController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
/**
*  callBack choose notification protocol
*/
protocol SelectionTypeDelegate {

    /**
    Implementation method
    :param: results Switch state
    :param: type    type
    */
    func onSelectedType(results:Bool,type:NSString)

}

class EnterNotificationController: UIViewController,SwitchActionDelegate,PaletteDelegate,SyncControllerDelegate,ButtonManagerCallBack{

    class func setLedColor(sourceType: NSString,ledColor:UInt32)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        var value:UInt32 = getMotorOnOff(sourceType) ? (ledColor | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
            : (ledColor & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
        
        userDefaults.setObject(UInt(value),forKey:sourceType)
        userDefaults.synchronize()
        
    }
    class  func getLedColor(sourceType: NSString) ->UInt32
    {
        if let color = NSUserDefaults.standardUserDefaults().objectForKey(sourceType) as? UInt
        {
            return UInt32(color) & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        } else {
            // default value
            var ledColor:UInt32
            switch sourceType {
                case NotificationType.CALL.rawValue :
                ledColor = SetNortificationRequest.SetNortificationRequestValues.ORANGE_LED
            case NotificationType.SMS.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.GREEN_LED
            case NotificationType.EMAIL.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED
            case NotificationType.FACEBOOK.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.BLUE_LED
            case NotificationType.CALENDAR.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.RED_LED
            case NotificationType.WECHAT.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.LIGHTGREEN_LED
            default:
                ledColor = 0xFF0000
            }
            
            return ledColor
        }
    }
    
    class func setMotorOnOff(sourceType: NSString,motorStatus:Bool)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        var ledColor = getLedColor(sourceType)
        
        ledColor = motorStatus ? (ledColor | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
            : (ledColor & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
        userDefaults.setObject(UInt(ledColor),forKey:sourceType)
        userDefaults.synchronize()
    }
    
    class func getMotorOnOff(sourceType: NSString) ->Bool
    {
        if let color = NSUserDefaults.standardUserDefaults().objectForKey(sourceType) as? UInt
        {
            return ((UInt32(color) & SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR) == SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR) ? true : false
        }
        
        return false
    }

    @IBOutlet var enterNotView: EnterNotificationView!
    
    //From the higher level of the incoming type Array
    var mNotificationSettingArray:[NotificationSetting] = []
    
    var mCurrentNotificationSetting:NotificationSetting?

    /*
    Type switch state callBack to the before a object
    */
    var mDelegate:SelectionTypeDelegate?

    private var mSyncController:SyncController?
    
    /*
    led color default is full color led light on
    */
    //var ledcolor: UInt32 = 0xFF0000
    var PaletteSele:Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        enterNotView.bulidEnterNotificationView(self)

    }

    override func viewDidAppear(animated: Bool) {
        //checkConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if sender.isEqual(enterNotView.animationView?.getNoConnectScanButton()?) {
            NSLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(enterNotView.backButton) {
            self.navigationController?.popViewControllerAnimated(true)
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
        //checkConnection()
    }

    /**
    Checks if any device is currently connected
    */
    func checkConnection() {

        if mSyncController != nil && !(mSyncController!.isConnected()) {
            //We are currently not connected
            var isView:Bool = false
            for view in enterNotView.subviews {
                let anView:UIView = view as UIView
                if anView.isEqual(enterNotView.animationView?.bulibNoConnectView()) {
                    isView = true
                }
            }
            if !isView {
                enterNotView.addSubview(enterNotView.animationView!.bulibNoConnectView())
                reconnect()
            }
        } else {
            enterNotView.animationView!.endConnectRemoveView()
        }
        self.view.bringSubviewToFront(enterNotView.titleBgView)
    }

    func reconnect() {
        enterNotView.animationView?.RotatingAnimationObject((enterNotView.animationView?.getNoConnectImage())!)
        mSyncController?.connect()
    }



    /**
    set the color of current notification setting
    */
    func setCurrentNotificationSettingColor(color:UInt32, isSaveLocal:Bool = true){
        if let typeName = mCurrentNotificationSetting?.typeName {
            EnterNotificationController.setLedColor(typeName,ledColor:color)
        }
    }
    
    // MARK: - SwitchActionDelegate
    func onSwitch(results:Bool ,sender:UISwitch){
        if let currentSettings = mCurrentNotificationSetting {
            //save in local
            EnterNotificationController.setMotorOnOff(currentSettings.typeName, motorStatus: results)
            //update the currentSetting
            currentSettings.setStates(results)
            SetingViewController.refreshNotificationSettingArray(&mNotificationSettingArray)
            //send request to watch
            mSyncController?.SetNortification(mNotificationSettingArray)
            //refresh ui
            mDelegate?.onSelectedType(results, type: currentSettings.typeName)
        }
        
    }

    // MARK: - PaletteDelegate
    func selectedPalette(color:UIColor){
        NSLog("UIColor\(color)")
         let indexPathRow:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let cellForRow:NotificationTypeCell = enterNotView.NotificationTableView.cellForRowAtIndexPath(indexPathRow) as NotificationTypeCell
        cellForRow.typeTitle.backgroundColor = color
        var currentColor:UInt32
        switch color {
        case AppTheme.NEVO_CUSTOM_COLOR(Red: 44, Green: 166, Blue: 224):
            currentColor = SetNortificationRequest.SetNortificationRequestValues.BLUE_LED
        case AppTheme.NEVO_CUSTOM_COLOR(Red: 229, Green: 0, Blue: 18):
            currentColor = SetNortificationRequest.SetNortificationRequestValues.RED_LED
        case AppTheme.NEVO_CUSTOM_COLOR(Red: 250, Green: 237, Blue: 0):
            currentColor = SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED
        case AppTheme.NEVO_CUSTOM_COLOR(Red: 141, Green: 194, Blue: 31):
            currentColor = SetNortificationRequest.SetNortificationRequestValues.GREEN_LED
        case AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 150, Blue: 0):
            currentColor = SetNortificationRequest.SetNortificationRequestValues.ORANGE_LED
        case AppTheme.NEVO_CUSTOM_COLOR(Red: 13, Green: 172, Blue: 103):
            currentColor = SetNortificationRequest.SetNortificationRequestValues.LIGHTGREEN_LED
        default:
            currentColor = 0
        }
        if currentColor != 0 {
            setCurrentNotificationSettingColor(currentColor)
        }
        //refresh the settingArray value
        SetingViewController.refreshNotificationSettingArray(&mNotificationSettingArray)
        //send request to watch
        mSyncController?.SetNortification(mNotificationSettingArray)
        //reload data
        if let currentSetting = mCurrentNotificationSetting {
            mDelegate?.onSelectedType(true, type: currentSetting.typeName)
        }
        
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 65.0
        }else{
            return 245
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if (section == 0){
            return 0.0
        }else{
            return 100
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (section == 0) {
            return 1
        }else if (section == 1) {
            return 1
        }else{
            return 0
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            var endCell:NotificationTypeCell = tableView.dequeueReusableCellWithIdentifier("NotificationTypeCell", forIndexPath: indexPath) as NotificationTypeCell
            endCell.selectionStyle = UITableViewCellSelectionStyle.None
            endCell.textLabel?.backgroundColor = UIColor.clearColor()

            if let currentSetting = mCurrentNotificationSetting {
                endCell.typeTitle.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 28)
                endCell.typeTitle.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
                endCell.typeTitle.textColor = UIColor.whiteColor()
                endCell.typeTitle.text = NSLocalizedString(currentSetting.typeName, comment: "")

                if let currentSetting = mCurrentNotificationSetting {
                    var currentColor:UInt32 = currentSetting.getColor().unsignedIntValue
                    if (currentColor == SetNortificationRequest.SetNortificationRequestValues.RED_LED){
                        endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 229, Green: 0, Blue: 18)
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.BLUE_LED){
                        endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 44, Green: 166, Blue: 224)
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.GREEN_LED){
                        endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 141, Green: 194, Blue: 31)
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED){
                        endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 250, Green: 237, Blue: 0)
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.ORANGE_LED){
                        endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 150, Blue: 0)
                    }
                    else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.LIGHTGREEN_LED){
                        endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 13, Green: 172, Blue: 103)
                    }

                }
            }
            endCell.ActionDelegate = self

            return endCell
        }else if (indexPath.section == 1){
            let paletteCell:PaletteViewCell = enterNotView.EnterPaletteListCell(indexPath, dataSource: NSArray())
            paletteCell.pDelegate = self
            return paletteCell
        }

        return UITableViewCell()

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
