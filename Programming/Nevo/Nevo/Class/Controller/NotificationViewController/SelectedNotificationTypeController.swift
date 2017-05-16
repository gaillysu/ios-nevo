//
//  SelectedNotificationTypeController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

protocol SelectedNotificationDelegate {
    func didSelectedNotificationDelegate(_ clockIndex:Int,ntSwitchState:Bool,appid:String)
    func didDeleteNotification(appID: String)
}

class SelectedNotificationTypeController: UITableViewController {
    
    @IBOutlet weak var selectedNotificationView: SelectedNotificationView!
    fileprivate let colorArray:[String] = ["2 o'clock","4 o'clock","6 o'clock","8 o'clock","10 o'clock","12 o'clock"]
    var selectedDelegate:SelectedNotificationDelegate?
    var notSetting:NotificationSetting?
    
    lazy var realm : Realm = {
        return try! Realm()
    }()

    var notification: MEDUserNotification? {
        return self.realm.objects(MEDUserNotification.self).filter("appid == %@", self.notSetting!.getPacket()).first
    }
    
    var notificationColor: MEDNotificationColor?
    
    fileprivate var isFirstLoadData: Bool = true
    
    var notificationSection:Int {
        return AppTheme.isTargetLunaR_OR_Nevo() ? 3 : 4
    }
    
