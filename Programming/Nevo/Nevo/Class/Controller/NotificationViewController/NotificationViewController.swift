//
//  NotificationViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import XCGLogger

class NotificationViewController: UITableViewController,SelectedNotificationDelegate {
    fileprivate var nevoNotiOFFArray:[NotificationSetting] = []
    fileprivate var nevoNotiONArray:[NotificationSetting] = []
    fileprivate var lunarNotiOFFArray:[NotificationSetting] = []
    fileprivate var lunarNotiONArray:[NotificationSetting] = []
    
    fileprivate var mNotificationOFFArray:[NotificationSetting] {
        if AppTheme.isTargetLunaR_OR_Nevo() {
            return nevoNotiOFFArray
        } else {
            return lunarNotiOFFArray
        }
    }
    fileprivate var mNotificationONArray:[NotificationSetting] {
        if AppTheme.isTargetLunaR_OR_Nevo() {
            return nevoNotiONArray
        } else {
            return lunarNotiONArray
        }
    }
    
    fileprivate let titleHeader:[String] = ["ACTIVE_NOTIFICATIONS","INACTIVE_NOTIFICATIONS"]
    fileprivate var mNotificationArray:NSArray = NSArray()

    var hasNotiOFF:Bool {
        return self.mNotificationOFFArray.count != 0
    }
    var hasNotiON:Bool {
        return self.mNotificationONArray.count != 0
    }
    
    @IBOutlet weak var notificationView: NotificationView!

    init() {
        super.init(nibName: "NotificationViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationSettingArray()
        notificationView.bulidNotificationView(self.navigationItem)
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.view.backgroundColor = UIColor.getLightBaseColor()
            self.tableView.backgroundColor = UIColor.getLightBaseColor()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNotificationSettingArray()
        
        let indexSet:NSIndexSet = NSIndexSet(indexesIn: NSMakeRange(0, 1))
        tableView.reloadSections(indexSet as IndexSet, with: .automatic)
        tableView.reloadData()
    }

    func initNotificationSettingArray() {
        nevoNotiONArray.removeAll()
        nevoNotiOFFArray.removeAll()
        
        /// Todo: When lunar's new notification module is completed, we can rewrite here.
        lunarNotiONArray.removeAll()
        lunarNotiOFFArray.removeAll()

        mNotificationArray = UserNotification.getAll()
        
        let notificationTypeArray:[NotificationType] = [
            NotificationType.call,
            NotificationType.email,
            NotificationType.facebook,
            NotificationType.sms,
            NotificationType.wechat,
            NotificationType.calendar]
        
        for notificationType in notificationTypeArray {
            for model in mNotificationArray{
                let notification:UserNotification = model as! UserNotification
                if(notification.NotificationType == notificationType.rawValue as String){
                    let setting:NotificationSetting = NotificationSetting(type: notificationType, clock: notification.clock, color: 0, states:notification.status)
                    
                    /// Todo: When lunar's new notification module is completed, we can rewrite here.
                    if(notification.status) {
                        nevoNotiONArray.append(setting)
                        lunarNotiONArray.append(setting)
                    }else {
                        nevoNotiOFFArray.append(setting)
                        lunarNotiOFFArray.append(setting)
                    }
                    break
                }
            }
        }
    }
}

// MARK: - SelectedNotificationDelegate
extension NotificationViewController {
    func didSelectedNotificationDelegate(_ clockIndex:Int,ntSwitchState:Bool,notificationType:String){
        XCGLogger.default.debug("clockIndex····:\(clockIndex),ntSwitchState·····:\(ntSwitchState)")
        for model in mNotificationArray {
            let notModel:UserNotification = model as! UserNotification
            if(notModel.NotificationType == notificationType){
                let notification:UserNotification = UserNotification(keyDict: ["id":notModel.id, "clock":clockIndex, "NotificationType":notificationType,"status":ntSwitchState])
                if(notification.update()){
                    initNotificationSettingArray()
                    self.tableView.reloadData()
                    let allArray:[NotificationSetting] = mNotificationOFFArray + mNotificationONArray
                    if(AppDelegate.getAppDelegate().isConnected()){
                        AppDelegate.getAppDelegate().SetNortification(allArray)
                        let banner = MEDBanner(title: NSLocalizedString("sync_notifications", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 2.0)
                    }else{
                        let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 2.0)
                    }
                }
                break
            }
        }
    }
}

// MARK: TableView Datasource
extension NotificationViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 45.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        if hasNotiON && hasNotiOFF {
            return NSLocalizedString(titleHeader[section], comment: "")
        } else {
            return hasNotiON ? NSLocalizedString(titleHeader[0], comment: "") : NSLocalizedString(titleHeader[1], comment: "")
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !hasNotiON && !hasNotiOFF {
            return 0
        } else {
            return hasNotiON && hasNotiOFF ? 2 : 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasNotiON && hasNotiOFF {
            return section == 0 ? mNotificationONArray.count : mNotificationOFFArray.count
        }
        
        return hasNotiON ? mNotificationONArray.count : mNotificationOFFArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var noti:NotificationSetting? = nil
        if hasNotiON && hasNotiOFF {
            noti = indexPath.section == 0 ? mNotificationONArray[indexPath.row] : mNotificationOFFArray[indexPath.row]
        } else {
            noti = hasNotiON ? mNotificationONArray[indexPath.row] : mNotificationOFFArray[indexPath.row]
        }
        
        if let noti = noti {
            var detailString:String = ""
            noti.getStates() ? (detailString = noti.getColorName()) : (detailString = NSLocalizedString("turned_off", comment: ""))
            return NotificationView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: noti.typeName, detailLabel:detailString)
        }
        
        return UITableViewCell()
    }
}


// MARK: - TableView Delegate
extension NotificationViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        var titleString:String = ""
        var clockIndex:Int = 0
        var state:Bool = false
        
        var noti:NotificationSetting?
        if hasNotiON && hasNotiOFF {
            noti = indexPath.section == 0 ? mNotificationONArray[indexPath.row] : mNotificationOFFArray[indexPath.row]
        } else {
            noti = hasNotiON ? mNotificationONArray[indexPath.row] : mNotificationOFFArray[indexPath.row]
        }
        
        if let noti = noti {
            titleString = noti.typeName
            clockIndex = noti.getClock()
            state = noti.getStates()
        }
        
        let selectedNot:SelectedNotificationTypeController = SelectedNotificationTypeController()
        selectedNot.titleString = titleString
        selectedNot.clockIndex = clockIndex
        selectedNot.swicthStates = state
        selectedNot.selectedDelegate = self
        self.navigationController?.pushViewController(selectedNot, animated: true)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headView = view as! UITableViewHeaderFooterView
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            headView.textLabel?.textColor = UIColor.white
        }
    }
}
