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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNotificationSettingArray()
        
        let indexSet:NSIndexSet = NSIndexSet(indexesIn: NSMakeRange(0, 1))
        tableView.reloadSections(indexSet as IndexSet, with: .automatic)
        tableView.reloadData()
    }

    func initNotificationSettingArray() {
        mNotificationArray = MEDUserNotification.getAll() as! [MEDUserNotification]
        allArraySettingArray.removeAll()
        for model in mNotificationArray{
            let notification:MEDUserNotification = model
            let notificationType:String = notification.notificationType
            var type = NotificationType(rawValue: notificationType as NSString)
            if type == nil {
                type = NotificationType.whatsapp
            }
            let setting:NotificationSetting = NotificationSetting(type: type!, clock: notification.clock, color: NSNumber(value:notification.clock), states:notification.isAddWatch)
            allArraySettingArray.append(setting)
        }
    }

    // MARK: - SelectedNotificationDelegate
    func didSelectedNotificationDelegate(_ clockIndex:Int,ntSwitchState:Bool,notificationType:String){
        XCGLogger.default.debug("clockIndex····:\(clockIndex),ntSwitchState·····:\(ntSwitchState)")
        for model in mNotificationArray {
            let notModel:MEDUserNotification = model
            if(notModel.notificationType == notificationType){
                let model:MEDUserNotification = MEDUserNotification()
                model.key = notModel.key
                model.appid = notModel.appid
                model.appName = notModel.appName
                model.receiveDate = notModel.receiveDate
                model.clock = clockIndex
                model.isAddWatch = ntSwitchState
                model.deleteFlag = notModel.deleteFlag
                if(model.update()){
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
                }
                break
            }
        }
    }

    // MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 45.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let noti:NotificationSetting = allArraySettingArray[indexPath.row]
        let selectedNot:SelectedNotificationTypeController = SelectedNotificationTypeController()
        selectedNot.notSetting = noti
        selectedNot.selectedDelegate = self
        self.navigationController?.pushViewController(selectedNot, animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        return NSLocalizedString(titleHeader[section], comment: "")
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headView = view as! UITableViewHeaderFooterView
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            headView.textLabel?.textColor = UIColor.white
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if mNotificationArray.count>0 {
            switch (section){
            case 0:
                return (allArraySettingArray.filter({$0.getStates() == false})).count
            case 1:
                return (allArraySettingArray.filter({$0.getStates() == true})).count
            default:
                return 1;
            }
        }else{
            return 1
        }
        
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var noti:NotificationSetting? = allArraySettingArray[indexPath.row]
        switch indexPath.section {
        case 0:
            noti = (allArraySettingArray.filter({$0.getStates() == false}))[indexPath.row]
        default:
            noti = (allArraySettingArray.filter({$0.getStates() == true}))[indexPath.row]
        }
        
        if let noti = noti {
            var detailString:String = ""
            noti.getStates() ? (detailString = noti.getColorName()) : (detailString = NSLocalizedString("turned_off", comment: ""))
            return NotificationView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: noti.typeName, detailLabel:detailString)
        }
        
        return UITableViewCell()
    }
}
