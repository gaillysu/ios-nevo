//
//  MyNevoController.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoController: UIViewController,ButtonManagerCallBack,SyncControllerDelegate {

    @IBOutlet var mynevoView: MyNevoView!
    private var mSyncController:SyncController?
    private var currentBattery:Int = 0
    private var rssialert :UIAlertView?
    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController.sharedInstance

        mynevoView.bulidMyNevoView(self)

    }

    
    override func viewDidAppear(animated: Bool) {
        mSyncController?.startConnect(false, delegate: self)
        mSyncController?.ReadBatteryLevel()
        mynevoView.setVersionLbael(mSyncController!.getSoftwareVersion(), bleNumber: mSyncController!.getFirmwareVersion())
    }
    
    override func viewDidDisappear(animated: Bool) {
        mSyncController?.removeMyNevoDelegate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func controllManager(sender:AnyObject){
        if sender.isEqual(mynevoView.animationView?.getNoConnectScanButton()) {
            AppTheme.DLog("noConnectScanButton")
            reconnect()
        }

        if(sender.isEqual(mynevoView.backButton)){
            self.navigationController?.popViewControllerAnimated(true)
        }

        if(sender.isEqual(mynevoView.UpgradeButton)){
            if (currentBattery<1 && mSyncController!.getSoftwareVersion().integerValue>0){
                let alert :UIAlertView = UIAlertView(title: NSLocalizedString("battery_warnings_title", comment: ""), message: NSLocalizedString("battery_warnings_msg", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                return;
            }

            let device:UIDevice = UIDevice.currentDevice()
            device.batteryMonitoringEnabled = true
            let batterylevel:Float = device.batteryLevel
            if(batterylevel < 0.2){
                let alert :UIAlertView = UIAlertView(title: NSLocalizedString("battery_warnings_title", comment: ""), message: NSLocalizedString("mobile_battery_warnings_msg", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
                return;
            }
            if(!mynevoView.UpgradeButton.selected){
                self.performSegueWithIdentifier("Setting_nevoOta", sender: self)
            }
        }

    }

    // MARK: - SyncControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber){
        AppTheme.DLog("Red RSSI Value:\(number)")
        if(number.integerValue < -85){
            if(rssialert==nil){
                rssialert = UIAlertView(title: NSLocalizedString("Unstable connection ensure", comment: ""), message:NSLocalizedString("Unstable connection ensure phone is on and in range", comment: "") , delegate: nil, cancelButtonTitle: nil)
                rssialert?.show()
            }
        }else{
            rssialert?.dismissWithClickedButtonIndex(1, animated: true)
            rssialert = nil
        }
    }


    func packetReceived(packet:NevoPacket){
        let thispacket:BatteryLevelNevoPacket = packet.copy() as BatteryLevelNevoPacket
        if(thispacket.isReadBatteryCommand(packet.getPackets())){
            let batteryValue:Int = thispacket.getBatteryLevel()
            currentBattery = batteryValue
            mynevoView.setBatteryLevelValue(batteryValue)

            mynevoView.setVersionLbael(mSyncController!.getSoftwareVersion(), bleNumber: mSyncController!.getFirmwareVersion())
            let currentSoftwareVersion:NSString = mSyncController!.getSoftwareVersion()
            let currentFirmwareVersion:NSString = mSyncController!.getFirmwareVersion()
            let buildinSoftwareVersion = GET_SOFTWARE_VERSION()
            let buildinFirmwareVersion = GET_FIRMWARE_VERSION()

            if(currentFirmwareVersion.integerValue >= buildinFirmwareVersion && currentSoftwareVersion.integerValue >= buildinSoftwareVersion){
                mynevoView.UpgradeButton.selected = true
                mynevoView.UpgradeButton.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
            }else{
                mynevoView.UpgradeButton.selected = false
                mynevoView.UpgradeButton.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 22)
            }
        }
    }

    func connectionStateChanged(isConnected : Bool){
        checkConnection()
        if(isConnected){
            mynevoView.setVersionLbael(mSyncController!.getSoftwareVersion(), bleNumber: mSyncController!.getFirmwareVersion())
        }
    }

    func syncFinished(){

    }

    /**
    Checks if any device is currently connected
    */

    func checkConnection() {

        if mSyncController != nil && !(mSyncController!.isConnected()) {

            //We are currently not connected
            var isView:Bool = false
            for view in mynevoView.subviews {
                let anView:UIView = view 
                if anView.isEqual(mynevoView.animationView!.bulibNoConnectView()) {
                    isView = true
                }
            }
            if !isView {
                mynevoView.addSubview(mynevoView.animationView!.bulibNoConnectView())
                reconnect()
            }
        } else {
            mynevoView.animationView!.endConnectRemoveView()
            mSyncController?.ReadBatteryLevel()
        }
        self.view.bringSubviewToFront(mynevoView.titleBgView)

    }

    func reconnect() {
        if let noConnectImage = mynevoView.animationView!.getNoConnectImage() {
            mynevoView.animationView!.RotatingAnimationObject(noConnectImage)
        }
        mSyncController?.connect()
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
