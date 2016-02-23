//
//  NotificationViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationViewController: UITableViewController,SelectedNotificationDelegate {
    private var mNotificationOFFArray:[NotificationSetting] = []
    private var mNotificationONArray:[NotificationSetting] = []
    private let titleHeader:[String] = ["ACTIVE_NOTIFICATIONS","INACTIVE_NOTIFICATIONS"]
    private var mNotificationArray:NSArray = NSArray()

    @IBOutlet weak var notificationView: NotificationView!

    init() {
        super.init(nibName: "NotificationViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationSettingArray()
        notificationView.bulidNotificationView(self.navigationItem)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            NotificationType.CALL,
            NotificationType.EMAIL,
            NotificationType.FACEBOOK,
            NotificationType.SMS,
            NotificationType.WECHAT,
            NotificationType.CALENDAR]
        for notificationType in notificationTypeArray {
            for model in mNotificationArray{
                let notification:UserNotification = model as! UserNotification
                if(notification.NotificationType == notificationType.rawValue){
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
    func didSelectedNotificationDelegate(clockIndex:Int,ntSwitchState:Bool,notificationType:String){
        AppTheme.DLog("clockIndex····:\(clockIndex),ntSwitchState·····:\(ntSwitchState)")
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
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 45.0
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40.0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var titleString:String = ""
        var clockIndex:Int = 0
        var state:Bool = false
        switch (indexPath.section){
        case 0:
            let notificationseting:NotificationSetting = mNotificationONArray[indexPath.row]
            titleString = notificationseting.typeName
            clockIndex = notificationseting.getClock()
            state = notificationseting.getStates()
        case 1:
            let notificationseting:NotificationSetting = mNotificationOFFArray[indexPath.row]
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
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        return NSLocalizedString(titleHeader[section], comment: "")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return titleHeader.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0:
            return mNotificationONArray.count
        case 1:
            return mNotificationOFFArray.count
        default: return 1;
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            let notificationseting:NotificationSetting = mNotificationONArray[indexPath.row]
            var detailString:String = ""
            notificationseting.getStates() ? (detailString = notificationseting.getColorName()) : (detailString = NSLocalizedString("turned_off", comment: ""))
            return NotificationView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: notificationseting.typeName, detailLabel:detailString)
        case 1:
            let notificationseting:NotificationSetting = mNotificationOFFArray[indexPath.row]
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
