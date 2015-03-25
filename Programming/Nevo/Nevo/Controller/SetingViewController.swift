//
//  SetingViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetingViewController: UIViewController,ButtonManagerCallBack {

    @IBOutlet var setingView: SetingView!

    var sources:NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        setingView.buliudView(self)

        sources = ["Notifications"]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func controllManager(sender:AnyObject){
        if (sender.isEqual(setingView.backButton)){
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.textLabel?.textColor = UIColor.whiteColor()
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath){
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.textLabel?.textColor = UIColor.blackColor()
    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return sources.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SetingCell", forIndexPath: indexPath) as UITableViewCell
        endCell.selectedBackgroundView = UIImageView(image: UIImage(named:"selectedButton"))
        endCell.textLabel?.text = sources.objectAtIndex(indexPath.row) as? String
        //endCell.textLabel?.textColor = UIColor.whiteColor()
        return endCell
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
