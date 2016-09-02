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
    private var contentTArray:[String] = [NSLocalizedString("24:00", comment: ""),NSLocalizedString("24:00", comment: ""),NSLocalizedString("24:00", comment: ""),NSLocalizedString("24:00", comment: "")]
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
        contentTitleArray = [NSLocalizedString("sleep_timer", comment: ""), NSLocalizedString("wake_timer", comment: ""), NSLocalizedString("Quality", comment: ""), NSLocalizedString("Duration", comment: "")]
        
        queryView.detailCollectionView.backgroundColor = UIColor.whiteColor()
        queryView.detailCollectionView.registerNib(UINib(nibName:"SleepHistoryViewCell",bundle: nil) , forCellWithReuseIdentifier: "SleepHistoryValue_Identifier")
        
        SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:NSDate = notification.userInfo!["selectedDate"] as! NSDate
            self.selectedDate = userinfo
            self.queryArray = UserSleep.getCriteria("WHERE date BETWEEN \(userinfo.timeIntervalSince1970-86400) AND \(userinfo.endOfDay.timeIntervalSince1970)")
            //self.queryView.bulidQueryView(self,modelArray: self.queryArray!)
        }
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            self.AnalysisSleepData()
        }

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
    }
    
    func AnalysisSleepData() {
        self.queryArray = UserSleep.getCriteria("WHERE date BETWEEN \(NSDate.yesterday().beginningOfDay.timeIntervalSince1970) AND \(selectedDate.endOfDay.timeIntervalSince1970)")
        queryView.bulidQueryView(self,modelArray: queryArray!)
        
        if queryView.chartView!.getYVals().count > 0 {
            var sleepTime:Double = 0
            var deepTime:Double = 0
            for (index,vlaue) in queryView.chartView!.getYVals().enumerate() {
                sleepTime += vlaue[0]+vlaue[1]+vlaue[2]
                deepTime += vlaue[2]
                if index == 0 {
                    let sleep:Double = 60-(vlaue[0]+vlaue[1]+vlaue[2])
                    var reString:String = queryView.chartView!.getXVals()[0]
                    let subRange = Range(reString.endIndex.advancedBy(-2)..<reString.endIndex)
                    if NSString(format:"\(Int(sleep))").length == 1 {
                        reString.replaceRange(subRange, with: "0\(Int(sleep))")
                    }else{
                        reString.replaceRange(subRange, with: "\(Int(sleep))")
                    }
                    contentTArray.replaceRange(Range(0..<1), with: [reString])
                }
                
                if index == queryView.chartView!.getYVals().count - 1 {
                    let endSleep:Double = vlaue[0]+vlaue[1]+vlaue[2]
                    var reString:String = queryView.chartView!.getXVals()[queryView.chartView!.getXVals().count-1]
                    let subRange = Range(reString.endIndex.advancedBy(-2)..<reString.endIndex)
                    
                    if NSString(format:"\(Int(endSleep))").length == 1 {
                        reString.replaceRange(subRange, with: "0\(Int(endSleep))")
                    }else{
                        reString.replaceRange(subRange, with: "\(Int(endSleep))")
                    }
                    contentTArray.replaceRange(Range(1..<2), with: [reString])
                }
            }
            let quality:String = "\(Int(deepTime/sleepTime*100))%"
            contentTArray.replaceRange(Range(2..<3), with: [quality])
            contentTArray.replaceRange(Range(3..<4), with: ["\(Int(sleepTime/60)) h"])
            self.queryView.detailCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        AnalysisSleepData()
    }

    override func viewDidLayoutSubviews() {
        (queryView.detailCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width/2.0, 40)
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
        
        contentTArray.insert("\(startString)", atIndex: 0)
        contentTArray.insert("\(endString)", atIndex: 1)
        contentTArray.insert(String(format: "%100"), atIndex: 2)
        contentTArray.insert(String(format: "%dh%dm", Int(dataSleep.getWeakSleep()),Int((dataSleep.getWeakSleep())*Double(60)%Double(60))), atIndex: 3)
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
        cell.titleLabel.text = contentTitleArray[indexPath.row].uppercaseString
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
