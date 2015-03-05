//
//  NotificationController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationController: UIViewController,SelectionTypeDelegate {

    var sDelegate:SelectionTypeDelegate!

    @IBOutlet var notificationList: NotificationView!

    var noticeTypeArray:NSArray!
    var typeModel:TypeModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = NSLocalizedString("Notification", comment: "")
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel

        sDelegate = self
        typeModel = TypeModel()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SelectionTypeDelegate
    func onSelectedType(results:Bool,type:NSString){
        NSLog("type===:\(type)")
        typeModel.setNotificationTypeStates(type, states: results)
        notificationList.tableListView.reloadData()
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        return 50.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        noticeTypeArray = typeModel.getNotificationTypeContent()[indexPath.row] as NSArray
        self.performSegueWithIdentifier("EnterNotification", sender: self)
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let countyyy:Int = typeModel.getNotificationTypeContent().count
        return typeModel.getNotificationTypeContent().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = notificationList.NotificationlistCell(indexPath, dataSource: typeModel.getNotificationTypeContent())
        return cell
    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //TODD
        if (segue.identifier == "EnterNotification"){
            var notficp = segue.destinationViewController as EnterNotificationController
            notficp.notTypeArray = noticeTypeArray

            notficp.sDelegate = sDelegate

        }

    }

}
