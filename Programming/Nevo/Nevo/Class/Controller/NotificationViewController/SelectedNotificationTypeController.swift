//
//  SelectedNotificationTypeController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol SelectedNotificationDelegate {

    func didSelectedNotificationDelegate(_ clockIndex:Int,ntSwitchState:Bool,notificationType:String)
}

class SelectedNotificationTypeController: UITableViewController {
    
    @IBOutlet weak var selectedNotificationView: SelectedNotificationView!
    let colorArray:[String] = ["2 o'clock","4 o'clock","6 o'clock","8 o'clock","10 o'clock","12 o'clock"]
    var titleString:String?
    var clockIndex:Int = 0
    var swicthStates:Bool = false
    var selectedDelegate:SelectedNotificationDelegate?

    init() {
        super.init(nibName: "SelectedNotificationTypeController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString(titleString!, comment: "")
        //self.view.backgroundColor = UIColor.white
        self.tableView.register(UINib(nibName: "LineColorCell",bundle: nil), forCellReuseIdentifier: "LineColor_Identifier")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonManager(_ sender:AnyObject){
        if(sender.isKind(of: UISwitch.classForCoder())){
            NSLog(" UISwitch 开关")
            let switchView:UISwitch = sender as! UISwitch
            let mNotificationArray:NSArray =  UserNotification.getAll()
            for model in mNotificationArray{
                let notificationModel:UserNotification = model as! UserNotification
                if(titleString == notificationModel.NotificationType){
                    selectedDelegate?.didSelectedNotificationDelegate(notificationModel.clock, ntSwitchState: switchView.isOn,notificationType:notificationModel.NotificationType)
                    if(switchView.isOn) {
                        swicthStates = true
                    }else {
                        swicthStates = false
                    }
                    selectedNotificationView.reloadData()
                    break
                }
            }
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        switch ((indexPath as NSIndexPath).section){
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        if(swicthStates){
            return 3
        }else{
            return 1
        }
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
            let cell = selectedNotificationView.AllowNotificationsTableViewCell(indexPath, tableView: tableView, title: NSLocalizedString("Allow_Notifications", comment: ""), state:swicthStates)
            for swicthView in cell.contentView.subviews{
                if(swicthView.isKind(of: UISwitch.classForCoder())){
                    let mSwitch:UISwitch = swicthView as! UISwitch
                    mSwitch.addTarget(self, action: #selector(SelectedNotificationTypeController.buttonManager(_:)), for: UIControlEvents.valueChanged)
                }
            }
            return cell
        case 1:
            return selectedNotificationView.getNotificationClockCell(indexPath, tableView: tableView, title: "", clockIndex: clockIndex)
        case 2:
            let cell = selectedNotificationView.getLineColorCell(indexPath, tableView: tableView, cellTitle: colorArray[(indexPath as NSIndexPath).row], clockIndex: clockIndex)
            return cell
        default: return UITableViewCell();
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if((indexPath as NSIndexPath).section == 2){
            let cell:LineColorCell = tableView.cellForRow(at: indexPath) as! LineColorCell
            cell.imageName.isHidden = false
            
            let mNotificationArray:NSArray =  UserNotification.getAll()
            for model in mNotificationArray{
                let notificationModel:UserNotification = model as! UserNotification
                if(titleString == notificationModel.NotificationType){
                    clockIndex = ((indexPath as NSIndexPath).row+1)*2
                    let reloadIndexPath:IndexPath = IndexPath(row: 0, section: 1)
                    selectedDelegate?.didSelectedNotificationDelegate(((indexPath as NSIndexPath).row+1)*2, ntSwitchState: notificationModel.status,notificationType:notificationModel.NotificationType)
                    tableView.reloadRows(at: [reloadIndexPath], with: UITableViewRowAnimation.automatic)
                    tableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.automatic)
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
