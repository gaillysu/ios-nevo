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

class NotificationViewController: UITableViewController {
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

        self.tableView.register(UINib(nibName: "NotificationTypeCell", bundle: nil), forCellReuseIdentifier: "Notification_Identifier")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNotificationSettingArray()
        tableView.reloadData()
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

// MARK: - Private function
extension NotificationViewController {
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

            let setting:NotificationSetting = NotificationSetting(type: type!, clock: notification.clock, color: notification.colorValue, colorName: notification.colorName, states:notification.isAddWatch,packet:notification.appid ,appName:notification.appName)
            allArraySettingArray.append(setting)
        }
    }
}

// MARK: - TableView Datasource & Delegate
extension NotificationViewController {
    
    func deleteNotificationsAlertView() {
        let banner = MEDBanner(title: NSLocalizedString("Because it is a basic Notifications can not be deleted", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
        banner.dismissesOnTap = true
        banner.show(duration: 1.5)
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
            endCell.setTitleLabel(title: noti.getAppName())
            endCell.setContentLabel(content: NSLocalizedString(detailString, comment: ""))
            endCell.setTitleImage(imageName: "new_\(noti.typeName.lowercased())")
            
            if endCell.titleImage.image == nil {
                let bundleid:String = noti.getPacket()
                if let rawAppName = NSString.init(string: noti.getPacket()).components(separatedBy: ".").last {
                    endCell.setTitleLabel(title: rawAppName)
                }
                
                let placeholderImage: String = "notiPlaceholder"
                endCell.setTitleImage(imageName: placeholderImage)
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

// MARK: - AddPacketToWatchDelegate, SelectedNotificationDelegate
extension NotificationViewController: AddPacketToWatchDelegate, SelectedNotificationDelegate {
    func addPacketToWatchDelegate(appid:String,onOff:Bool){
        initNotificationSettingArray()
        self.tableView.reloadData()
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
                if ConnectionManager.manager.isConnected {
                    ConnectionManager.manager.setNortification(allArraySettingArray)
                    
                    let banner = MEDBanner(title: NSLocalizedString("sync_notifications", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
                    banner.dismissesOnTap = true
                    banner.show(duration: 2.0)
                }else{
                    let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
                    banner.dismissesOnTap = true
                    banner.show(duration: 2.0)
                }
                break
            }
        }
    }
    
    func didDeleteNotification(appID: String) {
        let notifications = MEDUserNotification.getFilter("key = '\(appID)'")
        if notifications.count>0 {
            let notiValue:MEDUserNotification = notifications[0] as! MEDUserNotification
            if notiValue.deleteFlag {
                _ = notiValue.remove()
            } else {
                deleteNotificationsAlertView()
            }
        }
        
        initNotificationSettingArray()
        tableView.reloadData()
    }
}
