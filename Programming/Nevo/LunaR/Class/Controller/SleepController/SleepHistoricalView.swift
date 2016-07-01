//
//  QueryHistoricalView.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import Charts

class SleepHistoricalView: UIView, ChartViewDelegate{

    @IBOutlet var chartView:BarChartView?
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var nodataLabel: UILabel!
    private var queryModel:NSMutableArray = NSMutableArray()
    private let sleepArray:NSMutableArray = NSMutableArray();
    private var mDelegate:SelectedChartViewDelegate?
    private var totalNumber:Double = 0

    func bulidQueryView(delegate:SelectedChartViewDelegate,modelArray:NSArray,navigation:UINavigationItem){
        queryModel.removeAllObjects()
        sleepArray.removeAllObjects()
        queryModel.addObjectsFromArray(modelArray as [AnyObject])
        if(mDelegate == nil) {
            mDelegate = delegate
            navigation.title = NSLocalizedString("sleep_history_title", comment: "")
            // MARK: - chartView?.marker
            chartView?.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 25, Green: 31, Blue: 59)
            chartView?.descriptionText = " ";
            chartView?.noDataText = NSLocalizedString("no_sleep_data", comment: "")
            chartView?.noDataTextDescription = "";
            chartView?.pinchZoomEnabled = false
            chartView?.drawGridBackgroundEnabled = false;
            chartView?.drawBarShadowEnabled = false;
            let xScale:CGFloat = CGFloat(queryModel.count)/7.0;//integer/integer = integer,float/float = float
            chartView?.setScaleMinima(xScale, scaleY: 1)
            chartView?.setScaleEnabled(false);
            chartView?.drawValueAboveBarEnabled = true;
            chartView?.doubleTapToZoomEnabled = false;
            chartView?.setViewPortOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
            chartView?.delegate = self

            let leftAxis:ChartYAxis = chartView!.leftAxis;
            leftAxis.valueFormatter = NSNumberFormatter();
            leftAxis.drawAxisLineEnabled = false;
            leftAxis.drawGridLinesEnabled = false;
            leftAxis.enabled = false;
            leftAxis.spaceTop = 0.6;

            chartView!.rightAxis.enabled = false;

            let xAxis:ChartXAxis = chartView!.xAxis;
            xAxis.labelFont = UIFont.systemFontOfSize(8)
            xAxis.drawAxisLineEnabled = false;
            xAxis.drawGridLinesEnabled = false;
            xAxis.labelPosition = ChartXAxis.LabelPosition.BottomInside
            chartView!.legend.enabled = false;
        }
        self.slidersValueChanged()
    }

    func slidersValueChanged(){
        //[self setDataCount:(_sliderX.value + 1) range:_sliderY.value];
        self.setDataCount(queryModel.count, Range: 50)
    }

    func stringFromDate(date:NSDate) -> String {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
    }

    func setDataCount(count:Int, Range range:Double){
        if(count == 0) {
            return
        }
        var xVal:[String] = [];
        var yVal:[BarChartDataEntry] = [];
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
            //计算睡眠结束时间
            for (var s:Int = 13; s > 0; s -= 1){
                if((sleepTimerArray[s] as! NSNumber).integerValue != 0){
                    let date:NSTimeInterval = seleModel.date
                    let timer:Double = Double(((sleepTimerArray[s] as! NSNumber).integerValue)*60)
                    endTimer = NSTimeInterval(Double((s)*60*60)+timer) + date
                    break
                }
            }

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
            }

            if(i != 0){
                //跨天的睡眠数据源
                let nextSeleModel:UserSleep = queryModel.objectAtIndex(i-1) as! UserSleep;//取出前一天的数据
                let mSleepTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlySleepTime as String)
                let mWakeTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlyWakeTime as String)
                let mLightTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlyLightTime as String)
                let mDeepTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.hourlyDeepTime as String)

                //计算睡眠开始时间
                for s:Int in 20 ..< mSleepTimerArray.count {
                    if((mSleepTimerArray[s] as! NSNumber).integerValue != 0){
                        let date:NSTimeInterval = nextSeleModel.date + NSTimeInterval(Double(s*60*60)+Double((60-(mSleepTimerArray[s] as! NSNumber).integerValue)*60))
                        startTimer = date
                        break
                    }
                }
                //计算在晚上六点以后的睡眠数据
                for s:Int in 18 ..< mSleepTimerArray.count {
                    sleepTimer = (mSleepTimerArray[s] as! NSNumber).integerValue + sleepTimer
                    wakeTimer = (mWakeTimeTimerArray[s] as! NSNumber).integerValue + wakeTimer
                    lightTimer = (mLightTimeTimerArray[s] as! NSNumber).integerValue + lightTimer
                    deepTimer = (mDeepTimeTimerArray[s] as! NSNumber).integerValue + deepTimer
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
            
            let date:NSDate = NSDate(timeIntervalSince1970: seleModel.date)
            var dateString:NSString = date.stringFromFormat("yyyyMMdd")
            if(dateString.length < 8) {
                dateString = "00000000"
            }

            xVal.append("\(dateString.substringWithRange(NSMakeRange(6, 2)))/\(dateString.substringWithRange(NSMakeRange(4, 2)))")

            yVal.append(BarChartDataEntry(values: [val1,val2,val3], xIndex:sleepArray.count))
            sleepArray.addObject(Sleep(weakSleep: val3,lightSleep: val2,deepSleep: val1,startTimer:startTimer , endTimer:endTimer))
        }

        //According to at least seven days of data
        if(yVal.count<7){
            for s:Int in yVal.count ..< 7 {
                xVal.append(" ")
                yVal.append(BarChartDataEntry(values: [0,0,0], xIndex:sleepArray.count))
                sleepArray.addObject(Sleep(weakSleep: 0,lightSleep: 0,deepSleep: 0,startTimer:0 ,endTimer:0))
            }
        }

        //柱状图表
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "")
        
        //每个数据区块的颜色
        set1.colors = [AppTheme.getDeepSleepColor(),AppTheme.getLightSleepColor(),AppTheme.getWakeSleepColor()];
        //UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
        //每个数据块的类别名称,数组形式传递
        set1.stackLabels = ["Deep sleep","Light sleep","weak sleep"];
        set1.barSpace = 0.05;
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        let dataSets:[BarChartDataSet] = [set1];

        let data:BarChartData = BarChartData(xVals: xVal, dataSets: dataSets)
        data.setDrawValues(false);//false 显示柱状图数值否则不显示

        chartView?.data = data;
        chartView?.animate(yAxisDuration: 1.5, easingOption: ChartEasingOption.EaseInOutCirc)
        chartView?.moveViewToX(CGFloat(yVal.count))
        
        if totalNumber == 0 {
            chartView?.data = nil
        }
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {

        let sleep:Sleep = self.sleepArray.objectAtIndex(entry.xIndex) as! Sleep;
        chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        mDelegate?.didSleepSelectedhighlightValue!(entry.xIndex, dataSetIndex: dataSetIndex, dataSleep: sleep)
    }

}