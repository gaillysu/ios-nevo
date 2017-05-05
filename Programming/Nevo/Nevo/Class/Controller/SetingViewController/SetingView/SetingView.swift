//
//  SetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import MSCellAccessory

private let NotificationSwitchButtonTAG:Int = 1690
class SetingView: UIView {
    
    @IBOutlet var tableListView: UITableView!
    
    var settingsViewController:SetingViewController?
    fileprivate var mDelegate:ButtonManagerCallBack?
    //var animationView:AnimationView!
    var mSendLocalNotificationSwitchButton:UISwitch!
    
    let unitArray = [NSLocalizedString("metrics", comment: ""),NSLocalizedString("imperial", comment: "")]
    weak var unitTextField:UITextField?
    var picker:UIPickerView?
    func bulidNotificationViewUI(_ delegate:ButtonManagerCallBack){
        mDelegate = delegate
        tableListView.separatorColor = UIColor.lightGray
        tableListView.viewDefaultColorful()
    }
    
    @IBAction func buttonAction(_ sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }
    
    func NotificationSystemTableViewCell(_ indexPath:IndexPath,tableView:UITableView,model:(cellName:String,imageName:String))->UITableViewCell {
        let cellID:String = "NotificationSystemTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if (cell == nil) {
            switch indexPath.section {
            case 1:
                switch indexPath.row {
                case 0:
                    cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellID)
                case 2:
                    cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellID)
                default:
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
                }
            case 2:
                switch indexPath.row {
                case 1:
                    cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellID)
                    picker = UIPickerView()
                    guard let picker = self.picker else{
                        return cell!
                    }
                    picker.delegate = self
                    picker.dataSource = self
                    unitTextField = UITextField(frame: CGRect(x: 0, y: 300, width: 0, height: 0))
                    addSubview(unitTextField!)
                    unitTextField?.inputView = picker
        
