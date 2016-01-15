//
//  SelectedNotificationTypeController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol SelectedNotificationDelegate {

    func didSelectedNotificationDelegate(clockIndex:Int,ntSwitchState:Bool,notificationType:String)
}

class SelectedNotificationTypeController: UITableViewController {
    
    @IBOutlet weak var selectedNotificationView: SelectedNotificationView!
    let colorArray:[String] = ["2 o'clock","4 o'clock","6 o'clock","8 o'clock","10 o'clock","12 o'clock"]
    var titleString:String?
    var clockIndex:Int = 0
    var swicthStates:Bool = false
    var selectedDelegate:SelectedNotificationDelegate?

    init() {
        super.init(nibName: "SelectedNotificationTypeController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString(titleString!, comment: "")


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonManager(sender:AnyObject){
        if(sender.isKindOfClass(UISwitch.classForCoder())){
            NSLog(" UISwitch 开关")
            let switchView:UISwitch = sender as! UISwitch
            let mNotificationArray:NSArray =  UserNotification.getAll()
            for model in mNotificationArray{
                let notificationModel:UserNotification = model as! UserNotification
                if(titleString == notificationModel.NotificationType){
                    selectedDelegate?.didSelectedNotificationDelegate(notificationModel.clock, ntSwitchState: switchView.on,notificationType:notificationModel.NotificationType)
                    break
                }
            }
        }

    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        switch (indexPath.section){
        case 0:
            return 45.0
        case 1:
            //let cellHeight:CGFloat = selectedNotificationView.getNotificationClockCell(indexPath, tableView: tableView, title: "").contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            return 185.0
        case 2:
            return 50.0
        default: return 45.0;
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 2){
            return colorArray.count
        }
        return 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            let cell = selectedNotificationView.AllowNotificationsTableViewCell(indexPath, tableView: tableView, title: "Allow Notifications", state:swicthStates)
            for swicthView in cell.contentView.subviews{
                if(swicthView.isKindOfClass(UISwitch.classForCoder())){
                    let mSwitch:UISwitch = swicthView as! UISwitch
                    mSwitch.addTarget(self, action: Selector("buttonManager:"), forControlEvents: UIControlEvents.ValueChanged)
                }
            }
            return cell
        case 1:
            return selectedNotificationView.getNotificationClockCell(indexPath, tableView: tableView, title: "", clockIndex: clockIndex)
        case 2:
            let cell = selectedNotificationView.getLineColorCell(indexPath, tableView: tableView, cellTitle: colorArray[indexPath.row], clockIndex: clockIndex)
            return cell
        default: return UITableViewCell();
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.section == 2){
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            for view in tableView.visibleCells{
                let image = view.viewWithTag((tableView as! SelectedNotificationView).checkTag)
                if(image != nil){
                    if(cell!.isEqual(view)){
                        image?.hidden = false
                    }else{
                        image?.hidden = true
                    }
                }
            }
            
            let mNotificationArray:NSArray =  UserNotification.getAll()
            for model in mNotificationArray{
                let notificationModel:UserNotification = model as! UserNotification
                if(titleString == notificationModel.NotificationType){
                    clockIndex = (indexPath.row+1)*2
                    let reloadIndexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 1)
                    selectedDelegate?.didSelectedNotificationDelegate((indexPath.row+1)*2, ntSwitchState: notificationModel.status,notificationType:notificationModel.NotificationType)
                    tableView.reloadRowsAtIndexPaths([reloadIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    break
                }
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
