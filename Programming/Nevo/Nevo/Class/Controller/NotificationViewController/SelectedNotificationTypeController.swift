//
//  SelectedNotificationTypeController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol SelectedNotificationDelegate {

    func didSelectedNotificationDelegate(_ clockIndex:Int,ntSwitchState:Bool,appid:String)
}

class SelectedNotificationTypeController: UITableViewController {
    
    @IBOutlet weak var selectedNotificationView: SelectedNotificationView!
    fileprivate let colorArray:[String] = ["2 o'clock","4 o'clock","6 o'clock","8 o'clock","10 o'clock","12 o'clock"]
    var selectedDelegate:SelectedNotificationDelegate?
    var notSetting:NotificationSetting?
    
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
            self.navigationItem.title = NSLocalizedString(notSetting!.typeName, comment: "")
        }
        
        self.tableView.register(UINib(nibName: "LineColorCell",bundle: nil), forCellReuseIdentifier: "LineColor_Identifier")
        tableView.separatorStyle = notSetting!.getStates() ? .singleLine : .none
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tableView.backgroundColor = UIColor.getLightBaseColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonManager(_ sender:AnyObject){
        if(sender.isKind(of: UISwitch.classForCoder())){
            let switchView:UISwitch = sender as! UISwitch
            selectedDelegate?.didSelectedNotificationDelegate(notSetting!.getClock(), ntSwitchState: switchView.isOn,appid:notSetting!.getPacket())
            notSetting?.setStates(switchView.isOn)
            notSetting?.setClock(notSetting!.getClock())
            tableView.separatorStyle = switchView.isOn ? .singleLine : .none
            selectedNotificationView.reloadData()
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        switch ((indexPath as NSIndexPath).section){
        case 0:
            return 45.0
        case 1:
            return 185.0
        case 2:
            return 50.0
        default: return 45.0;
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 2){
            return colorArray.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).section){
        case 0:
            let titleString:String = AppTheme.isTargetLunaR_OR_Nevo() ? "Allow_Notifications" : "Allow_Notifications_Lunar"
            let cell = selectedNotificationView.AllowNotificationsTableViewCell(indexPath, tableView: tableView, title: NSLocalizedString(titleString, comment: ""), state:notSetting!.getStates())
            for swicthView in cell.contentView.subviews{
                if(swicthView.isKind(of: UISwitch.classForCoder())){
                    let mSwitch:UISwitch = swicthView as! UISwitch
                    mSwitch.addTarget(self, action: #selector(SelectedNotificationTypeController.buttonManager(_:)), for: UIControlEvents.valueChanged)
                }
            }
            return cell
        case 1:
            let cell = selectedNotificationView.getNotificationClockCell(indexPath, tableView: tableView, title: "", clockIndex: notSetting!.getClock())
            if notSetting!.getStates() {
                cell.backgroundColor = UIColor.white
                cell.isUserInteractionEnabled = true;
                if !AppTheme.isTargetLunaR_OR_Nevo() {
                    cell.backgroundColor = UIColor.getGreyColor()
                }
            }else{
                cell.backgroundColor = UIColor.clear
                cell.isUserInteractionEnabled = false;
            }
            return cell
        case 2:
            let cell = selectedNotificationView.getLineColorCell(indexPath, tableView: tableView, cellTitle: colorArray[indexPath.row], clockIndex: notSetting!.getClock())
            
            if notSetting!.getStates() {
                cell.backgroundColor = UIColor.white
                cell.contentView.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryView?.isHidden = false
                cell.isUserInteractionEnabled = true
                if !AppTheme.isTargetLunaR_OR_Nevo() {
                    cell.backgroundColor = UIColor.getGreyColor()
                    cell.contentView.backgroundColor = UIColor.getGreyColor()
                    cell.textLabel?.textColor = UIColor.white
                }
            }else{
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
                cell.accessoryView?.isHidden = true
                cell.isUserInteractionEnabled = false
            }
            
            return cell
        default: return UITableViewCell();
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if((indexPath as NSIndexPath).section == 2){
            let cell:LineColorCell = tableView.cellForRow(at: indexPath) as! LineColorCell
            let image = UIImage(named: "notifications_check")
            cell.accessoryView = UIImageView(image: image)
            
            notSetting?.setClock((indexPath.row+1)*2)
            selectedDelegate?.didSelectedNotificationDelegate(notSetting!.getClock(), ntSwitchState: notSetting!.getStates(),appid:notSetting!.getPacket())
            let reloadIndexPath:IndexPath = IndexPath(row: 0, section: 1)
            tableView.reloadRows(at: [reloadIndexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.automatic)
        }

    }
}
