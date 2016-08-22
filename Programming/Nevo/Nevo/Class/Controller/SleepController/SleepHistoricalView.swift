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
    optional func didSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSteps:UserSteps)
    optional func didSleepSelectedhighlightValue(xIndex:Int,dataSetIndex: Int, dataSleep:Sleep)
}

class SleepHistoricalView: UIView, ChartViewDelegate{

    @IBOutlet var chartView:AnalysisStepsChartView?
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var nodataLabel: UILabel!
    private var queryModel:NSMutableArray = NSMutableArray()
    private let sleepArray:NSMutableArray = NSMutableArray();
    private var mDelegate:SelectedChartViewDelegate?
    private var totalNumber:Double = 0

    func bulidQueryView(delegate:SelectedChartViewDelegate,modelArray:NSArray){
        queryModel.removeAllObjects()
        sleepArray.removeAllObjects()
        queryModel.addObjectsFromArray(modelArray as [AnyObject])
        if(mDelegate == nil) {
            mDelegate = delegate
            // MARK: - chartView?.marker
            //chartView.addDataPoint("\(1)", entry: BarChartDataEntry(value: xVal, xIndex:i))
            chartView?.backgroundColor = UIColor.whiteColor()
            chartView?.drawSettings(chartView!.xAxis, yAxis: chartView!.leftAxis, rightAxis: chartView!.rightAxis)
        }
        chartView?.reset()
        self.setDataCount(queryModel.count)
    }

