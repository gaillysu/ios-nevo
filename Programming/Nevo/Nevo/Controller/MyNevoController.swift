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

    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        mynevoView.bulidMyNevoView(self)

    }

    
    override func viewDidAppear(animated: Bool) {
        mSyncController?.ReadBatteryLevel()
        mynevoView.setVersionLbael(mSyncController!.getSoftwareVersion(), bleNumber: mSyncController!.getFirmwareVersion())
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
            if (currentBattery<1){
                let alert :UIAlertView = UIAlertView(title: "Battery warnings", message: "Your watch battery not enough, please change a new battery can be OTA", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                return;
            }
            self.performSegueWithIdentifier("Setting_nevoOta", sender: self)
        }

    }

    // MARK: - SyncControllerDelegate
    func packetReceived(packet:NevoPacket){
        let thispacket:BatteryLevelNevoPacket = packet.copy() as BatteryLevelNevoPacket
        if(thispacket.isReadBatteryCommand(packet.getPackets())){
            let batteryValue:Int = thispacket.getBatteryLevel()
            currentBattery = batteryValue
            mynevoView.setBatteryLevelValue(batteryValue)

            mynevoView.setVersionLbael(mSyncController!.getSoftwareVersion(), bleNumber: mSyncController!.getFirmwareVersion())
        }
    }

    func connectionStateChanged(isConnected : Bool){

        checkConnection()
        
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
