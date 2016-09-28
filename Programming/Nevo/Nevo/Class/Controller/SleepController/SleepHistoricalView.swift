//
//  QueryHistoricalView.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import Charts

@objc protocol SelectedChartViewDelegate{
    @objc optional func didSelectedhighlightValue(_ xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps)
    @objc optional func didSleepSelectedhighlightValue(_ xIndex:Int,dataSetIndex: Int, dataSleep:Sleep)
}

class SleepHistoricalView: UIView, ChartViewDelegate{

    @IBOutlet var chartView:AnalysisStepsChartView?
    @IBOutlet weak var detailCollectionView: UICollectionView!
    fileprivate var queryModel:NSMutableArray = NSMutableArray()
    fileprivate let sleepArray:NSMutableArray = NSMutableArray();
    fileprivate var mDelegate:SelectedChartViewDelegate?
    fileprivate var totalNumber:Double = 0

    func bulidQueryView(_ delegate:SelectedChartViewDelegate,modelArray:NSArray){
        queryModel.removeAllObjects()
        sleepArray.removeAllObjects()
        queryModel.addObjects(from: modelArray as [AnyObject])
        if(mDelegate == nil) {
            mDelegate = delegate
            // MARK: - chartView?.marker
            chartView?.backgroundColor = UIColor.white
            chartView?.drawSettings(chartView!.xAxis, yAxis: chartView!.leftAxis, rightAxis: chartView!.rightAxis)
        }
        chartView?.data = nil
        chartView?.reset()
        self.setDataCount(queryModel.count)
    }

    func setDataCount(_ count:Int){
        if(count == 0) {
            for i:Int in 0..<2 {
                let seleModel:UserSleep = UserSleep()
                seleModel.date = Date.yesterday().beginningOfDay.timeIntervalSince1970+Double(i*86400)
                seleModel.hourlySleepTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                seleModel.hourlyWakeTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                seleModel.hourlyLightTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                seleModel.hourlyDeepTime = "[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]";
                queryModel.add(seleModel)
            }
        }
        
        var sleepEntry:[[String:[Double]]] = []
        for i:Int in 0 ..< queryModel.count {
            /**
            *  Data sorting,Small to large sort
            */
            for j:Int in i ..< queryModel.count {
                let iSeleModel:UserSleep = queryModel.object(at: i) as! UserSleep;
                let jSeleModel:UserSleep = queryModel.object(at: j) as! UserSleep;
                let iSleepDate:Double = iSeleModel.date
                let jSleepDate:Double = jSeleModel.date
                if (iSleepDate > jSleepDate){
                    let temp:UserSleep = queryModel.object(at: i) as! UserSleep;
                    queryModel.replaceObject(at: i, with: queryModel[j])
                    queryModel.replaceObject(at: j, with: temp)

                }
            }
        }
        
        //计算睡眠时间以中午12点为计算起点,
        for i:Int in 0 ..< queryModel.count {
            let seleModel:UserSleep = queryModel.object(at: i) as! UserSleep;
            //当天的数据源(没有跨天的数据源)
            let sleepTimeArray:NSArray = AppTheme.jsonToArray(seleModel.hourlySleepTime as String)
            let wakeTimeTimeArray:NSArray = AppTheme.jsonToArray(seleModel.hourlyWakeTime as String)
            let lightTimeTimeArray:NSArray = AppTheme.jsonToArray(seleModel.hourlyLightTime as String)
            let deepTimeTimeArray:NSArray = AppTheme.jsonToArray(seleModel.hourlyDeepTime as String)

            var sleepTimer:Int  = 0
            var wakeTimer:Int  = 0
            var lightTimer:Int  = 0
            var deepTimer:Int  = 0

            if(i == 0){
                //计算在晚上8点以后的睡眠数据
                for s:Int in 20 ..< sleepTimeArray.count {
                    sleepTimer = (sleepTimeArray[s] as! NSNumber).intValue + sleepTimer
                    wakeTimer = (wakeTimeTimeArray[s] as! NSNumber).intValue + wakeTimer
                    lightTimer = (lightTimeTimeArray[s] as! NSNumber).intValue + lightTimer
                    deepTimer = (deepTimeTimeArray[s] as! NSNumber).intValue + deepTimer
                    if (sleepTimeArray[s] as! NSNumber).int32Value > 0 {
                        sleepEntry.append(["\(s):00":[(wakeTimeTimeArray[s] as! NSNumber).doubleValue,(lightTimeTimeArray[s] as! NSNumber).doubleValue,(deepTimeTimeArray[s] as! NSNumber).doubleValue]])
                    }
                    
                }
            }else{
                for s:Int in 0 ..< sleepTimeArray.count-10 {
                    //计算一天中后12小时的数据,
                    sleepTimer = (sleepTimeArray[s] as! NSNumber).intValue + sleepTimer
                    wakeTimer = (wakeTimeTimeArray[s] as! NSNumber).intValue + wakeTimer
                    lightTimer = (lightTimeTimeArray[s] as! NSNumber).intValue + lightTimer
                    deepTimer = (deepTimeTimeArray[s] as! NSNumber).intValue + deepTimer
                    if (sleepTimeArray[s] as! NSNumber).int32Value > 0 {
                        sleepEntry.append(["\(s):00":[(wakeTimeTimeArray[s] as! NSNumber).doubleValue,(lightTimeTimeArray[s] as! NSNumber).doubleValue,(deepTimeTimeArray[s] as! NSNumber).doubleValue]])
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
        
        for value in sleepEntry{
            for (key,value2) in value {
                NSLog("value2:\(value2),\(key)")
                chartView!.addDataPoint(key, entry: value2)
            }
        }
        
        if sleepEntry.count == 0 {
            for i:Int in 0..<8 {
                NSLog("value2:\(0),\(i)")
                chartView!.addDataPoint("\(i):00", entry: [0,0,60])
            }
        }
        
        chartView!.invalidateChart()
    }
    
    func calculateDate(_ date:TimeInterval,hour:Int)->String {
        let date:Date = Date(timeIntervalSince1970: date)
        var dateString:NSString = date.stringFromFormat("yyyyMMdd") as NSString
        if(dateString.length < 8) {
            dateString = "00000000"
        }
        return "\(hour):00"
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {

        let sleep:Sleep = self.sleepArray.object(at: entry.xIndex) as! Sleep;
        chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        mDelegate?.didSleepSelectedhighlightValue!(entry.xIndex, dataSetIndex: dataSetIndex, dataSleep: sleep)
    }

}