    func setDataCount(count:Int){
        if(count == 0) {
            return
        }

        for i:Int in 0 ..< queryModel.count {
            /**
            *  Data sorting,Small to large sort
            */
            for j:Int in i ..< queryModel.count {
                let iSeleModel:UserSleep = queryModel.objectAtIndex(i) as! UserSleep;
                let jSeleModel:UserSleep = queryModel.objectAtIndex(j) as! UserSleep;
                let iSleepDate:Double = iSeleModel.date
                let jSleepDate:Double = jSeleModel.date
                if (iSleepDate > jSleepDate){
                    let temp:UserSleep = queryModel.objectAtIndex(i) as! UserSleep;
                    queryModel.replaceObjectAtIndex(i, withObject: queryModel[j])
                    queryModel.replaceObjectAtIndex(j, withObject: temp)

                }
            }
        }
        
        //计算睡眠时间以中午12点为计算起点,
        for i:Int in 0 ..< queryModel.count {
            let seleModel:UserSleep = queryModel.objectAtIndex(i) as! UserSleep;
            //当天的数据源(没有跨天的数据源)
            let sleepTimerArray:NSArray = AppTheme.jsonToArray(seleModel.hourlySleepTime as String)
            let wakeTimeTimerArray:NSArray = AppTheme.jsonToArray(seleModel.hourlyWakeTime as String)
            let lightTimeTimerArray:NSArray = AppTheme.jsonToArray(seleModel.hourlyLightTime as String)
            let deepTimeTimerArray:NSArray = AppTheme.jsonToArray(seleModel.hourlyDeepTime as String)

            var sleepTimer:Int  = 0
            var wakeTimer:Int  = 0
            var lightTimer:Int  = 0
            var deepTimer:Int  = 0
            var startTimer:NSTimeInterval = 0
            var endTimer:NSTimeInterval = 0

            //因为涉及到跨天按照正常习惯一天的睡眠时间包括从睡觉到结束睡觉的这段时间都是前一天的睡眠时间(包括凌晨0点后到中午12点之间的数据)
            //计算睡眠结束时间,完成计算跳出循环
            for (var s:Int = 13; s > 0; s -= 1){
                if((sleepTimerArray[s] as! NSNumber).integerValue != 0){
                    let date:NSTimeInterval = seleModel.date
                    let timer:Double = Double(((sleepTimerArray[s] as! NSNumber).integerValue)*60)
                    endTimer = NSTimeInterval(Double((s)*60*60)+timer) + date
                    break
                }
            }

            //计算睡眠开始于凌晨以后的睡眠开始时间,完成计算跳出循环
            for s:Int in 0 ..< sleepTimerArray.count-6 {
                if((sleepTimerArray[s] as! NSNumber).integerValue != 0){
                    let date:NSTimeInterval = seleModel.date + NSTimeInterval(Double(s*60*60)+Double((60-(sleepTimerArray[s] as! NSNumber).integerValue)*60))
                    startTimer = date
                    break
                }
            }

            for s:Int in 0 ..< sleepTimerArray.count-6 {
                //计算一天中后12小时的数据,
                sleepTimer = (sleepTimerArray[s] as! NSNumber).integerValue + sleepTimer
                wakeTimer = (wakeTimeTimerArray[s] as! NSNumber).integerValue + wakeTimer
                lightTimer = (lightTimeTimerArray[s] as! NSNumber).integerValue + lightTimer
                deepTimer = (deepTimeTimerArray[s] as! NSNumber).integerValue + deepTimer
                if (sleepTimerArray[s] as! NSNumber).integerValue > 0 {
                    self.chartView!.addDataPoint(self.calculateDate(seleModel.date,hour:s), entry: [(sleepTimerArray[s] as! NSNumber).doubleValue,(lightTimeTimerArray[s] as! NSNumber).doubleValue,(deepTimeTimerArray[s] as! NSNumber).doubleValue])
                }
            }

            if(i != 0){
                //跨天的睡眠数据源,反向法
                let nextSeleModel:UserSleep = queryModel.objectAtIndex(i-1) as! UserSleep;//取出前一天的数据
                let mSleepTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlySleepTime as String)
                let mWakeTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlyWakeTime as String)
                let mLightTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlyLightTime as String)
                let mDeepTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlyDeepTime as String)

                //计算凌晨以前的睡眠开始时间,完成计算跳出循环
                for s:Int in 20 ..< mSleepTimerArray.count {
                    if((mSleepTimerArray[s] as! NSNumber).integerValue != 0){
                        let date:NSTimeInterval = nextSeleModel.date + NSTimeInterval(Double(s*60*60)+Double((60-(mSleepTimerArray[s] as! NSNumber).integerValue)*60))
                        startTimer = date
                        break
                    }
                }
                //计算在晚上8点以后的睡眠数据
                for s:Int in 20 ..< mSleepTimerArray.count {
                    sleepTimer = (mSleepTimerArray[s] as! NSNumber).integerValue + sleepTimer
                    wakeTimer = (mWakeTimeTimerArray[s] as! NSNumber).integerValue + wakeTimer
                    lightTimer = (mLightTimeTimerArray[s] as! NSNumber).integerValue + lightTimer
                    deepTimer = (mDeepTimeTimerArray[s] as! NSNumber).integerValue + deepTimer
                    
                    chartView!.addDataPoint(calculateDate(seleModel.date,hour:s), entry: [(mSleepTimerArray[s] as! NSNumber).doubleValue,(mLightTimeTimerArray[s] as! NSNumber).doubleValue,(mDeepTimeTimerArray[s] as! NSNumber).doubleValue])
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
        
        chartView!.invalidateChart()
        
        if totalNumber == 0 {
            chartView?.data = nil
        }
    }
    
    func calculateDate(date:NSTimeInterval,hour:Int)->String {
        let date:NSDate = NSDate(timeIntervalSince1970: date)
        var dateString:NSString = date.stringFromFormat("yyyyMMdd")
        if(dateString.length < 8) {
            dateString = "00000000"
        }
        return "\(hour):00"
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {

        let sleep:Sleep = self.sleepArray.objectAtIndex(entry.xIndex) as! Sleep;
        chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        mDelegate?.didSleepSelectedhighlightValue!(entry.xIndex, dataSetIndex: dataSetIndex, dataSleep: sleep)
    }

}
