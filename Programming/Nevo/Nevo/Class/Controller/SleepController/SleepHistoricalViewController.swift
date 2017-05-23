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
import SwiftyJSON

class SleepHistoricalViewController: PublicClassController {

    @IBOutlet var chartView:AnalysisStepsChartView?
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var contentTitleArray:[String] = []
    fileprivate var contentTArray:[String] = ["0","0","0","0"]
    fileprivate var selectedDate:Date = Date()
    fileprivate var queryModel:[MEDUserSleep] = []
    fileprivate var totalNumber:Double = 0 //The unit is hour

    fileprivate var todaySleepArray:[Any] = MEDUserSleep.getFilter("date < \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND date > \(Date().endOfDay.timeIntervalSince1970)")
    init() {
        super.init(nibName: "SleepHistoricalViewController", bundle: Bundle.main)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("sleep_history_title", comment: "")
        contentTitleArray = [NSLocalizedString("sleep_timer", comment: ""), NSLocalizedString("wake_timer", comment: ""), NSLocalizedString("Quality", comment: ""), NSLocalizedString("Duration", comment: "")]
        
        detailCollectionView.backgroundColor = UIColor.white
        detailCollectionView.register(UINib(nibName:"SleepHistoryViewCell",bundle: nil) , forCellWithReuseIdentifier: "SleepHistoryValue_Identifier")
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 0, height: 0)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        detailCollectionView.collectionViewLayout = layout
        
       
        chartView?.backgroundColor = UIColor.white
        chartView?.drawSettings(chartView!.xAxis, yAxis: chartView!.leftAxis, rightAxis: chartView!.rightAxis)
        chartView?.data = nil
        chartView?.reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        todaySleepArray = MEDUserSleep.getFilter("date >= \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND date <= \(Date().endOfDay.timeIntervalSince1970)")
        AnalysisSleepData(todaySleepArray)
        
        _ = SwiftEventBus.onMainThread(self, name: SELECTED_CALENDAR_NOTIFICATION) { (notification) in
            let userinfo:Date = notification.userInfo!["selectedDate"] as! Date
            self.selectedDate = userinfo as Date
            let selectedSleepArray = MEDUserSleep.getFilter("date >= \(userinfo.timeIntervalSince1970-86400) AND date <= \(userinfo.endOfDay.timeIntervalSince1970)")
            self.AnalysisSleepData(selectedSleepArray)
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            let syncArray:[Any] = MEDUserSleep.getFilter("date >= \(Date.yesterday().beginningOfDay.timeIntervalSince1970) AND date <=\(Date().endOfDay.timeIntervalSince1970)")
            self.AnalysisSleepData(syncArray)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let layout:UICollectionViewFlowLayout = detailCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: detailCollectionView.frame.size.width/2.0, height: detailCollectionView.frame.size.height/2.0 - 10)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self, name: SELECTED_CALENDAR_NOTIFICATION)
        SwiftEventBus.unregister(self, name: EVENT_BUS_END_BIG_SYNCACTIVITY)
    }
    
    func AnalysisSleepData(_ array:[Any]) {
        queryModel.removeAll()
        queryModel = array as! [MEDUserSleep]
        self.setDataCount(queryModel.count)
        
        if chartView!.getYVals().count > 0 {
            var sleepTime:Double = 0
            var deepTime:Double = 0
            for (index,vlaue) in chartView!.getYVals().enumerated() {
                sleepTime += vlaue[0]+vlaue[1]+vlaue[2]
                deepTime += vlaue[2]
                if index == 0 {
                    let sleep:Double = 60-(vlaue[0]+vlaue[1]+vlaue[2])
                    var reString:String = chartView!.getXVals()[0]
                    let subRange = Range(reString.characters.index(reString.endIndex, offsetBy: -2)..<reString.endIndex)
                    if NSString(format:"\(Int(sleep))" as NSString).length == 1 {
                        reString.replaceSubrange(subRange, with: "0\(Int(sleep))")
                    }else{
                        if sleep<60 {
                            reString.replaceSubrange(subRange, with: "\(Int(sleep))")
                        }else{
                            let timerArray:[String] = reString.components(separatedBy: ":")
                            let hour = timerArray[0].toInt()
                            reString = "\(hour):00"
                        }
                    }
                    contentTArray.replaceSubrange(Range(0..<1), with: [reString])
                }
                
                if index == chartView!.getYVals().count - 1 {
                    let endSleep:Double = vlaue[0]+vlaue[1]+vlaue[2]

                    var reString:String = chartView!.getXVals()[chartView!.getXVals().count-1]
                    let subRange = Range(reString.characters.index(reString.endIndex, offsetBy: -2)..<reString.endIndex)
                    
                    let endSleepString:String = String(format: "%.0f", endSleep)
                    if endSleepString.length() == 1 {
                        reString.replaceSubrange(subRange, with: "0\(Int(endSleep))")
                    }else{
                        if endSleep<60 {
                            reString.replaceSubrange(subRange, with: "\(Int(endSleep))")
                        }else{
                            let timerArray:[String] = reString.components(separatedBy: ":")
                            let hour = timerArray[0].toInt()+1
                            reString = "\(hour):00"
                        }
                    }
                    if getTotalSleepNumber() == 0 {
                        contentTArray.replaceSubrange(Range(1..<2), with: ["0"])
                    }else{
                        contentTArray.replaceSubrange(Range(1..<2), with: [reString])
                    }
                }
            }
            
            let sleepValue:Double = getTotalSleepNumber()
            let isNan = (deepTime/sleepTime).isNaN
            var quality:String = "\(isNan ? 0:Int(deepTime/sleepTime*100))%"
            if sleepValue == 0 {
                quality = "0%"
            }
            
            contentTArray.replaceSubrange(Range(2..<3), with: [quality])
            contentTArray.replaceSubrange(Range(3..<4), with: [sleepValue.timerFormatValue()])
            detailCollectionView.reloadData()
        }
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
        
        cell.backgroundColor = UIColor.white
        return cell
    }
}

