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
    fileprivate var mNotificationOFFArray:[NotificationSetting] = []
    fileprivate var mNotificationONArray:[NotificationSetting] = []
    fileprivate let titleHeader:[String] = ["ACTIVE_NOTIFICATIONS","INACTIVE_NOTIFICATIONS"]
    fileprivate var mNotificationArray:NSArray = NSArray()

    var hasNotiOFF:Bool {
        get {
            return self.mNotificationOFFArray.count != 0
        }
    }
    var hasNotiON:Bool {
        get {
            return self.mNotificationONArray.count != 0
        }
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
        //notificationView.backgroundColor = UIColor.white
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.tableView.backgroundColor = UIColor.getGreyColor()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNotificationSettingArray()
        
        // xcode is sucks
        let indexSet:NSIndexSet = NSIndexSet(indexesIn: NSMakeRange(0, 1))
        tableView.reloadSections(indexSet as IndexSet, with: .automatic)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     init the mNotificationSettingArray

     :returns:
     */
    func initNotificationSettingArray() {
        mNotificationOFFArray.removeAll()
        mNotificationONArray.removeAll()
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
                    if(notification.status) {
                        mNotificationONArray.append(setting)
                    }else {
                        mNotificationOFFArray.append(setting)
                    }
                    break
                }
            }
        }
    }

    // MARK: - SelectedNotificationDelegate
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

    // MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 45.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        var titleString:String = ""
        var clockIndex:Int = 0
        var state:Bool = false
        
        var noti:NotificationSetting?
        if hasNotiON && hasNotiOFF {
            switch indexPath.section {
            case 0:
                noti = mNotificationONArray[indexPath.row]
            default:
                noti = mNotificationOFFArray[indexPath.row]
            }
        } else {
            if hasNotiON {
                noti = mNotificationONArray[indexPath.row]
            } else {
                noti = mNotificationOFFArray[indexPath.row]
            }
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

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        if hasNotiON && hasNotiOFF {
            return NSLocalizedString(titleHeader[section], comment: "")
        } else {
            if hasNotiON {
                return NSLocalizedString(titleHeader[1], comment: "")
            } else {
                return NSLocalizedString(titleHeader[0], comment: "")
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headView = view as! UITableViewHeaderFooterView
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            headView.textLabel?.textColor = UIColor.white
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if hasNotiON && hasNotiOFF {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if hasNotiON && hasNotiOFF {
            switch (section){
            case 0:
                return mNotificationONArray.count
            case 1:
                return mNotificationOFFArray.count
            default:
                return 1;
            }
        }
        
        if hasNotiON {
            return mNotificationONArray.count
        } else {
            return mNotificationOFFArray.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var noti:NotificationSetting? = nil
        if hasNotiON && hasNotiOFF {
            switch indexPath.section {
            case 0:
                noti = mNotificationONArray[(indexPath as NSIndexPath).row]
            default:
                noti = mNotificationOFFArray[(indexPath as NSIndexPath).row]
            }
        } else {
            if hasNotiON {
                noti = mNotificationONArray[(indexPath as NSIndexPath).row]
            } else {
                noti = mNotificationOFFArray[(indexPath as NSIndexPath).row]
            }
        }
        
        if let noti = noti {
            var detailString:String = ""
            noti.getStates() ? (detailString = noti.getColorName()) : (detailString = NSLocalizedString("turned_off", comment: ""))
            return NotificationView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: noti.typeName, detailLabel:detailString)
        }
        
        return UITableViewCell()
}


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /**
    // MARK: - SwitchActionDelegate
    func onSwitch(results:Bool ,sender:UISwitch){
    let indexPath:NSIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
    let cell:TableListCell = notificationList.tableListView.cellForRowAtIndexPath(indexPath) as! TableListCell
    if(results){
    cell.round.hidden = false
    }else{
    cell.round.hidden = true
    }

    mNotificationType = mNotificationSettingArray[sender.tag-1].getType()
    let notSetting:NotificationSetting = NotificationSetting.indexOfObjectAtType(mNotificationSettingArray, type: mNotificationType)!
    EnterNotificationController.setMotorOnOff(NSString(string: notSetting.typeName), motorStatus: results)
    SetingViewController.refreshNotificationSettingArray(&mNotificationSettingArray)
    //send request to watch
    AppDelegate.getAppDelegate().SetNortification(mNotificationSettingArray)
    }

    // MARK: - SelectionTypeDelegate
    func onSelectedType(results:Bool,type:NSString){
    AppTheme.DLog("type===:\(type)")
    SetingViewController.refreshNotificationSettingArray(&mNotificationSettingArray)
    notificationList.tableListView.reloadData()
    }

    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
