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

class EnterNotificationController: UITableViewController,SwitchActionDelegate,PaletteDelegate,SyncControllerDelegate,ButtonManagerCallBack{

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
                ledColor = SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED
            case NotificationType.SMS.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.GREEN_LED
            case NotificationType.EMAIL.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED
            case NotificationType.FACEBOOK.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.BLUE_LED
            case NotificationType.CALENDAR.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.RED_LED
            case NotificationType.WECHAT.rawValue:
                ledColor = SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED
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

    var numberCount:Int = 1
    var PaletteSele:Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        enterNotView.bulidEnterNotificationView(self,navigationItem:self.navigationItem)

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
        checkConnection()
    }

    /**
    Checks if any device is currently connected
    */
    func checkConnection() {
        if mSyncController != nil && !(mSyncController!.isConnected()) {
            //We are currently not connected
            enterNotView.addSubview((enterNotView.animationView?.bulibNoConnectView())!)
            reconnect()
        } else {
            enterNotView.animationView?.endConnectRemoveView()
        }
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
    func onSwitch(results:Bool){
        if let currentSettings = mCurrentNotificationSetting {
            //save in local
            EnterNotificationController.setMotorOnOff(currentSettings.typeName, motorStatus: results)
            //update the currentSetting
            currentSettings.setStates(results)
            NotificationController.refreshNotificationSettingArray(&mNotificationSettingArray)
            //send request to watch
            mSyncController?.SetNortification(mNotificationSettingArray)
            //refresh ui
            mDelegate?.onSelectedType(results, type: currentSettings.typeName)
        }
        
    }

    // MARK: - PaletteDelegate
    func selectedPalette(color:UIColor){
        NSLog("UIColor\(color)")
        let indexPathRow:NSIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        let cellForRow:CurrentPaletteCell = self.tableView.cellForRowAtIndexPath(indexPathRow) as CurrentPaletteCell
        cellForRow.currentColorView.backgroundColor = color

        var currentColor:UInt32
        switch color {
        case UIColor.blueColor():
            currentColor = SetNortificationRequest.SetNortificationRequestValues.BLUE_LED
        case UIColor.redColor():
            currentColor = SetNortificationRequest.SetNortificationRequestValues.RED_LED
        case UIColor.yellowColor():
            currentColor = SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED
        case UIColor.greenColor():
            currentColor = SetNortificationRequest.SetNortificationRequestValues.GREEN_LED
        case UIColor.orangeColor():
            currentColor = SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED
        case AppTheme.PALETTE_BAGGROUND_COLOR():
            currentColor = SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED
        default:
            currentColor = 0
        }
        if currentColor != 0 {
            setCurrentNotificationSettingColor(currentColor)
        }
        //refresh the settingArray value
        NotificationController.refreshNotificationSettingArray(&mNotificationSettingArray)
        //send request to watch
        mSyncController?.SetNortification(mNotificationSettingArray)
        //reload data
        if let currentSetting = mCurrentNotificationSetting {
            mDelegate?.onSelectedType(true, type: currentSetting.typeName)
        }
        
    }

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 50.0
        }else{
            if indexPath.row == 0 {
                return 45
            }else {
                return 245
            }
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if (section == 0){
            return 44.0
        }else{
            return 100
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if (indexPath.section == 1){
            if !PaletteSele {
                numberCount+=1
                PaletteSele = true
                let indexPathRow:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
                tableView.insertRowsAtIndexPaths([indexPathRow], withRowAnimation: UITableViewRowAnimation.Bottom)
            }else {
                numberCount-=1
                PaletteSele = false
                let indexPathRow:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
                tableView.deleteRowsAtIndexPaths([indexPathRow], withRowAnimation: UITableViewRowAnimation.Bottom)
            }
        }
    }

    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (section == 0) {
            return 1
        }else if (section == 1) {
            return numberCount
        }else{
            return 0
        }

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            var endCell:NotificationTypeCell = tableView.dequeueReusableCellWithIdentifier("NotificationTypeCell", forIndexPath: indexPath) as NotificationTypeCell
            endCell.selectionStyle = UITableViewCellSelectionStyle.None
            endCell.textLabel?.backgroundColor = UIColor.clearColor()
            if let currentSetting = mCurrentNotificationSetting {
                endCell.cellSwitch.on = currentSetting.getStates()
                endCell.textLabel?.text = NSLocalizedString(currentSetting.typeName, comment: "")
                endCell.imageView?.image = UIImage(named: NotificationView.getNotificationSettingIcon(currentSetting))
            }
            
            //AppTheme.GET_RESOURCES_IMAGE(notType!.getNotificationTypeContent().objectForKey("icon") as String)
            endCell.ActionDelegate = self

            return endCell
        }else if (indexPath.section == 1){

            if (indexPath.row == 0) {
                let endCell:CurrentPaletteCell = enterNotView.EnterCurrentPaletteCell(indexPath)
                if let currentSetting = mCurrentNotificationSetting {
                    var currentColor:UInt32 = currentSetting.getColor().unsignedIntValue
                    if (currentColor == SetNortificationRequest.SetNortificationRequestValues.RED_LED){
                        endCell.currentColorView.backgroundColor = UIColor.redColor()
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.BLUE_LED){
                        endCell.currentColorView.backgroundColor = UIColor.blueColor()
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.GREEN_LED){
                        endCell.currentColorView.backgroundColor = UIColor.greenColor()
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED){
                        endCell.currentColorView.backgroundColor = UIColor.yellowColor()
                    }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED){
                        endCell.currentColorView.backgroundColor = UIColor.orangeColor()
                    }
                    else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED){
                        endCell.currentColorView.backgroundColor = AppTheme.PALETTE_BAGGROUND_COLOR()
                    }
                    
                }

                //endCell.pDelegate = self
                return endCell
            }else {
                let paletteCell:PaletteViewCell = enterNotView.EnterPaletteListCell(indexPath, dataSource: NSArray())
                paletteCell.pDelegate = self
                return paletteCell
            }

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
