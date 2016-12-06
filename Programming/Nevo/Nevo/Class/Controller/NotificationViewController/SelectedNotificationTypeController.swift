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
    var notificationColor: MEDNotificationColor?
    
    fileprivate var isFirstLoadData: Bool = true
    
    init() {
        super.init(nibName: "SelectedNotificationTypeController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if notSetting!.typeName == "Other" {
            navigationItem.title = notSetting?.getAppName()
        } else {
            navigationItem.title = NSLocalizedString(notSetting!.typeName, comment: "")
        }
        
        self.tableView.register(UINib(nibName: "LineColorCell",bundle: nil), forCellReuseIdentifier: "LineColor_Identifier")
        self.tableView.register(UINib(nibName: "AllowNotificationsTableViewCell",bundle: nil), forCellReuseIdentifier: "AllowNotifications_Identifier")
        selectedNotificationView.separatorStyle = notSetting!.getStates() ? .singleLine : .none
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tableView.backgroundColor = UIColor.getLightBaseColor()
        }
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
                let controller = NotiColorController()
                controller.notificationColor = self.notificationColor
                controller.notification = self.notSetting
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
            let alertController = ActionSheetView.makeWarningAlert(title: NSLocalizedString("DeleteNotificationWarning", comment: ""), message: nil, style: .alert, confirmText: NSLocalizedString("Yes", comment: ""), cancelText: NSLocalizedString("Cancel", comment: ""), okAction: { (_) in
                self.selectedDelegate?.didDeleteNotification(appID: self.notSetting!.getPacket())
                _ = self.navigationController?.popViewController(animated: true)
            }, cancelAction: { (_) in
                self.dismiss(animated: true, completion: nil)
            })
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - TableView DataSource
extension SelectedNotificationTypeController:AddPacketToWatchDelegate {
    func addPacketToWatchDelegate(appid:String,onOff:Bool){
        selectedDelegate?.didSelectedNotificationDelegate(notSetting!.getClock(), ntSwitchState: onOff,appid:appid)
        notSetting?.setStates(onOff)
        notSetting?.setClock(notSetting!.getClock())
        tableView.separatorStyle = onOff ? .singleLine : .none
        
        selectedNotificationView.reloadSections(IndexSet.init(integersIn: 1..<4), with: .automatic)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 2){
            return AppTheme.isTargetLunaR_OR_Nevo() ? colorArray.count : 1
        }
        return 1
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
            let cell = selectedNotificationView.getNotificationClockCell(indexPath, tableView: tableView, title: "", clockIndex: notSetting!.getClock())
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                cell.backgroundColor = UIColor.getGreyColor()
            }
            return cell
        case 2:
            var cell: UITableViewCell = selectedNotificationView.getLineColorCell(indexPath, tableView: tableView, cellTitle: colorArray[indexPath.row], clockIndex: notSetting!.getClock())
            
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                let realm = try! Realm()
                let noti = realm.objects(MEDUserNotification.self).filter("appid = \(notSetting?.getPacket())").first
                if let colorItem: MEDNotificationColor = realm.objects(MEDNotificationColor.self).filter("key = \(noti!.colorKey)").first {
                    /// 只有一个cell，不用考虑重用
                    cell = UITableViewCell.init()
                    cell.accessoryType = .disclosureIndicator
                    cell.imageView?.image = UIImage.dotImageWith(color: UIColor.init(rgba: colorItem.color), size: CGSize.init(width: 100, height: 100))
                    cell.textLabel?.text = colorItem.name
                    
                    self.notificationColor = colorItem
                } else {
                    cell = UITableViewCell.init()
                    cell.accessoryType = .disclosureIndicator
                    cell.imageView?.image = UIImage.dotImageWith(color: UIColor.getBaseColor(), size: CGSize.init(width: 100, height: 100))
                    cell.textLabel?.text = "Default Name"
                }
            }
            
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                cell.backgroundColor = UIColor.getGreyColor()
                cell.contentView.backgroundColor = UIColor.getGreyColor()
                cell.textLabel?.textColor = UIColor.white
            }
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
            
            deleteLabel.backgroundColor = UIColor.getGreyColor()
            deleteLabel.textColor = UIColor.white
            if AppTheme.isTargetLunaR_OR_Nevo() {
                deleteLabel.backgroundColor = UIColor.white
                deleteLabel.textColor = UIColor.black
            }
            
            return cell!
        }
    }
}