    init() {
        super.init(nibName: "SelectedNotificationTypeController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if notSetting!.typeName == "Other", let name = notSetting?.getAppName() {
            navigationItem.title = name
        } else {
            let title:String = notSetting!.typeName
            let titleString:String = AppTheme.isTargetLunaR_OR_Nevo() ? title.replacingOccurrences(of: "WeChat", with: "Whatsapp"):title
            navigationItem.title = NSLocalizedString(titleString, comment: "")
        }
        
        self.tableView.register(UINib(nibName: "LineColorCell",bundle: nil), forCellReuseIdentifier: "LineColor_Identifier")
        self.tableView.register(UINib(nibName: "AllowNotificationsTableViewCell",bundle: nil), forCellReuseIdentifier: "AllowNotifications_Identifier")
        
        selectedNotificationView.separatorStyle = notSetting!.getStates() ? .singleLine : .none
        
        viewDefaultColorful()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if notification != nil {
            let notificationType:String = notification!.notificationType
            var type = NotificationType(rawValue: notificationType as NSString)
            if type == nil {
                type = NotificationType.other
            }
            notSetting = NotificationSetting(type: type!, clock: notification!.clock, color: notification!.colorValue, colorName: notification!.colorName, states:notification!.isAddWatch,packet:notification!.appid ,appName:notification!.appName)
        }
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate
extension SelectedNotificationTypeController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if !notSetting!.getStates() && [1, 2, 3].contains(indexPath.section) {
            return 0
        }
        
        switch (indexPath.section){
        case 1:
            return 185.0
        default: return 45.0;
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.section == 2){
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                let controller = NotiColorController(style: .grouped)
                controller.notificationColor = self.notificationColor
                controller.notification = self.notification
                navigationController?.pushViewController(controller, animated: true)
                return
            }
            
            let cell:LineColorCell = tableView.cellForRow(at: indexPath) as! LineColorCell
            let image = UIImage(named: "notifications_check")
            cell.accessoryView = UIImageView(image: image)
            
            notSetting?.setClock((indexPath.row+1)*2)
            selectedDelegate?.didSelectedNotificationDelegate(notSetting!.getClock(), ntSwitchState: notSetting!.getStates(),appid:notSetting!.getPacket())
            let reloadIndexPath:IndexPath = IndexPath(row: 0, section: 1)
            tableView.reloadRows(at: [reloadIndexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.automatic)
        } else if indexPath.section == 3 {
            let alertController = MEDAlertController(title: NSLocalizedString("DeleteNotificationWarning", comment: ""), message: nil, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (_) in
                self.selectedDelegate?.didDeleteNotification(appID: self.notSetting!.getPacket())
                _ = self.navigationController?.popViewController(animated: true)

            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            confirmAction.viewDefaultColorful()
            cancelAction.viewDefaultColorful()
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - TableView DataSource
extension SelectedNotificationTypeController:AddPacketToWatchDelegate {
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return notificationSection
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 && AppTheme.isTargetLunaR_OR_Nevo() {
            return colorArray.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).section){
        case 0:
            let allowCell:AllowNotificationsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AllowNotifications_Identifier", for: indexPath) as! AllowNotificationsTableViewCell
            allowCell.selectionStyle = UITableViewCellSelectionStyle.none;
            allowCell.addDelegate = self
            allowCell.notificationSetting = notSetting
            var titleColor:UIColor?
            var onColor:UIColor?
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                titleColor = UIColor.white
                onColor = UIColor.getBaseColor()
                allowCell.backgroundColor = UIColor.getGreyColor()
            }else{
                titleColor = UIColor.black
                onColor = AppTheme.NEVO_SOLAR_YELLOW()
            }
            allowCell.setAllowSwitch(color: onColor!,isOn:notSetting!.getStates())
            allowCell.setTitleLabel(title: NSLocalizedString("Allow_Notifications", comment: ""), titleColor: titleColor!, titleFont: nil)
            return allowCell
        case 1:
            let colorString = notSetting!.getHexColor()
            let color = colorString == "" ? UIColor.getRandomColor() : UIColor(colorString)
            let cell = selectedNotificationView.getNotificationClockCell(indexPath, tableView: tableView, image: UIImage.dotImageWith(color: color, backgroundColor: UIColor.getGreyColor(), size: CGSize(width: 15, height: 15)), clockIndex: notSetting!.getClock())
            
            cell.viewDefaultColorful()
            
            return cell
        case 2:
            var cell: UITableViewCell = UITableViewCell.init()
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                cell.accessoryType = notSetting!.getStates() ? .disclosureIndicator : .none
                let colorString = notSetting!.getHexColor()
                let color = colorString == "" ? UIColor.getRandomColor() : UIColor(colorString)
                
                cell.imageView?.image = UIImage.dotImageWith(color: color, backgroundColor: UIColor.getGreyColor(), size: CGSize(width: 15, height: 15))

                cell.imageView?.backgroundColor = UIColor.clear
                cell.textLabel?.text = notSetting!.getLunarColorName()
                cell.selectionStyle = .none
            } else {
                cell = selectedNotificationView.getLineColorCell(indexPath, tableView: tableView, cellTitle: colorArray[indexPath.row], clockIndex: notSetting!.getClock())
            }
            
            if !notSetting!.getStates() {
                cell.accessoryView = nil
            }
            
            cell.viewDefaultColorful()
            return cell
        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "kDeleteCellIdentifier")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "kDeleteCellIdentifier")
            }
            let deleteLabel: UILabel = UILabel()
            cell!.contentView.addSubview(deleteLabel)
            
            deleteLabel.snp.makeConstraints({ (v) in
                v.edges.equalToSuperview()
            })
            
            deleteLabel.font = UIFont(name: "Raleway", size: 16)
            deleteLabel.text = NSLocalizedString("Delete Notification", comment: "")
            deleteLabel.textAlignment = .center
            
            cell!.viewDefaultColorful()
            deleteLabel.viewDefaultColorful()

            return cell!
        }
    }
    
    func addPacketToWatchDelegate(appid:String,onOff:Bool){
        selectedDelegate?.didSelectedNotificationDelegate(notSetting!.getClock(), ntSwitchState: onOff,appid:appid)
        notSetting?.setStates(onOff)
        notSetting?.setClock(notSetting!.getClock())
        tableView.separatorStyle = onOff ? .singleLine : .none
        selectedNotificationView.reloadSections(IndexSet.init(integersIn: 1..<notificationSection), with: .automatic)
    }
}
