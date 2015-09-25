//
//  QueryHistoricalView.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class QueryHistoricalView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var naBgView: UIView!
    @IBOutlet weak var querySegment: UISegmentedControl!
    @IBOutlet weak var queryTableview: UITableView!
    @IBOutlet var chartView:BarChartView?

    private var queryModel:NSMutableArray = NSMutableArray()

    func bulidQueryView(delegate:QueryHistoricalController,modelArray:NSArray){
        queryModel.addObjectsFromArray(modelArray as [AnyObject])

        chartView!.delegate = delegate;
        chartView!.descriptionText = " ";
        chartView?.noDataText = "No sleep tracking data"
        chartView!.noDataTextDescription = " ";

        chartView!.maxVisibleValueCount = 60
        chartView!.pinchZoomEnabled = true//手势放大缩小效果
        chartView!.drawGridBackgroundEnabled = false;
        chartView!.drawBarShadowEnabled = false;
        chartView!.drawValueAboveBarEnabled = false;

        let leftAxis:ChartYAxis = chartView!.leftAxis;
        leftAxis.valueFormatter = NSNumberFormatter();
        leftAxis.valueFormatter!.maximumFractionDigits = 1;
        leftAxis.valueFormatter!.negativeSuffix = " h";
        leftAxis.valueFormatter!.positiveSuffix = " h";

        chartView!.rightAxis.enabled = false;

        let xAxis:ChartXAxis = chartView!.xAxis;
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Top;
        let l:ChartLegend  = chartView!.legend;
        l.position = ChartLegend.ChartLegendPosition.BelowChartRight;
        l.form = ChartLegend.ChartLegendForm.Square;
        l.formSize = 8.0;
        l.formToTextSpace = 4.0;
        l.xEntrySpace = 6.0;
        self.slidersValueChanged()
    }

    func slidersValueChanged(){

        //[self setDataCount:(_sliderX.value + 1) range:_sliderY.value];
        self.setDataCount(queryModel.count, Range: 50)
    }

    
    func setDataCount(count:Int, Range range:Double){
        var xVal:[String] = [];
        var yVal:[BarChartDataEntry] = [];
//        for(var i:Int = 0; i<queryModel.count; i++){
//            let seleModel:DaySleepSaveModel = queryModel.objectAtIndex(i) as! DaySleepSaveModel;
//            xVal.append(seleModel.sleepDate as! String)
//            var val1:Double  = seleModel.DailyDeepTime!.doubleValue/60;
//            var val2:Double  = seleModel.DailyLightTime!.doubleValue/60;
//            var val3:Double  = seleModel.DailyWakeTime!.doubleValue/60;
//            yVal.append(BarChartDataEntry(values: [val1,val2,val3], xIndex: i))
//        }
        for (var i:Int = 0; i < queryModel.count; i++) {
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
            xVal.append(("\(seleModel.created)" as NSString).substringWithRange(NSMakeRange(4, 4)))

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
            yVal.append(BarChartDataEntry(values: [val1,val2,val3], xIndex:i))

            //释放前一天的睡眠(必须，不然会循环引用)
            sleepTimer = 0
            wakeTimer = 0
            lightTimer = 0
            deepTimer = 0
        }

        //图标名称
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "Sleep tracking")
        //每个数据区块的颜色
        set1.colors = [ChartColorTemplates.vordiplom()[0],ChartColorTemplates.vordiplom()[1],ChartColorTemplates.vordiplom()[2]];
        //每个数据块的类别名称,数组形式传递
        set1.stackLabels = ["Deep sleep", "light sleep", "weak sleep"];

        var dataSets:[BarChartDataSet] = [];
        dataSets.append(set1);

        let formatter:NSNumberFormatter = NSNumberFormatter();
        formatter.maximumFractionDigits = 1;
        formatter.negativeSuffix = " h";
        formatter.positiveSuffix = " h";

        let data:BarChartData = BarChartData(xVals: xVal, dataSets: dataSets)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 7.0))
        data.setValueFormatter(formatter)
        chartView!.data = data;
    }

    func getQueryTableviewCell(indexPath:NSIndexPath,array:NSArray)->UITableViewCell {
        let endCellID:NSString = "queryCell"
        var endCell = queryTableview.dequeueReusableCellWithIdentifier(endCellID as String) as? queryTableviewCell
        let seleModel:DaySleepSaveModel = array.objectAtIndex(indexPath.row) as! DaySleepSaveModel;
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("queryTableviewCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? queryTableviewCell;

        }
        //endCell!.deepSleepTime.text = seleModel.HourlyDeepTime as? String
        //endCell!.sleepTime.text = seleModel.DailySleepTime as? String
        //endCell!.wakeTime.text = seleModel.DailyWakeTime as? String
        //endCell!.lightTime.text = seleModel.DailyLightTime as? String
        //endCell!.dailyDist.text = seleModel.DailyDist as? String
        //endCell!.dailyCalories.text = seleModel.DailyCalories as? String
        
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!

    }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
