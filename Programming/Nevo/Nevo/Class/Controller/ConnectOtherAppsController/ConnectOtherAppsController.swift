//
//  ConnectOtherAppsController.swift
//  Nevo
//
//  Created by leiyuncun on 16/5/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class ConnectOtherAppsController: UITableViewController {
    private let licenseApp:[String] = ["HealthKit","Validic"]
    
    init() {
        super.init(nibName: "ConnectOtherAppsController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "App Authorized"
        self.tableView.registerNib(UINib(nibName: "ConnectOtherAppsCell", bundle:nil), forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return licenseApp.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier" ,forIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        (cell as! ConnectOtherAppsCell).appNameLabel.text = licenseApp[indexPath.row]
        (cell as! ConnectOtherAppsCell).appSwitch.tag = indexPath.row
        (cell as! ConnectOtherAppsCell).appSwitch.addTarget(self, action: #selector(appAuthorizedAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func appAuthorizedAction(sender:UISwitch) {
        switch sender.tag {
        case 0:
            break
        case 1:
            break
        case 2: break
        case 3: break
        default: break
            
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
    
}
