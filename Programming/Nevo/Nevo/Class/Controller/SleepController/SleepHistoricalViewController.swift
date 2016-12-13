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

    @IBOutlet weak var queryView: SleepHistoricalView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var contentTitleArray:[String] = []
    fileprivate var contentTArray:[String] = ["0","0","0","0"]
    fileprivate var selectedDate:Date = Date()

    fileprivate var todaySleepArray:[Any] = MEDUserSleep.getFilter("date < \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND date > \(Date().endOfDay.timeIntervalSince1970)")
        //UserSleep.getCriteria("WHERE date BETWEEN \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND \(Date().endOfDay.timeIntervalSince1970)")
    init() {
        super.init(nibName: "SleepHistoricalViewController", bundle: Bundle.main)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            titleLabel.textColor = UIColor.white
        }
        
        self.navigationItem.title = NSLocalizedString("sleep_history_title", comment: "")
        contentTitleArray = [NSLocalizedString("sleep_timer", comment: ""), NSLocalizedString("wake_timer", comment: ""), NSLocalizedString("Quality", comment: ""), NSLocalizedString("Duration", comment: "")]
        
        queryView.detailCollectionView.backgroundColor = UIColor.white
        queryView.detailCollectionView.register(UINib(nibName:"SleepHistoryViewCell",bundle: nil) , forCellWithReuseIdentifier: "SleepHistoryValue_Identifier")
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 0, height: 0)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        queryView.detailCollectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        todaySleepArray = MEDUserSleep.getFilter("date < \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND date > \(Date().endOfDay.timeIntervalSince1970)")
            //UserSleep.getCriteria("WHERE date BETWEEN \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND \(Date().endOfDay.timeIntervalSince1970)")
        AnalysisSleepData(todaySleepArray)
        
        _ = SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:Date = notification.userInfo!["selectedDate"] as! Date
            self.selectedDate = userinfo as Date
            let selectedSleepArray = MEDUserSleep.getFilter("date < \(userinfo.timeIntervalSince1970-86400) AND date > \(userinfo.endOfDay.timeIntervalSince1970)")
                //UserSleep.getCriteria("WHERE date BETWEEN \(userinfo.timeIntervalSince1970-86400) AND \(userinfo.endOfDay.timeIntervalSince1970)")
            self.AnalysisSleepData(selectedSleepArray)
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            let syncArray:[Any] = MEDUserSleep.getFilter("date < \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND date > \(Date().endOfDay.timeIntervalSince1970)")
            self.AnalysisSleepData(syncArray)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let layout:UICollectionViewFlowLayout = queryView.detailCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: queryView.detailCollectionView.frame.size.width/2.0, height: queryView.detailCollectionView.frame.size.height/2.0 - 10)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY)
    }
    
    func AnalysisSleepData(_ array:[Any]) {
        queryView.bulidQueryView(self,modelArray: array)
        
        if queryView.chartView!.getYVals().count > 0 {
            var sleepTime:Double = 0
            var deepTime:Double = 0
            for (index,vlaue) in queryView.chartView!.getYVals().enumerated() {
                sleepTime += vlaue[0]+vlaue[1]+vlaue[2]
                deepTime += vlaue[2]
                if index == 0 {
                    let sleep:Double = 60-(vlaue[0]+vlaue[1]+vlaue[2])
                    var reString:String = queryView.chartView!.getXVals()[0]
                    let subRange = Range(reString.characters.index(reString.endIndex, offsetBy: -2)..<reString.endIndex)
                    if NSString(format:"\(Int(sleep))" as NSString).length == 1 {
                        reString.replaceSubrange(subRange, with: "0\(Int(sleep))")
                    }else{
                        reString.replaceSubrange(subRange, with: "\(Int(sleep))")
                    }
                    contentTArray.replaceSubrange(Range(0..<1), with: [reString])
                }
                
                if index == queryView.chartView!.getYVals().count - 1 {
                    let endSleep:Double = vlaue[0]+vlaue[1]+vlaue[2]

                    var reString:String = queryView.chartView!.getXVals()[queryView.chartView!.getXVals().count-1]
                    let subRange = Range(reString.characters.index(reString.endIndex, offsetBy: -2)..<reString.endIndex)
                    
                    if NSString(format:"\(Int(endSleep))" as NSString).length == 1 {
                        reString.replaceSubrange(subRange, with: "0\(Int(endSleep))")
                    }else{
                        reString.replaceSubrange(subRange, with: "\(Int(endSleep))")
                    }
                    if queryView.getTotalSleepNumber() == 0 {
                        contentTArray.replaceSubrange(Range(1..<2), with: ["0"])
                    }else{
                        contentTArray.replaceSubrange(Range(1..<2), with: [reString])
                    }
                    
                }
            }
            
            let sleepValue:Double = queryView.getTotalSleepNumber()
            let isNan = (deepTime/sleepTime).isNaN
            var quality:String = "\(isNan ? 0:Int(deepTime/sleepTime*100))%"
            if sleepValue == 0 {
                quality = "0%"
            }
            
            contentTArray.replaceSubrange(Range(2..<3), with: [quality])
            contentTArray.replaceSubrange(Range(3..<4), with: [AppTheme.timerFormatValue(value: sleepValue)])
            self.queryView.detailCollectionView.reloadData()
        }
    }

    
    // MARK: - SelectedChartViewDelegate
    func didSleepSelectedhighlightValue(_ xIndex:Int,dataSetIndex: Int, dataSleep:Sleep) {
        contentTArray.removeAll()
        let startTimer:Date = Date(timeIntervalSince1970: dataSleep.getStartTimer())
        let endTimer:Date = Date(timeIntervalSince1970: dataSleep.getEndTimer())
        let startString:String = startTimer.stringFromFormat("hh:mm a")
        let endString:String = endTimer.stringFromFormat("hh:mm a")
        
        contentTArray.insert("\(startString)", at: 0)
        contentTArray.insert("\(endString)", at: 1)
        contentTArray.insert(String(format: "%100"), at: 2)
        contentTArray.insert(String(format: "%dh%dm", Int(dataSleep.getWeakSleep()),Int(((dataSleep.getWeakSleep())*Double(60)).truncatingRemainder(dividingBy: Double(60)))), at: 3)
        queryView.detailCollectionView.reloadData()
    }

    fileprivate func calculateMinutes(_ time:Double) -> (hours:Int,minutes:Int){
        return (Int(time),Int(60*(time.truncatingRemainder(dividingBy: 1))));
    }

}

extension SleepHistoricalViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:SleepHistoryViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SleepHistoryValue_Identifier", for: indexPath) as! SleepHistoryViewCell
        cell.updateTitleLabel(contentTitleArray[indexPath.row])
        cell.valueLabel.text = "\(contentTArray[indexPath.row])"
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            cell.backgroundColor = UIColor.getGreyColor()
            cell.valueLabel.textColor = UIColor.getBaseColor()
            cell.titleLabel.textColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
}
