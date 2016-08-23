//
//  QueryHistoricalController.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/14.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import Charts
import SwiftEventBus

class SleepHistoricalViewController: PublicClassController,ChartViewDelegate,SelectedChartViewDelegate {

    @IBOutlet var queryView: SleepHistoricalView!
    private var contentTitleArray:[String] = []
    private var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
    private var selectedDate:NSDate = NSDate()

    private var queryArray:NSArray?
    init() {
        super.init(nibName: "SleepHistoricalViewController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("sleep_history_title", comment: "")
        contentTitleArray = [NSLocalizedString("sleep_duration", comment: ""), NSLocalizedString("sleep_timer", comment: ""), NSLocalizedString("wake_timer", comment: ""), NSLocalizedString("deep_sleep", comment: ""), NSLocalizedString("light_sleep", comment: ""), NSLocalizedString("wake_duration", comment: "")]
        
        queryView.detailCollectionView.registerNib(UINib(nibName:"SleepHistoryViewCell",bundle: nil) , forCellWithReuseIdentifier: "SleepHistoryValue_Identifier")
        
        SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:NSDate = notification.userInfo!["selectedDate"] as! NSDate
            self.selectedDate = userinfo
            self.queryArray = UserSleep.getCriteria("WHERE date BETWEEN \(userinfo.timeIntervalSince1970-86400) AND \(userinfo.endOfDay.timeIntervalSince1970)")
            //self.queryView.bulidQueryView(self,modelArray: self.queryArray!)
        }

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.queryArray = UserSleep.getCriteria("WHERE date BETWEEN \(selectedDate.timeIntervalSince1970-86400) AND \(selectedDate.endOfDay.timeIntervalSince1970)")
        queryView.bulidQueryView(self,modelArray: queryArray!)

        if(queryArray?.count>0) {
            queryView.nodataLabel.hidden = true
        }else{
            //queryView.nodataLabel.backgroundColor = UIColor.getGreyColor()
            queryView.nodataLabel.hidden = false
            queryView.nodataLabel.text = NSLocalizedString("no_data", comment: "");
        }
    }

    override func viewDidLayoutSubviews() {
        (queryView.detailCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/3.0, queryView.detailCollectionView.frame.size.height/2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - SelectedChartViewDelegate
    func didSleepSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSleep:Sleep) {
        contentTArray.removeAll()
        let startTimer:NSDate = NSDate(timeIntervalSince1970: dataSleep.getStartTimer())
        let endTimer:NSDate = NSDate(timeIntervalSince1970: dataSleep.getEndTimer())
        let startString:String = startTimer.stringFromFormat("hh:mm a")
        let endString:String = endTimer.stringFromFormat("hh:mm a")

        contentTArray.insert(String(format: "%dh%dm", Int(dataSleep.getTotalSleep()),Int((dataSleep.getTotalSleep())*Double(60)%Double(60))), atIndex: 0)
        contentTArray.insert("\(startString)", atIndex: 1)
        contentTArray.insert("\(endString)", atIndex: 2)
        contentTArray.insert(String(format: "%dh%dm", Int(dataSleep.getDeepSleep()),Int((dataSleep.getDeepSleep())*Double(60)%Double(60))), atIndex: 3)
        contentTArray.insert(String(format: "%dh%dm", Int(dataSleep.getLightSleep()),Int((dataSleep.getLightSleep())*Double(60)%Double(60))), atIndex: 4)
        contentTArray.insert(String(format: "%dh%dm", Int(dataSleep.getWeakSleep()),Int((dataSleep.getWeakSleep())*Double(60)%Double(60))), atIndex: 5)
        queryView.detailCollectionView.reloadData()
    }

    private func calculateMinutes(time:Double) -> (hours:Int,minutes:Int){
        return (Int(time),Int(60*(time%1)));
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SleepHistoryViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("SleepHistoryValue_Identifier", forIndexPath: indexPath) as! SleepHistoryViewCell
        cell.titleLabel.text = contentTitleArray[indexPath.row]
        cell.valueLabel.text = "\(contentTArray[indexPath.row])"
        cell.backgroundColor = UIColor.whiteColor()
        return cell
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
