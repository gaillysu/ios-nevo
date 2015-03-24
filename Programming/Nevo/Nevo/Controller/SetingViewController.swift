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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setingView.buliudView(self)
        
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

    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 4
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SetingCell", forIndexPath: indexPath) as UITableViewCell

        //endCell.selectionStyle = UITableViewCellSelectionStyle.None
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
