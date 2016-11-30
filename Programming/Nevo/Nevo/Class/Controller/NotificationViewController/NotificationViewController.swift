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
import RealmSwift

class NotificationViewController: UITableViewController,SelectedNotificationDelegate {
    fileprivate let titleHeader:[String] = ["ACTIVE_NOTIFICATIONS","INACTIVE_NOTIFICATIONS"]
    fileprivate var mNotificationArray:[MEDUserNotification] = []
    fileprivate var allArraySettingArray:[NotificationSetting] = []
    
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
        self.tableView.register(UINib(nibName: "NotificationTypeCell", bundle: nil), forCellReuseIdentifier: "Notification_Identifier")
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(refreshAction(_:)))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func refreshAction(_ sender:UIBarButtonItem) {
        let request:GetTotalNotificationAppReuqest = GetTotalNotificationAppReuqest()
        AppDelegate.getAppDelegate().sendRequest(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNotificationSettingArray()
        
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func initNotificationSettingArray() {
        mNotificationArray = MEDUserNotification.getAll() as! [MEDUserNotification]
        allArraySettingArray.removeAll()
        for model in mNotificationArray{
            let notification:MEDUserNotification = model
            let notificationType:String = notification.notificationType
            var type = NotificationType(rawValue: notificationType as NSString)
            if type == nil {
                type = NotificationType.other
            }
            let setting:NotificationSetting = NotificationSetting(type: type!, clock: notification.clock, color: NSNumber(value:notification.clock), states:notification.isAddWatch,packet:notification.appid ,appName:notification.appName)
            allArraySettingArray.append(setting)
        }
    }
}

// MARK: - Calculate Properties
extension NotificationViewController {
    fileprivate var onNotificaitons: [NotificationSetting] {
        return allArraySettingArray.filter({return $0.getStates() == true})
    }
    fileprivate var hasOnNotifications: Bool { return onNotificaitons.count != 0}
    
    fileprivate var offNotifications: [NotificationSetting] {
        return allArraySettingArray.filter({return $0.getStates() == false})
    }
    fileprivate var hasOffNotifications: Bool { return offNotifications.count != 0}
}

// MARK: - TableView Datasource & Delegate
extension NotificationViewController {
    
    func deleteNotificationsAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("Because it is a basic Notifications can not be deleted", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            return true
        }else{
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment:""), handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        
        // MARK: - APPTHEME ADJUST
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            button1.backgroundColor = UIColor.getBaseColor()
        } else {
            button1.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        return [button1]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            var noti: NotificationSetting?
            if hasOnNotifications && hasOffNotifications {
                noti = indexPath.section == 0 ? onNotificaitons[indexPath.row] : offNotifications[indexPath.row]
            } else {
                noti = hasOnNotifications ? onNotificaitons[indexPath.row] : offNotifications[indexPath.row]
            }
            
            let notfiction = MEDUserNotification.getFilter("key = '\(noti!.getPacket())'")
            if notfiction.count>0 {
                let notValue:MEDUserNotification = notfiction[0] as! MEDUserNotification
                if !notValue.deleteFlag {
                   _ = notValue.remove()
                }else{
                    deleteNotificationsAlertView()
                }
            }
            
            initNotificationSettingArray()
            tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if hasOnNotifications && hasOffNotifications {
            return 2
        } else {
            return !hasOnNotifications && !hasOffNotifications ? 0 : 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        var title: String = ""
        
        if hasOffNotifications && hasOnNotifications {
            title = titleHeader[section]
        } else {
            title = hasOnNotifications ? titleHeader[0] : titleHeader[1]
        }
        
        return NSLocalizedString(title, comment: "")
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headView = view as! UITableViewHeaderFooterView
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            headView.textLabel?.textColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasOffNotifications && hasOnNotifications {
            return section == 0 ? onNotificaitons.count : offNotifications.count
        } else {
            return hasOnNotifications ? onNotificaitons.count : offNotifications.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var noti: NotificationSetting?
        if hasOnNotifications && hasOffNotifications {
            noti = indexPath.section == 0 ? onNotificaitons[indexPath.row] : offNotifications[indexPath.row]
        } else {
            noti = hasOnNotifications ? onNotificaitons[indexPath.row] : offNotifications[indexPath.row]
        }
        
        if let noti = noti {
            var detailString:String = ""
            noti.getStates() ? (detailString = noti.getColorName()) : (detailString = NSLocalizedString("turned_off", comment: ""))
            
            let endCell:NotificationTypeCell = tableView.dequeueReusableCell(withIdentifier: "Notification_Identifier", for: indexPath) as! NotificationTypeCell
            endCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            endCell.setTitleLabel(title: NSLocalizedString(noti.getAppName(), comment: ""))
            endCell.setContentLabel(content: NSLocalizedString(detailString, comment: ""))
            endCell.setTitleImage(imageName: "new_\(noti.typeName.lowercased())")
            
            if endCell.titleImage.image == nil {
                let bundleid:String = noti.getPacket()
                if let rawAppName = NSString.init(string: noti.getPacket()).components(separatedBy: ".").last {
                    endCell.setTitleLabel(title: rawAppName)
                }
                
                let placeholderImage: String = "notiPlaceholder"
                endCell.setTitleImage(imageName: placeholderImage)
                
                MEDAppInfoRequester.requesAppInfoWith(bundleId: noti.getPacket(), resultHandle: { (error, appInfo) in
                    if let info = appInfo {
                        let appName:String = info.trackName
                        let imageurl:String = info.artworkUrl100
                        endCell.setTitleLabel(title: appName)
                        endCell.titleImage.kf.setImage(with: URL(string: info.artworkUrl100), placeholder: UIImage(named: placeholderImage), options: nil, progressBlock: nil, completionHandler: { (image, error, cache, url) in
                            
                            if let newImage = image?.sameSizeWith(image: UIImage(named: "new_call")!) {
                                endCell.titleImage.image = newImage
                            }
                        })
                        
                        endCell.titleImage.kf.setImage(with: URL(string: imageurl), placeholder: UIImage(named:"AppIcon"), options: nil, progressBlock: nil, completionHandler: nil)
                        let notifictionObject = MEDUserNotification.getFilter("key = '\(bundleid)'")
                        if(notifictionObject.count > 0) {
                            let notifictionValue:MEDUserNotification = notifictionObject[0] as! MEDUserNotification
                            let realm = try! Realm()
                            try! realm.write {
                                notifictionValue.appName = appName
                            }
                        }
                    } else {
                        let banner = MEDBanner(title: "There seems to be something wrong with your network! so we cannot get the exact names and icons for some apps, please retry later!", subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.5)
                        
                        print("\(error)")
                    }
                })
            }
            
            endCell.setSwitchState(noti.getStates())
            endCell.notificationSetting = noti
            endCell.addDelegate = self
            return endCell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        
        var noti: NotificationSetting?
        if hasOnNotifications && hasOffNotifications {
            noti = indexPath.section == 0 ? onNotificaitons[indexPath.row] : offNotifications[indexPath.row]
        } else {
            noti = hasOnNotifications ? onNotificaitons[indexPath.row] : offNotifications[indexPath.row]
        }
        
        let selectedNot:SelectedNotificationTypeController = SelectedNotificationTypeController()
        if let noti = noti {
            selectedNot.notSetting = noti
            selectedNot.selectedDelegate = self
        }
        
        self.navigationController?.pushViewController(selectedNot, animated: true)
    }
}

// MARK: - SelectedNotificationDelegate
extension NotificationViewController:AddPacketToWatchDelegate {
    func addPacketToWatchDelegate(appid:String,onOff:Bool){
        initNotificationSettingArray()
        self.tableView.reloadData()
        AppDelegate.getAppDelegate().LunaRNotfication()
    }
    
    func didSelectedNotificationDelegate(_ clockIndex:Int,ntSwitchState:Bool,appid:String){
        for model in mNotificationArray {
            let notModel:MEDUserNotification = model
            if(notModel.appid == appid){
                let realm = try! Realm()
                try! realm.write {
                    notModel.clock = clockIndex
                    notModel.isAddWatch = ntSwitchState
                }
                initNotificationSettingArray()
                self.tableView.reloadData()
                if(AppDelegate.getAppDelegate().isConnected()){
                    AppDelegate.getAppDelegate().SetNortification(allArraySettingArray)
                    let banner = MEDBanner(title: NSLocalizedString("sync_notifications", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 2.0)
                }else{
                    let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                    banner.dismissesOnTap = true
                    banner.show(duration: 2.0)
                }
                break
            }
        }
    }
}
