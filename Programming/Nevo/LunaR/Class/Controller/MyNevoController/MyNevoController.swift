//
//  MyNevoController.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner

class MyNevoController: UITableViewController,SyncControllerDelegate,UIAlertViewDelegate {

    private var currentBattery:Int = 0
    private var rssialert :UIAlertView?
    private var buildinSoftwareVersion:Int = 0
    private var buildinFirmwareVersion:Int = 0

    var titleArray:[String] = []

    init() {
        super.init(nibName: "MyNevoController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("My LunaR", comment: "")
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        buildinSoftwareVersion = AppTheme.GET_SOFTWARE_VERSION()
        buildinFirmwareVersion = AppTheme.GET_FIRMWARE_VERSION()

        titleArray = [NSLocalizedString("watch_version", comment: ""),NSLocalizedString("battery", comment: ""),NSLocalizedString("app_version", comment: "")]
        tableView.backgroundColor = UIColor.getGreyColor()
        
        let footLabel:UILabel = UILabel(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,80))
        footLabel.numberOfLines = 0
        footLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        footLabel.textColor = UIColor.whiteColor()
        footLabel.text = "To save battery power, Bluetooth disconnects automatically when away from the phone for more than 2 minutes. You will not receive notifications on LunaR when disconnected."
        tableView.tableFooterView = footLabel
    }
    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        if AppDelegate.getAppDelegate().isConnected() {
            AppDelegate.getAppDelegate().ReadBatteryLevel()
        }
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

    }
    
    override func viewDidDisappear(animated: Bool) {
        AppDelegate.getAppDelegate().removeMyNevoDelegate()
        rssialert?.dismissWithClickedButtonIndex(1, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SyncControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber){
        AppTheme.DLog("Red RSSI Value:\(number)")
        if(number.integerValue < -85){
            if(rssialert==nil){
                rssialert = UIAlertView(title: NSLocalizedString("Unstable connection ensure", comment: ""), message:NSLocalizedString("Unstable connection ensure nevo is on and in range", comment: "") , delegate: nil, cancelButtonTitle: nil)
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
            let indexPath:NSIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

    func connectionStateChanged(isConnected : Bool){
        if(isConnected){
            AppDelegate.getAppDelegate().ReadBatteryLevel()
        }else{
            rssialert?.dismissWithClickedButtonIndex(1, animated: true)
            rssialert = nil
        }
    }

    func syncFinished(){

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
            headerimage.frame = CGRectMake(headerimage.frame.origin.x, headerimage.frame.origin.y+30, headerimage.frame.size.width, headerimage.frame.size.height)
            return headerimage.frame.size.height+50
        }
        return 0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.row == 0){
            if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue >= buildinSoftwareVersion && AppDelegate.getAppDelegate().getFirmwareVersion().integerValue >= buildinFirmwareVersion){
                let banner = Banner(title: NSLocalizedString("is_watch_version", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
                return
            }
            if(buildinSoftwareVersion==0&&buildinFirmwareVersion==0){return}
            let otaCont:NevoOtaViewController = NevoOtaViewController()
            let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
            self.presentViewController(navigation, animated: true, completion: nil)
        }

    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView{
        let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
        let view:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, headerimage.frame.size.height))
        view.addSubview(headerimage)
        headerimage.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0+30)
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
        var detailString:String = ""
        switch (indexPath.row){
        case 0:
           detailString = "MCU:\(AppDelegate.getAppDelegate().getSoftwareVersion()) BLE:\(AppDelegate.getAppDelegate().getFirmwareVersion())"
           //buildinSoftwareVersion:Int = 0 buildinFirmwareVersion:Int = 0
        case 1:
            switch (currentBattery){
            case 0:
                detailString = NSLocalizedString("battery_low", comment: "")
            case 1:
                detailString = NSLocalizedString("battery_sufficient", comment: "")
            case 2:
                detailString = NSLocalizedString("battery_full", comment: "")
            default: detailString = NSLocalizedString("", comment: "")
            }
        case 2:
            let loclString:String = (NSBundle.mainBundle().infoDictionary! as NSDictionary).objectForKey("CFBundleShortVersionString") as! String
            detailString = loclString
        default: detailString = NSLocalizedString("", comment: "")
        }
        return MyNevoView.getMyNevoViewTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row], detailText: detailString)
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
