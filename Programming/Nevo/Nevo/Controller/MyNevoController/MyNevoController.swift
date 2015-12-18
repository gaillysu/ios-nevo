//
//  MyNevoController.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoController: UITableViewController,ButtonManagerCallBack,SyncControllerDelegate {

    @IBOutlet var mynevoView: MyNevoView!
    private var currentBattery:Int = 0
    private var rssialert :UIAlertView?
    private var buildinSoftwareVersion:Int = 0
    private var buildinFirmwareVersion:Int = 0

    var titleArray:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        mynevoView.bulidMyNevoView(self,navigation: self.navigationItem)
        buildinSoftwareVersion = GET_SOFTWARE_VERSION()
        buildinFirmwareVersion = GET_FIRMWARE_VERSION()

        titleArray = ["Firmware","Battery","Watch version"]
    }

    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        //AppDelegate.getAppDelegate().ReadBatteryLevel()
        //mynevoView.setVersionLbael(AppDelegate.getAppDelegate().getSoftwareVersion(), bleNumber: AppDelegate.getAppDelegate().getFirmwareVersion())
    }
    
    override func viewDidDisappear(animated: Bool) {
        AppDelegate.getAppDelegate().removeMyNevoDelegate()
        rssialert?.dismissWithClickedButtonIndex(1, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - controllManager
    func controllManager(sender:AnyObject){

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

        let currentSoftwareVersion:NSString = AppDelegate.getAppDelegate().getSoftwareVersion()
        let currentFirmwareVersion:NSString = AppDelegate.getAppDelegate().getFirmwareVersion()

    }


    func packetReceived(packet:NevoPacket){
        let thispacket:BatteryLevelNevoPacket = packet.copy() as BatteryLevelNevoPacket
        if(thispacket.isReadBatteryCommand(packet.getPackets())){
            let batteryValue:Int = thispacket.getBatteryLevel()
            currentBattery = batteryValue
        }
    }

    func connectionStateChanged(isConnected : Bool){
        checkConnection()
        if(isConnected){
            AppDelegate.getAppDelegate().ReadBatteryLevel()
        }else{
            rssialert?.dismissWithClickedButtonIndex(1, animated: true)
            rssialert = nil
        }
    }

    func syncFinished(){

    }

    /**
    Checks if any device is currently connected
    */
    func checkConnection() {
        if !AppDelegate.getAppDelegate().isConnected() {
            AppDelegate.getAppDelegate().ReadBatteryLevel()
        }
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if(section == 0){
            let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
            return headerimage.frame.size.height
        }
        return 0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(indexPath.row == 1){
            let otaCont:NevoOtaViewController = NevoOtaViewController()
            otaCont.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(otaCont, animated: true)
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView{
        let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
        let view:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, headerimage.frame.size.height))
        view.addSubview(headerimage)
        headerimage.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        return view
    }

    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return titleArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return mynevoView.getMyNevoViewTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row])
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