extension SleepHistoricalViewController:ChartViewDelegate {
    func setDataCount(_ count:Int){
        totalNumber = 0
        
        if(count == 0) {
            for i:Int in 0..<2 {
                let seleModel:MEDUserSleep = MEDUserSleep()
                seleModel.date = Date.yesterday().beginningOfDay.timeIntervalSince1970+Double(i*86400)
                seleModel.hourlySleepTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                seleModel.hourlyWakeTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                seleModel.hourlyLightTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                seleModel.hourlyDeepTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                queryModel.append(seleModel)
            }
        }
        
        var sleepEntry:[[String:[Double]]] = []
        /**
         *  Data sorting,Small to large sort
         */
        queryModel = queryModel.sorted(by: {$0.date < $1.date})
        
        //计算睡眠时间以中午12点为计算起点,
        for i:Int in 0 ..< queryModel.count {
            let seleModel:MEDUserSleep = queryModel[i]
            //当天的数据源(没有跨天的数据源)
            
            let sleepTimeArray = JSON(seleModel.hourlySleepTime.jsonToArray()).arrayValue
            let wakeTimeTimeArray = JSON(seleModel.hourlyWakeTime.jsonToArray()).arrayValue
            let lightTimeTimeArray = JSON(seleModel.hourlyLightTime.jsonToArray()).arrayValue
            let deepTimeTimeArray = JSON(seleModel.hourlyDeepTime.jsonToArray()).arrayValue
            
            var sleepTimer:Int  = 0
            var wakeTimer:Int  = 0
            var lightTimer:Int  = 0
            var deepTimer:Int  = 0
            
            if(i == 0){
                //计算在晚上8点以后的睡眠数据
                for s:Int in 20 ..< sleepTimeArray.count {
                    sleepTimer = sleepTimeArray[s].intValue + sleepTimer
                    wakeTimer = wakeTimeTimeArray[s].intValue + wakeTimer
                    lightTimer = lightTimeTimeArray[s].intValue + lightTimer
                    deepTimer = deepTimeTimeArray[s].intValue + deepTimer
                    if sleepTimeArray[s].int32Value > 0 {
                        sleepEntry.append(["\(s):00":[wakeTimeTimeArray[s].doubleValue,lightTimeTimeArray[s].doubleValue,deepTimeTimeArray[s].doubleValue]])
                    }
                    
                }
            }else{
                for s:Int in 0 ..< sleepTimeArray.count-10 {
                    //计算一天中后12小时的数据,
                    sleepTimer = sleepTimeArray[s].intValue + sleepTimer
                    wakeTimer = wakeTimeTimeArray[s].intValue + wakeTimer
                    lightTimer = lightTimeTimeArray[s].intValue + lightTimer
                    deepTimer = deepTimeTimeArray[s].intValue + deepTimer
                    if sleepTimeArray[s].int32Value > 0 {
                        sleepEntry.append(["\(s):00":[wakeTimeTimeArray[s].doubleValue,lightTimeTimeArray[s].doubleValue,deepTimeTimeArray[s].doubleValue]])
                    }
                }
            }
            
            //获取源数据睡眠时间单位是分钟,转换成小时为单位给画图数据源
            let val1:Double  = Double(deepTimer)/60;//深睡画图数据源
            let val2:Double  = Double(lightTimer)/60;//浅睡画图数据源
            let val3:Double  = Double(wakeTimer)/60;//醒来画图数据源
            if(val1+val2+val3 == 0){
                continue
            }
            
            //Calculate the total sleep time
            totalNumber += val1+val2+val3
        }
        
        if sleepEntry.count != 0{
            for index in sleepEntry.count..<sleepEntry.count+1 {
                sleepEntry.append(["\(index):00":[0,0,0]])
            }
            
            for value in sleepEntry{
                for (key,value2) in value {
                    NSLog("value2:\(value2),\(key)")
                    chartView!.addDataPoint(key, entry: value2)
                }
            }
        }else{
            for i:Int in 0..<8 {
                NSLog("value2:\(0),\(i)")
                chartView!.addDataPoint("\(i):00", entry: [60,0,0])
            }
        }
        
        chartView!.invalidateChart()
    }
    
    func getTotalSleepNumber()->Double {
        return totalNumber;
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        
    }
}
