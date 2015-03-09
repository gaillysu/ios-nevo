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

    var noticeTypeArray:NSArray!
    var typeModel:TypeModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        notificationList.bulidNotificationViewUI(self,navigationItem: self.navigationItem)
        typeModel = TypeModel()
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
        if sender.isEqual(notificationList.animationView?.getNoConnectScanButton()?) {
            NSLog("noConnectScanButton")
            reconnect()
        }
    }

    // MARK: - SyncControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func packetReceived(packet:RawPacket) {

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
        typeModel.setNotificationTypeStates(type, states: results)
        notificationList.tableListView.reloadData()
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        return 50.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        noticeTypeArray = typeModel.getNotificationTypeContent()[indexPath.row] as NSArray
        self.performSegueWithIdentifier("EnterNotification", sender: self)
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return typeModel.getNotificationTypeContent().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = notificationList.NotificationlistCell(indexPath, dataSource: typeModel.getNotificationTypeContent())
        return cell
    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "EnterNotification"){
            var notficp = segue.destinationViewController as EnterNotificationController
            notficp.notTypeArray = noticeTypeArray
            notficp.mDelegate = self

        }

    }

}
