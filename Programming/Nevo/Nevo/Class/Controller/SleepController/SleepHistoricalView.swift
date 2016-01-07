//
//  QueryHistoricalView.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepHistoricalView: UIView, ChartViewDelegate{

    @IBOutlet var chartView:BarChartView?
    @IBOutlet weak var detailCollectionView: UICollectionView!
    private var queryModel:NSMutableArray = NSMutableArray()
    private let sleepArray:NSMutableArray = NSMutableArray();
    private var mDelegate:SelectedChartViewDelegate?

    func bulidQueryView(delegate:SelectedChartViewDelegate,modelArray:NSArray,navigation:UINavigationItem){
        mDelegate = delegate
        queryModel.addObjectsFromArray(modelArray as [AnyObject])
        
        navigation.title = NSLocalizedString("sleep_history_title", comment: "")

        // MARK: - chartView?.marker
        // TODO chartView?.marker =
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
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.BottomInside
        
        
        chartView!.legend.enabled = false;
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
        var xVal:[String] = [];
        var yVal:[BarChartDataEntry] = [];
        for (var i:Int = 0; i < queryModel.count; i++) {
            /**
            *  Data sorting,Small to large sort
            */
            for (var j:Int = i; j < queryModel.count; j++){
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
        
        for (var i:Int = 0; i < queryModel.count; i++){
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

            //因为涉及到跨天按照正常习惯一天的睡眠时间包括从睡觉到结束睡觉的这段时间都是前一天的睡眠时间(包括凌晨0点后到中午12点之间的数据)
            for (var s:Int  = 0; s < sleepTimerArray.count-6; s++){
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
                //计算在晚上六点以后的睡眠数据
                for (var s:Int  = 18; s < mSleepTimerArray.count; s++){
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
            let mDateString:String = String(format: "%.0f", seleModel.date)
            let date:NSDate = NSDate(timeIntervalSince1970: seleModel.date)
            //mDateString.dateFromFormat("yyyyMMdd")!
            let dateString:NSString = date.stringFromFormat("yyyyMMdd")
            //stringFromDate(date) as NSString
            xVal.append("\(dateString.substringWithRange(NSMakeRange(6, 2)))/\(dateString.substringWithRange(NSMakeRange(4, 2)))")

            yVal.append(BarChartDataEntry(values: [(val2+val3),val1], xIndex:sleepArray.count))
            sleepArray.addObject(Sleep(weakSleep: val3,lightSleep: val2,deepSleep: val1))
        }

        //According to at least seven days of data
        if(yVal.count<7){
            for (var s:Int  = yVal.count; s < 7; s++){
                xVal.append(" ")
                yVal.append(BarChartDataEntry(values: [0,0], xIndex:sleepArray.count))
                sleepArray.addObject(Sleep(weakSleep: 0,lightSleep: 0,deepSleep: 0))
            }
        }

        //柱状图表
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "")
        
        //每个数据区块的颜色
        set1.colors = [ChartColorTemplates.getLightSleepColor(),ChartColorTemplates.getDeepSleepColor()];
        //每个数据块的类别名称,数组形式传递
        set1.stackLabels = ["Deep sleep", "Light sleep"];
        set1.barSpace = 0.05;
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.highLightAlpha = 1
        let dataSets:[BarChartDataSet] = [set1];

        let data:BarChartData = BarChartData(xVals: xVal, dataSets: dataSets)
        data.setDrawValues(false);//false 显示柱状图数值否则不显示

        chartView?.data = data;
        chartView?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
        chartView?.moveViewToX(yVal.count)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {

        let sleep:Sleep = self.sleepArray.objectAtIndex(entry.xIndex) as! Sleep;
        chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)
        mDelegate?.didSleepSelectedhighlightValue!(entry.xIndex, dataSetIndex: dataSetIndex, dataSleep: sleep)
    }

}
