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
import XCGLogger

class MyNevoController: UITableViewController,UIAlertViewDelegate {
    
    fileprivate var currentBattery:Int = -1
    fileprivate var rssialert :UIAlertView?
    
    let watchInfoArray:[String] = [NSLocalizedString("watch_version", comment: ""),NSLocalizedString("Battery", comment: ""),NSLocalizedString("app_version", comment: "")]
    
    let forgetWatchArray:[String] = [NSLocalizedString("forget_watch", comment: "")]
    
    
    init() {
        super.init(nibName: "MyNevoController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("My nevo", comment: "")
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_RSSI_VALUE) { (notification) in
            let number:NSNumber = notification.object as! NSNumber
            XCGLogger.default.debug("Red RSSI Value:\(number)")
            if(number.intValue < -95){
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
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_BATTERY_STATUS_CHANGED) { (notification) in
            let batteryValue = notification.object as! Int;
            self.currentBattery = batteryValue
            let indexPath:NSIndexPath = NSIndexPath(row: 1, section: 0)
            self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            let connected = notification.object as! PostConnectionState
            if let connectedState = connected.isConnected {
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
    
    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 {
            let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
            return headerimage.frame.size.height + 70
        }
        return 0
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
            
            if indexPath.row == 0 {
                if(UserDefaults.standard.getSoftwareVersion() >= buildin_software_version && UserDefaults.standard.getFirmwareVersion() >= buildin_firmware_version){
                    let banner = MEDBanner(title: NSLocalizedString("is_watch_version", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.5)
                    return
                } else if(AppDelegate.getAppDelegate().isConnected()){
                    if !AppDelegate.getAppDelegate().isSyncState() || UserDefaults.standard.getSoftwareVersion() == 0 {
                        let otaCont:NevoOtaViewController = NevoOtaViewController()
                        let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                        self.present(navigation, animated: true, completion: nil)
                    }else{
                        let banner = MEDBanner(title: "In sync data, sync is completed in OTA, please", subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.5)
                    }
                }else{
                    let banner = MEDBanner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.5)
                }
                
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let actionSheet:MEDAlertController = MEDAlertController(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_your_nevo", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction:AlertAction = AlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            cancelAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
            actionSheet.addAction(cancelAction)
            
            let forgetAction:AlertAction = AlertAction(title: NSLocalizedString("forget", comment: ""), style: UIAlertActionStyle.default, handler: { ( alert) -> Void in
                AppDelegate.getAppDelegate().disconnect()
                AppDelegate.getAppDelegate().forgetSavedAddress()
                
                AppDelegate.getAppDelegate().setWatchInfo(-1, model: -1)
                let tutrorial:TutorialOneViewController = TutorialOneViewController()
                let nav:UINavigationController = UINavigationController(rootViewController: tutrorial)
                nav.isNavigationBarHidden = true
                
                self.present(nav, animated: true, completion: {
                    UIApplication.shared.keyWindow?.rootViewController = nav
                })
            })
            forgetAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
            actionSheet.addAction(forgetAction)
            self.present(actionSheet, animated: true, completion: nil)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView{
        if section == 0     {
            let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
            let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: headerimage.frame.size.height + 70))
            view.addSubview(headerimage)
            headerimage.center = CGPoint(x: view.frame.size.width/2.0, y: view.frame.size.height/2.0)
            return view
        }
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height:0 ))
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 2
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch section {
        case 0:
            return watchInfoArray.count
        case 1:
            return forgetWatchArray.count
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var detailString:String = ""
        var isUpdate:Bool = false
        if indexPath.section  == 0 {
            
            
            switch (indexPath.row){
            case 0:
                let currentSoftwareVersion = UserDefaults.standard.getSoftwareVersion()
                let currentFirmwareVersion = UserDefaults.standard.getFirmwareVersion()
                var softwareFlag = currentSoftwareVersion < buildin_software_version
                let firmwareFlag = currentFirmwareVersion < buildin_firmware_version
                if(softwareFlag && firmwareFlag){
                    detailString = "\(NSLocalizedString("update_available", comment: "")), \(currentFirmwareVersion)/\(currentSoftwareVersion)"
                    
                    detailString = detailString.replacingOccurrences(of: "VERSION_NUMBER", with: "\(buildin_firmware_version.to2String())/\(buildin_software_version.to2String())")
                    
                    debugLog("MCU:\(UserDefaults.standard.getSoftwareVersion()) BLE:\(UserDefaults.standard.getFirmwareVersion())")
                    
                    isUpdate = true
                } else {
                    detailString = "MCU:\(UserDefaults.standard.getSoftwareVersion()) BLE:\(UserDefaults.standard.getFirmwareVersion())"
                }
            case 1:
                switch (currentBattery){
                case -1:
                    detailString = "Unavailable"
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
            return MyNevoView.getMyNevoViewTableViewCell(indexPath, tableView: tableView, title: watchInfoArray[indexPath.row], detailText: detailString,isUpdate:isUpdate)
        } else if indexPath.section == 1 {
            let cell = MyNevoView.getMyNevoViewTableViewCell(indexPath, tableView: tableView, title: forgetWatchArray[indexPath.row], detailText: "",isUpdate:isUpdate)
            cell.textLabel?.textColor = UIColor.darkRed()
            return cell
        }
        return MyNevoView.getMyNevoViewTableViewCell(indexPath, tableView: tableView, title: watchInfoArray[0], detailText: "",isUpdate:isUpdate)
    }
}
