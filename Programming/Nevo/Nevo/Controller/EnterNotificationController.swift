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

class EnterNotificationController: UIViewController,SyncControllerDelegate,ButtonManagerCallBack{

    class func setLedColor(sourceType: NSString,ledColor:UInt32)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        var value:UInt32 = getMotorOnOff(sourceType) ? (ledColor | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
            : (ledColor & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
        
        userDefaults.setObject(UInt(value),forKey:sourceType as String)
        userDefaults.synchronize()
        
    }
    class  func getLedColor(sourceType: NSString) ->UInt32
    {
        if let color = NSUserDefaults.standardUserDefaults().objectForKey(sourceType as String) as? UInt
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
        userDefaults.setObject(UInt(ledColor),forKey:sourceType as String)
        userDefaults.synchronize()
    }
    
    class func getMotorOnOff(sourceType: NSString) ->Bool
    {
        if let color = NSUserDefaults.standardUserDefaults().objectForKey(sourceType as String) as? UInt
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

        enterNotView.bulidEnterNotificationView(self,seting:mCurrentNotificationSetting!)

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
        if sender.isEqual(enterNotView.animationView?.getNoConnectScanButton()) {
            AppTheme.DLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(enterNotView.backButton) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if(sender.isEqual(enterNotView.yellowButton) || sender.isEqual(enterNotView.redButton) || sender.isEqual(enterNotView.greenButton) || sender.isEqual(enterNotView.orangeButton) || sender.isEqual(enterNotView.peakgreenButton) || sender.isEqual(enterNotView.blueButton)){

            for button in [enterNotView.yellowButton,enterNotView.redButton,enterNotView.greenButton,enterNotView.orangeButton,enterNotView.peakgreenButton,enterNotView.blueButton]{
                if sender.isEqual(button) {
                    button.selected = true
                }else{
                    button.selected = false
                }
            }
            var currentColor:UInt32
            switch sender as! UIButton {
            case enterNotView.blueButton:
                currentColor = SetNortificationRequest.SetNortificationRequestValues.BLUE_LED
            case enterNotView.redButton:
                currentColor = SetNortificationRequest.SetNortificationRequestValues.RED_LED
            case enterNotView.yellowButton:
                currentColor = SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED
            case enterNotView.greenButton:
                currentColor = SetNortificationRequest.SetNortificationRequestValues.GREEN_LED
            case enterNotView.orangeButton:
                currentColor = SetNortificationRequest.SetNortificationRequestValues.ORANGE_LED
            case enterNotView.peakgreenButton:
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
            for view in enterNotView.subviews {
                let anView:UIView = view as! UIView
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
