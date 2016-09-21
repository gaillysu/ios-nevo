//
//  MyNevoController.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import SwiftEventBus


class MyNevoController: UITableViewController,UIAlertViewDelegate {

    fileprivate var currentBattery:Int = 0
    fileprivate var rssialert :UIAlertView?
    fileprivate var buildinSoftwareVersion:Int = 0
    fileprivate var buildinFirmwareVersion:Int = 0

    var titleArray:[String] = []

    init() {
        super.init(nibName: "MyNevoController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("My nevo", comment: "")
        buildinSoftwareVersion = AppTheme.GET_SOFTWARE_VERSION()
        buildinFirmwareVersion = AppTheme.GET_FIRMWARE_VERSION()

        titleArray = [NSLocalizedString("watch_version", comment: ""),NSLocalizedString("battery", comment: ""),NSLocalizedString("app_version", comment: "")]
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_RSSI_VALUE) { (notification) in
            let number:NSNumber = notification.object as! NSNumber
            XCGLogger.defaultInstance().debug("Red RSSI Value:\(number)")
            if(number.intValue < -85){
                if(self.rssialert==nil){
                    self.rssialert = UIAlertView(title: NSLocalizedString("Unstable connection ensure", comment: ""), message:NSLocalizedString("Unstable connection ensure nevo is on and in range", comment: "") , delegate: nil, cancelButtonTitle: nil)
                    self.rssialert?.show()
                }
            }else{
                self.rssialert?.dismiss(withClickedButtonIndex: 1, animated: true)
                self.rssialert = nil
            }
        }
        
        //RAWPACKET DATA
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_RAWPACKET_DATA_KEY) { (notification) in
            let packet = notification.object as! NevoPacket
            //Do nothing
            let thispacket:BatteryLevelNevoPacket = packet.copy() as BatteryLevelNevoPacket
            if(thispacket.isReadBatteryCommand(packet.getPackets())){
                let batteryValue:Int = thispacket.getBatteryLevel()
                self.currentBattery = batteryValue
                let indexPath:NSIndexPath = NSIndexPath(row: 1, section: 0)
                self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            let isConnected:Bool = notification.object as! Bool
            if(isConnected){
                AppDelegate.getAppDelegate().ReadBatteryLevel()
            }else{
                self.rssialert?.dismiss(withClickedButtonIndex: 1, animated: true)
                self.rssialert = nil
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().startConnect(false)
        if AppDelegate.getAppDelegate().isConnected() {
            AppDelegate.getAppDelegate().ReadBatteryLevel()
        }
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        rssialert?.dismiss(withClickedButtonIndex: 1, animated: true)
        SwiftEventBus.unregister(self, name: EVENT_BUS_RSSI_VALUE)
        SwiftEventBus.unregister(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY)
        SwiftEventBus.unregister(self, name: EVENT_BUS_RAWPACKET_DATA_KEY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if(section == 0){
            let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
            return headerimage.frame.size.height
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if((indexPath as NSIndexPath).row == 0){
            if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue >= buildinSoftwareVersion && AppDelegate.getAppDelegate().getFirmwareVersion().integerValue >= buildinFirmwareVersion){
                let banner = Banner(title: NSLocalizedString("is_watch_version", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
                return
            }
            if(buildinSoftwareVersion==0&&buildinFirmwareVersion==0){return}
            let otaCont:NevoOtaViewController = NevoOtaViewController()
            let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
            self.present(navigation, animated: true, completion: nil)
        }

    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView{
        let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
        let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: headerimage.frame.size.height))
        view.addSubview(headerimage)
        headerimage.center = CGPoint(x: view.frame.size.width/2.0, y: view.frame.size.height/2.0)
        return view
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return titleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var detailString:String = ""
        switch ((indexPath as NSIndexPath).row){
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
            let loclString:String = (Bundle.main.infoDictionary! as NSDictionary).object(forKey: "CFBundleShortVersionString") as! String
            detailString = loclString
        default: detailString = NSLocalizedString("", comment: "")
        }
        return MyNevoView.getMyNevoViewTableViewCell(indexPath, tableView: tableView, title: titleArray[(indexPath as NSIndexPath).row], detailText: detailString)
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
