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
            self.performSegueWithIdentifier("Setting_nevoOta", sender: self)
        }

    }

    // MARK: - SyncControllerDelegate
    func packetReceived(packet:NevoPacket){

        var thispacket = packet.copy() as BatteryLevelNevoPacket
        var batteryValue:Int = thispacket.getBatteryLevel()
        mynevoView.setBatteryLevelValue(batteryValue)

        mynevoView.setVersionLbael(mSyncController!.getSoftwareVersion(), bleNumber: mSyncController!.getFirmwareVersion())
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
                let anView:UIView = view as! UIView
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
