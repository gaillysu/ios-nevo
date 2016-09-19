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
        notificationView.backgroundColor = UIColor.white
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
        XCGLogger.defaultInstance().debug("clockIndex····:\(clockIndex),ntSwitchState·····:\(ntSwitchState)")
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
                        let banner = Banner(title: NSLocalizedString("sync_notifications", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
                        banner.dismissesOnTap = true
                        banner.show(duration: 2.0)
                    }else{
                        let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
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
        switch ((indexPath as NSIndexPath).section){
        case 0:
            let notificationseting:NotificationSetting = mNotificationONArray[(indexPath as NSIndexPath).row]
            titleString = notificationseting.typeName
            clockIndex = notificationseting.getClock()
            state = notificationseting.getStates()
        case 1:
            let notificationseting:NotificationSetting = mNotificationOFFArray[(indexPath as NSIndexPath).row]
            titleString = notificationseting.typeName
            clockIndex = notificationseting.getClock()
            state = notificationseting.getStates()
        default: break;
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
        if(section == 0) {
            if(mNotificationONArray.count == 0) {
                return ""
            }else{
                return NSLocalizedString(titleHeader[section], comment: "")
            }
        }else{
            if(mNotificationOFFArray.count == 0) {
                return ""
            }else{
                return NSLocalizedString(titleHeader[section], comment: "")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return titleHeader.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0:
            return mNotificationONArray.count
        case 1:
            return mNotificationOFFArray.count
        default: return 1;
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).section){
        case 0:
            let notificationseting:NotificationSetting = mNotificationONArray[(indexPath as NSIndexPath).row]
            var detailString:String = ""
            notificationseting.getStates() ? (detailString = notificationseting.getColorName()) : (detailString = NSLocalizedString("turned_off", comment: ""))
            return NotificationView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: notificationseting.typeName, detailLabel:detailString)
        case 1:
            let notificationseting:NotificationSetting = mNotificationOFFArray[(indexPath as NSIndexPath).row]
            var detailString:String = ""
            notificationseting.getStates() ? (detailString = notificationseting.getColorName()) : (detailString = NSLocalizedString("turned_off", comment: ""))
            return NotificationView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: notificationseting.typeName, detailLabel:detailString)
        default: return UITableViewCell();
        }
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
