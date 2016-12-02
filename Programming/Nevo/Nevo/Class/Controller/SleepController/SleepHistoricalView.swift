//
//  QueryHistoricalView.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

@objc protocol SelectedChartViewDelegate{
    @objc optional func didSelectedhighlightValue(_ xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps)
    @objc optional func didSleepSelectedhighlightValue(_ xIndex:Int,dataSetIndex: Int, dataSleep:Sleep)
}

class SleepHistoricalView: UIView, ChartViewDelegate{

    @IBOutlet var chartView:AnalysisStepsChartView?
    @IBOutlet weak var detailCollectionView: UICollectionView!
    fileprivate var queryModel:[MEDUserSleep] = []
    fileprivate var mDelegate:SelectedChartViewDelegate?
    fileprivate var totalNumber:Double = 0 //The unit is hour

    func bulidQueryView(_ delegate:SelectedChartViewDelegate,modelArray:[Any]){
        queryModel.removeAll()
        queryModel = modelArray as! [MEDUserSleep]
        if(mDelegate == nil) {
            mDelegate = delegate
            // MARK: - chartView?.marker
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                chartView?.backgroundColor = UIColor.getGreyColor()
                self.backgroundColor = UIColor.getGreyColor()
                detailCollectionView.backgroundColor = UIColor.getGreyColor()
            }else{
                chartView?.backgroundColor = UIColor.white
            }
            
            chartView?.drawSettings(chartView!.xAxis, yAxis: chartView!.leftAxis, rightAxis: chartView!.rightAxis)
        }
        chartView?.data = nil
        chartView?.reset()
        self.setDataCount(queryModel.count)
    }

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
            
            let sleepTimeArray = JSON(AppTheme.jsonToArray(seleModel.hourlySleepTime)).arrayValue
            let wakeTimeTimeArray = JSON(AppTheme.jsonToArray(seleModel.hourlySleepTime)).arrayValue
            let lightTimeTimeArray = JSON(AppTheme.jsonToArray(seleModel.hourlySleepTime)).arrayValue
            let deepTimeTimeArray = JSON(AppTheme.jsonToArray(seleModel.hourlySleepTime)).arrayValue

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
    
    func getTotalSleepNumber()->Double {
        return totalNumber;
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {

        //let sleep:Sleep = self.sleepArray.object(at: entry.xIndex) as! Sleep;
        //chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        //mDelegate?.didSleepSelectedhighlightValue!(entry.xIndex, dataSetIndex: dataSetIndex, dataSleep: sleep)
    }

}
