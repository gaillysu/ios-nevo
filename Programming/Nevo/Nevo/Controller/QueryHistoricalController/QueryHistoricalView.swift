//
//  QueryHistoricalView.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class QueryHistoricalView: UIView , ChartViewDelegate{

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var naBgView: UIView!
    @IBOutlet weak var querySegment: UISegmentedControl!
    @IBOutlet weak var queryTableview: UITableView!
    @IBOutlet var chartView:BarChartView?

    @IBOutlet weak var deepSleepLabel: UILabel!
    @IBOutlet weak var lightSleepLabel: UILabel!
    @IBOutlet weak var totalSleepLabel: UILabel!
    private var queryModel:NSMutableArray = NSMutableArray()
    private let sleepArray:NSMutableArray = NSMutableArray();
    
    func bulidQueryView(delegate:QueryHistoricalController,modelArray:NSArray){
        queryModel.addObjectsFromArray(modelArray as [AnyObject])
        
        chartView!.delegate = delegate;
        chartView!.descriptionText = " ";
        chartView?.noDataText = "No sleep tracking data"
        chartView!.noDataTextDescription = "";
        chartView!.pinchZoomEnabled = false
        chartView!.drawGridBackgroundEnabled = false;
        chartView!.drawBarShadowEnabled = false;
        let xScale:CGFloat = CGFloat(queryModel.count/7);
        chartView!.setScaleMinima(xScale, scaleY: 1)
        chartView!.setScaleEnabled(false);
        chartView!.drawValueAboveBarEnabled = true;
        chartView!.doubleTapToZoomEnabled = false;
        chartView!.setViewPortOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
        chartView!.delegate = self

        let leftAxis:ChartYAxis = chartView!.leftAxis;
        leftAxis.valueFormatter = NSNumberFormatter();
        leftAxis.drawAxisLineEnabled = false;
        leftAxis.drawGridLinesEnabled = false;
        leftAxis.enabled = false;
        leftAxis.spaceTop = 0.6;
        
        chartView!.rightAxis.enabled = false;

        let xAxis:ChartXAxis = chartView!.xAxis;
        xAxis.drawAxisLineEnabled = false;
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.BottomInside
        //        xAxis.labelTextColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0);
        
        
        chartView!.legend.enabled = false;
        self.slidersValueChanged()
    }

    func slidersValueChanged(){
        //[self setDataCount:(_sliderX.value + 1) range:_sliderY.value];
        self.setDataCount(queryModel.count, Range: 50)
    }

    
    func setDataCount(count:Int, Range range:Double){
        var xVal:[String] = [];
        var yVal:[BarChartDataEntry] = [];
        for (var i:Int = 0; i < queryModel.count; i++) {
            /**
            *  Data sorting,Small to large sort
            */
            for (var j:Int = i; j < queryModel.count; j++){
                let iSeleModel:DaySleepSaveModel = queryModel.objectAtIndex(i) as! DaySleepSaveModel;
                let jSeleModel:DaySleepSaveModel = queryModel.objectAtIndex(j) as! DaySleepSaveModel;
                let iSleepDate:Int = iSeleModel.created
                let jSleepDate:Int = jSeleModel.created
                if (iSleepDate > jSleepDate){
                    let temp:DaySleepSaveModel = queryModel.objectAtIndex(i) as! DaySleepSaveModel;
                    queryModel.replaceObjectAtIndex(i, withObject: queryModel[j])
                    queryModel.replaceObjectAtIndex(j, withObject: temp)

                }
            }
        }
        //计算睡眠时间以中午12点为计算起点,
        
        for (var i:Int = 0; i < queryModel.count; i++){
            let seleModel:DaySleepSaveModel = queryModel.objectAtIndex(i) as! DaySleepSaveModel;

            //当天的数据源(没有跨天的数据源)
            let sleepTimerArray:NSArray = AppTheme.jsonToArray(seleModel.HourlySleepTime as String)
            let wakeTimeTimerArray:NSArray = AppTheme.jsonToArray(seleModel.HourlyWakeTime as String)
            let lightTimeTimerArray:NSArray = AppTheme.jsonToArray(seleModel.HourlyLightTime as String)
            let deepTimeTimerArray:NSArray = AppTheme.jsonToArray(seleModel.HourlyDeepTime as String)

            var sleepTimer:Int  = 0
            var wakeTimer:Int  = 0
            var lightTimer:Int  = 0
            var deepTimer:Int  = 0

            //因为涉及到跨天按照正常习惯一天的睡眠时间包括从睡觉到结束睡觉的这段时间都是前一天的睡眠时间(包括凌晨0点后到中午12点之间的数据)
            for (var s:Int  = 12; s < sleepTimerArray.count; s++){
                //计算一天中后12小时的数据,
                sleepTimer = (sleepTimerArray[s] as! NSNumber).integerValue + sleepTimer
                wakeTimer = (wakeTimeTimerArray[s] as! NSNumber).integerValue + wakeTimer
                lightTimer = (lightTimeTimerArray[s] as! NSNumber).integerValue + lightTimer
                deepTimer = (deepTimeTimerArray[s] as! NSNumber).integerValue + deepTimer
            }

            //跨天的睡眠数据源
            if(i+1<queryModel.count){
                let nextSeleModel:DaySleepSaveModel = queryModel.objectAtIndex(i+1) as! DaySleepSaveModel;
                let mSleepTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.HourlySleepTime as String)
                let mWakeTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.HourlyWakeTime as String)
                let mLightTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.HourlyLightTime as String)
                let mDeepTimeTimerArray:NSArray = AppTheme.jsonToArray(nextSeleModel.HourlyDeepTime as String)
                for (var s:Int  = 0; s < mSleepTimerArray.count-12; s++){
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
            }else{
                let dateString:NSString = "\(seleModel.created)" as NSString
                xVal.append("\(dateString.substringWithRange(NSMakeRange(6, 2)))/\(dateString.substringWithRange(NSMakeRange(4, 2)))")
            }
            yVal.append(BarChartDataEntry(values: [val1,(val2+val3)], xIndex:i))
            sleepArray.addObject(Sleep(weakSleep: val3,lightSleep: val2,deepSleep: val1))
            //释放前一天的睡眠(必须，不然会循环引用)
            sleepTimer = 0
            wakeTimer = 0
            lightTimer = 0
            deepTimer = 0
        }
        
        //图标名称
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "")
        
        //每个数据区块的颜色
        set1.colors = [ChartColorTemplates.getDeepSleepColor(),ChartColorTemplates.getLightSleepColor()];
        //每个数据块的类别名称,数组形式传递
        set1.stackLabels = ["Deep sleep", "Light sleep"];
        set1.barSpace = 0.05;
        var dataSets:[BarChartDataSet] = [];
        dataSets.append(set1);

        let data:BarChartData = BarChartData(xVals: xVal, dataSets: dataSets)
        data.setDrawValues(false);

        chartView!.data = data;
    }

    func getQueryTableviewCell(indexPath:NSIndexPath,array:NSArray)->UITableViewCell {
        let endCellID:NSString = "queryCell"
        var endCell = queryTableview.dequeueReusableCellWithIdentifier(endCellID as String) as? queryTableviewCell
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("queryTableviewCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? queryTableviewCell;

        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!

    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
        let sleep:Sleep = self.sleepArray.objectAtIndex(entry.xIndex) as! Sleep;

        let totalSleepTuple = calculateMinutes(sleep.getTotalSleep());
        let lightSleepTuple = calculateMinutes(sleep.getLightSleep());
        let deepSleepTuple = calculateMinutes(sleep.getDeepSleep());
        self.totalSleepLabel.text = String(format: "Hours: %02d minutes: %02d", totalSleepTuple.hours,totalSleepTuple.minutes)
        self.lightSleepLabel.text = String(format: "Hours: %02d minutes: %02d", lightSleepTuple.hours,lightSleepTuple.minutes)
        self.deepSleepLabel.text = String(format: "Hours: %02d minutes: %02d", deepSleepTuple.hours,deepSleepTuple.minutes)
        
    }
    
    private func calculateMinutes(time:Double) -> (hours:Int,minutes:Int){
        return (Int(time),Int(60*(time%1)));
    }
}