                default:
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
                }
            default:
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
            }
        }
        cell?.backgroundColor = UIColor.white
        cell?.textLabel?.text = model.cellName
        cell?.textLabel?.textColor = UIColor.black
        cell?.textLabel!.backgroundColor = UIColor.clear
        cell?.imageView?.image = UIImage(named: model.imageName)
        cell?.accessoryType = .disclosureIndicator
        cell?.viewDefaultColorful()

        if indexPath.row == 0 && indexPath.section == 1 {
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                cell?.textLabel?.text = "My LunaR";
            }
            let connectionController = AppDelegate.getAppDelegate().getMconnectionController()!
            var statusString = NSLocalizedString("Disconnected", comment: "")
            var color = UIColor.darkRed()
            if connectionController.isConnected() {
                if UserDefaults.standard.getFirmwareVersion() < AppTheme.GET_FIRMWARE_VERSION() || UserDefaults.standard.getSoftwareVersion() < AppTheme.GET_SOFTWARE_VERSION() {
                    statusString = NSLocalizedString("New Version Available!", comment: "")
                    color = UIColor.getBaseColor()
                } else {
                    statusString = NSLocalizedString("Connected", comment: "")
                    color = UIColor.darkGreen()
                }
            }
            cell?.detailTextLabel?.text = statusString
            cell?.detailTextLabel?.textColor = color
            cell?.detailTextLabel?.alpha = 0.7
        }else if indexPath.row == 2 && indexPath.section == 1{
            if UserDefaults.standard.getFirmwareVersion() >= 40 && UserDefaults.standard.getSoftwareVersion() >= 27{
                cell?.enable(on: true)
                cell?.detailTextLabel?.textColor = UIColor.lightGray
                cell?.detailTextLabel?.text = UserDefaults.standard.getDurationSearch().shortTimeRepresentation()
                cell?.accessoryView = nil
                cell?.accessoryType = .disclosureIndicator
            }else{
                cell?.enable(on: false)
                cell?.accessoryType = .none
                cell?.isUserInteractionEnabled = true
                cell?.accessoryView = MSCellAccessory.init(type: FLAT_DETAIL_BUTTON , color: UIColor.getBaseColor())
                cell?.accessoryView?.addGestureRecognizer(UITapGestureRecognizer(target: settingsViewController, action: #selector(settingsViewController?.showUpdateNevoAlertView)))
                cell?.selectionStyle = .none
            }
        }else if indexPath.row == 4 && indexPath.section == 1{
            let activity:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activity.center = CGPoint(x: UIScreen.main.bounds.size.width-activity.frame.size.width, y: 50/2.0)
            cell?.contentView.addSubview(activity)
            activity.viewDefaultColorful()
            cell?.accessoryType = .none
        }else if indexPath.row == 1 && indexPath.section == 2{
            if let unit = MEDSettings.int(forKey: "UserSelectedUnit"){
                if unit == 0 {
                    cell?.detailTextLabel?.text = "Metrics"
                } else {
                    cell?.detailTextLabel?.text = "Imperical"
                }
            }
            cell?.detailTextLabel?.textColor = UIColor.lightGray
        }
        return cell!
    }
    
    func LinkLossNotificationsTableViewCell(_ indexPath:IndexPath,tableView:UITableView,model:(cellName:String,imageName:String))->UITableViewCell {
        let cellID:String = "LinkLossNotificationsTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        }
        cell?.backgroundColor = UIColor.white
        cell?.contentView.backgroundColor = UIColor.white
        cell?.textLabel?.text = model.cellName
        cell?.imageView?.image = UIImage(named: model.imageName)
        cell?.textLabel?.textColor = UIColor.black
        let view = cell!.contentView.viewWithTag(NotificationSwitchButtonTAG)
        if view == nil {
            mSendLocalNotificationSwitchButton = UISwitch(frame: CGRect(x: 0,y: 0,width: 51,height: 31))
            mSendLocalNotificationSwitchButton.tag = NotificationSwitchButtonTAG
            mSendLocalNotificationSwitchButton?.isOn = ConnectionManager.sharedInstance.getIsSendLocalMsg()
            mSendLocalNotificationSwitchButton?.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            mSendLocalNotificationSwitchButton?.addTarget(self, action: #selector(SetingView.buttonAction(_:)), for: UIControlEvents.valueChanged)
            mSendLocalNotificationSwitchButton?.center = CGPoint(x: UIScreen.main.bounds.size.width-32, y: 50.0/2.0)
            cell?.contentView.addSubview(mSendLocalNotificationSwitchButton!)
        }
        
        // Theme adjust
        cell?.viewDefaultColorful()
        mSendLocalNotificationSwitchButton.viewDefaultColorful()
        
        return cell!
    }
    
    class func getNotificationSettingIcon(_ notificationSetting:NotificationSetting) -> String {
        var icon:String = ""
        switch notificationSetting.getType() {
        case .call:
            icon = "callIcon"
        case .email:
            icon = "emailIcon"
        case .facebook:
            icon = "facebookIcon"
        case .sms:
            icon = "smsIcon"
        case .calendar:
            icon = "calendar_icon"
        case .wechat:
            icon = "WeChat_Icon"
        case .whatsapp:
            icon = "WeChat_Icon"
        case .other:
            icon = "WeChat_Icon"
        }
        
        return icon
    }
    
    func NotificationSwicthCell(_ indexPath:IndexPath)->UITableViewCell {
        let cellID:String = "SwicthCell"
        var cell:UITableViewCell?
        cell = tableListView.dequeueReusableCell(withIdentifier: cellID)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
            mSendLocalNotificationSwitchButton = UISwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            mSendLocalNotificationSwitchButton.center = CGPoint(x: cell!.contentView.frame.size.width-60, y: 65/2.0)
            mSendLocalNotificationSwitchButton.addTarget(self, action: #selector(SetingView.SendLocalNotificationSwitchAction(_:)), for: UIControlEvents.valueChanged)
            mSendLocalNotificationSwitchButton.isOn = ConnectionManager.sharedInstance.getIsSendLocalMsg()
            mSendLocalNotificationSwitchButton.tintColor = AppTheme.NEVO_SOLAR_GRAY()
            mSendLocalNotificationSwitchButton.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
            cell?.contentView.addSubview(mSendLocalNotificationSwitchButton)
            cell?.layer.borderWidth = 0.5;
            cell?.layer.borderColor = UIColor.gray.cgColor;
            //cell?.selectionStyle = UITableViewCellSelectionStyle.None;
            cell?.textLabel?.text = NSLocalizedString("Link-Loss Notifications", comment: "")
        }
        return cell!
    }
    
    func SendLocalNotificationSwitchAction(_ swicth:UISwitch) {
        mDelegate?.controllManager(swicth)
    }
}

// MARK: - UIPickerViewDataSource
extension SetingView: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unitArray[row]
    }
}

extension SetingView: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

// MARK: - UIPickerViewDelegate
extension SetingView: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        MEDSettings.setValue(row, forKey: "UserSelectedUnit")
        let cell = self.tableListView.cellForRow(at: IndexPath(row: 1, section: 2))
        if row == 0 {
            cell?.detailTextLabel?.text = "Metrics"
        } else {
            cell?.detailTextLabel?.text = "Imperical"
        }
    }
}
