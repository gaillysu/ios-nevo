//
//  QueryHistoricalController.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/14.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class QueryHistoricalController: UIViewController,UITableViewDataSource,UITableViewDelegate,ChartViewDelegate {

    @IBOutlet var queryView: QueryHistoricalView!

    private var queryArray:NSArray?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "QueryHistoricalController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.LandscapeRight, animated: false)
        //UIView.beginAnimations(nil, context: nil)
        //UIView.setAnimationDuration(2)
        //self.view.transform = CGAffineTransformIdentity
        //self.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*(90)/180.0));
        //self.view.bounds = CGRectMake(0, 0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width);
        //UIView.commitAnimations()

        self.view.backgroundColor = UIColor.whiteColor()
        let secondsPerDay:NSTimeInterval  = 24*7 * 60 * 60;
        let yesterday:NSDate  = NSDate(timeIntervalSinceNow: -secondsPerDay)

        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let currentDateStr:NSString = dateFormatter.stringFromDate(yesterday)
        //"2015825"
        queryArray = DaySleepSaveModel.findByCriteria(String(format: " WHERE created > %@ ",currentDateStr))
        //DaySleepSaveModel.findAll()
        //queryView.queryTableview.dataSource = self
        //queryView.queryTableview.delegate = self

        queryView.bulidQueryView(self,modelArray: queryArray!)

        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ButtonController(sender: AnyObject) {
        if(queryView.backButton.isEqual(sender)){
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
       
    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return queryArray!.count
        //return mNotificationSettingArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        return queryView.getQueryTableviewCell(indexPath, array: queryArray!)
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
