//
//  AnalysisLineChartCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/9.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Charts
import Timepiece

class AnalysisLineChartCell: UICollectionViewCell,ChartViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    private var sortArray:NSMutableArray = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initChartView()
    }

    private func initChartView() {
        lineChartView.delegate = self;
        
        lineChartView.descriptionText = "";
        lineChartView.noDataTextDescription = "You need to provide data for the chart.";
        
        lineChartView.dragEnabled = false;
        lineChartView.setScaleEnabled(false)
        lineChartView.pinchZoomEnabled = false;
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.enabled = true
        lineChartView.drawGridBackgroundEnabled = false;
        
        let leftAxis:ChartYAxis = lineChartView.leftAxis;
        leftAxis.axisMaxValue = 9000.0;
        leftAxis.axisMinValue = 0.0;
        leftAxis.gridLineDashLengths = [0.0, 0.0];
        leftAxis.labelTextColor = UIColor.blackColor()
        //leftAxis.axisLineColor = UIColor.whiteColor()
        //leftAxis.gridColor = UIColor.whiteColor()
        leftAxis.drawZeroLineEnabled = true;
        leftAxis.drawLimitLinesBehindDataEnabled = true;
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawLabelsEnabled = true
        lineChartView.rightAxis.enabled = false;
        
        let xAxis:ChartXAxis = lineChartView.xAxis
        xAxis.labelTextColor = UIColor.blackColor();
        xAxis.axisLineColor = AppTheme.NEVO_SOLAR_GRAY()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFontOfSize(12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.minimumSize = CGSizeMake(80.0, 40.0);
        //lineChartView.marker = marker;
        
        lineChartView.legend.form = ChartLegend.Form.Line
        lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutQuart)
    }
    
    func setTitle(title:String) {
        titleLabel.text = title
    }
    
    func setContentValue(title:String) {
        titleLabel.text = title
    }
    
    func updateChartData(dataArray:NSArray,chartType:Int,rowIndex:Int,completionData:((totalValue:Float,totalCalores:Int,totalTime:Int) -> Void)) {
        lineChartView.data = nil
        switch chartType {
        case 0:
            var totalSteps:Int = 0
            var totalCalores:Int = 0
            var totalTime:Int = 0
            for value in dataArray {
                let usersteps:UserSteps = value as! UserSteps
                totalSteps += usersteps.steps
                totalCalores += Int(usersteps.calories)
                totalTime += (usersteps.walking_duration+usersteps.running_duration)
            }
            completionData(totalValue: Float(totalSteps), totalCalores: totalCalores, totalTime: totalTime)
            self.setStepsDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 1:
            var totalValue:Int = 0
            for value in dataArray {
                let usersteps:UserSleep = value as! UserSleep
                let sleepTime:[Int] = AppTheme.jsonToArray(usersteps.hourlySleepTime) as! [Int]
                for value2 in sleepTime {
                    totalValue+=value2
                }
            }
            completionData(totalValue: Float(totalValue)/60.0, totalCalores: 0, totalTime: 0)
            self.setSleepDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 2:
            //self.setStepsDataCount(dataArray, type: chartType,rowIndex:rowIndex)
            self.setSloarDataCount(7, range: 50)
        default: break
        }
    }
    
    func setStepsDataCount(countArray:NSArray,type:Int,rowIndex:Int) {
        var xVals:[String] = []
        var yVals:[ChartDataEntry] = []
        sortArray.removeAllObjects()
        sortArray.addObjectsFromArray(countArray as [AnyObject])
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSteps:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                let jSteps:UserSteps = sortArray.objectAtIndex(j) as! UserSteps;
                let iStepsDate:Double = iSteps.date
                let jStepsDate:Double = jSteps.date
                let iStepsValue:Int = iSteps.steps
                
                //Calculate the maximum
                if iStepsValue>maxValue {
                    maxValue = iStepsValue
                }
                //Time has sorted
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                    sortArray.replaceObjectAtIndex(i, withObject: sortArray[j])
                    sortArray.replaceObjectAtIndex(j, withObject: temp)
                }
            }
            //chart the maximum
            if i == countArray.count-1 {
                let leftAxis:ChartYAxis = lineChartView.leftAxis;
                leftAxis.axisMaxValue = Double(maxValue);
                leftAxis.axisMinValue = 0.0;
                leftAxis.gridLineDashLengths = [0.0, 0.0];
                leftAxis.labelTextColor = UIColor.blackColor()

                leftAxis.valueFormatter = NSNumberFormatter();
                leftAxis.valueFormatter!.maximumFractionDigits = 1;
                leftAxis.valueFormatter!.negativeSuffix = "";
                leftAxis.valueFormatter!.positiveSuffix = "";
                leftAxis.labelPosition = ChartYAxis.LabelPosition.OutsideChart
                leftAxis.spaceTop = 0.15;
            }
        }
        
        for i:Int in 0..<sortArray.count {
            let usersteps:UserSteps = sortArray[i] as! UserSteps
            let date:NSDate = "\(usersteps.createDate)".dateFromFormat("yyyyMMdd")!
            let dateString:String = date.stringFromFormat("dd/MM")
            let stepsArray = AppTheme.jsonToArray(usersteps.hourlysteps)
            var steps:Double = 0
            for value in stepsArray {
                steps += Double((value as! NSNumber).doubleValue)
            }
            NSLog("steps:\(steps)")
            yVals.append(ChartDataEntry(value: steps, xIndex: i))
            xVals.append(dateString)
        }
        
        var set1:LineChartDataSet?
        set1 = LineChartDataSet(yVals: yVals, label: "")
        set1?.lineDashLengths = [0.0, 0];
        set1?.highlightLineDashLengths = [0.0, 0.0];
        set1?.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1?.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1?.valueTextColor = UIColor.blackColor()
        set1?.lineWidth = 1.0;
        set1?.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1?.drawValuesEnabled = false
        set1?.drawCircleHoleEnabled = false;
        
        set1?.valueFont = UIFont.systemFontOfSize(9.0)
        
        let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_YELLOW().CGColor,AppTheme.NEVO_SOLAR_GRAY().CGColor];
        let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
        set1?.fillAlpha = 1.0;
        set1?.fill = ChartFill.fillWithLinearGradient(gradient, angle: 90.0)
        set1?.drawFilledEnabled = true;
        
        
        var dataSets:[LineChartDataSet] = [];
        dataSets.append(set1!)
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        data.setDrawValues(false)
        lineChartView.data = data;
        lineChartView.animate(xAxisDuration:2.5, easingOption: ChartEasingOption.EaseInOutQuart)
    }

    func setSleepDataCount(countArray:NSArray,type:Int,rowIndex:Int) {
        sortArray.removeAllObjects()
        sortArray.addObjectsFromArray(countArray as [AnyObject])
        var xVals:[String] = []
        var yVals:[ChartDataEntry] = []
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSleeps:UserSleep = sortArray.objectAtIndex(i) as! UserSleep;
                let jSleep:UserSleep = sortArray.objectAtIndex(j) as! UserSleep;
                let iSleepDate:Double = iSleeps.date
                let jSleepDate:Double = jSleep.date
                //Time has sorted
                if (iSleepDate > jSleepDate){
                    let temp:UserSleep = sortArray.objectAtIndex(i) as! UserSleep;
                    sortArray.replaceObjectAtIndex(i, withObject: sortArray[j])
                    sortArray.replaceObjectAtIndex(j, withObject: temp)
                }
            }
        }
    
        for (index,sleeps) in sortArray.enumerate() {
            var sleepTimeValue:Int = 0
            let mSleeps:UserSleep = sleeps as! UserSleep
            let sleepsValue:NSArray = AppTheme.jsonToArray(mSleeps.hourlySleepTime)
            
            let date:NSDate = NSDate(timeIntervalSince1970: mSleeps.date)
            let dateString:String = date.stringFromFormat("dd/MM")
            
            if index>0 {
                let kSleeps:UserSleep = sortArray[index-1] as! UserSleep
                let value2:NSArray = AppTheme.jsonToArray(kSleeps.hourlySleepTime)
                for (index2,value) in value2.enumerate() {
                    if index2>18 {
                        sleepTimeValue += (value as! NSNumber).integerValue
                    }
                }
            }
            
            for (index2,value) in sleepsValue.enumerate() {
                if index2<12 {
                    sleepTimeValue += (value as! NSNumber).integerValue
                }
            }
            //Calculate the maximum
            if sleepTimeValue>maxValue {
                maxValue = sleepTimeValue
            }
            
            //chart the maximum
            if index == countArray.count-1 {
                let leftAxis:ChartYAxis = lineChartView.leftAxis;
                leftAxis.axisMaxValue = Double(maxValue/60+2);
                leftAxis.axisMinValue = 0.0;
                leftAxis.gridLineDashLengths = [0.0, 0.0];
                leftAxis.labelTextColor = UIColor.blackColor()
                
                leftAxis.labelCount = 5;
                leftAxis.valueFormatter = NSNumberFormatter();
                leftAxis.valueFormatter!.maximumFractionDigits = 1;
                leftAxis.valueFormatter!.negativeSuffix = " hours";
                leftAxis.valueFormatter!.positiveSuffix = " hours";
                leftAxis.labelPosition = ChartYAxis.LabelPosition.OutsideChart
                leftAxis.spaceTop = 0.15;
            }
            
            xVals.append(dateString)
            NSLog("index----:\(index),\(sleepTimeValue),\(dateString)")
            yVals.append(ChartDataEntry(value: Double(sleepTimeValue)/60, xIndex: index))
        }
        
        if rowIndex == 0 || rowIndex == 1{
            if xVals.count<7 {
                for index:Int in xVals.count..<7 {
                    //let mult:Double = (600 + 1);
                    //let val:Double = Double(arc4random_uniform(UInt32(mult))) + 3;
                    xVals.append("")
                    yVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }
        
        if rowIndex == 2 {
            if xVals.count<30 {
                for index:Int in xVals.count..<30 {
                    xVals.append("")
                    yVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }

        var set1:LineChartDataSet?
        if lineChartView.data?.dataSetCount>0 {
            set1 = lineChartView.data?.dataSets[0] as? LineChartDataSet
            set1?.yVals = yVals
            lineChartView.data?.xValsObjc = xVals
            lineChartView.data?.notifyDataChanged()
            lineChartView.notifyDataSetChanged()
        }else{
            set1 = LineChartDataSet(yVals: yVals, label: "")
            set1?.lineDashLengths = [0.0, 0];
            set1?.highlightLineDashLengths = [0.0, 0.0];
            set1?.setColor(AppTheme.NEVO_SOLAR_YELLOW())
            set1?.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
            set1?.valueTextColor = UIColor.blackColor()
            set1?.lineWidth = 1.0;
            set1?.circleRadius = 0.0;
            //set1?.drawCirclesEnabled = false;
            set1?.drawValuesEnabled = false
            set1?.drawCircleHoleEnabled = false;
            //set1?.mode = LineChartDataSet.Mode.CubicBezier
            
            set1?.valueFont = UIFont.systemFontOfSize(9.0)
            
            let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_YELLOW().CGColor,AppTheme.NEVO_SOLAR_GRAY().CGColor];
            let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
            set1?.fillAlpha = 1.0;
            set1?.fill = ChartFill.fillWithLinearGradient(gradient, angle: 90.0)
            set1?.drawFilledEnabled = true;
            
            
            var dataSets:[LineChartDataSet] = [];
            dataSets.append(set1!)
            
            let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
            lineChartView.data = data;
            lineChartView.legend.form = ChartLegend.Form.Line
            lineChartView.animate(xAxisDuration: 1.4, easingOption: ChartEasingOption.EaseInOutCirc)
        }
    }
    
    func setSloarDataCount(count:Int,range:Double) {
        var xVals:[String] = []
        for i:Int in 0..<count {
            xVals.append("\(i)")
        }
        
        var yVals:[ChartDataEntry] = []
        
        var maxValue:Double = 0
        
        for i:Int in 0..<count {
            let mult:Double = range + 100.0
            let val:Double = Double(arc4random_uniform(UInt32(mult)) + 30)
            yVals.append(ChartDataEntry(value: val/60, xIndex: i))
            if val>maxValue {
                maxValue = val;
            }
            //chart the maximum
            if i == count-1 {
                let leftAxis:ChartYAxis = lineChartView.leftAxis;
                leftAxis.axisMaxValue = Double(maxValue/60+2);
                leftAxis.axisMinValue = 0.0;
                leftAxis.gridLineDashLengths = [0.0, 0.0];
                leftAxis.labelTextColor = UIColor.blackColor()
                
                leftAxis.labelCount = 5;
                leftAxis.valueFormatter = NSNumberFormatter();
                leftAxis.valueFormatter!.maximumFractionDigits = 1;
                leftAxis.valueFormatter!.negativeSuffix = " hours";
                leftAxis.valueFormatter!.positiveSuffix = " hours";
                leftAxis.labelPosition = ChartYAxis.LabelPosition.OutsideChart
                leftAxis.spaceTop = 0.15;
            }
        }
        
        var set1:LineChartDataSet?
        if lineChartView.data?.dataSetCount>0 {
            set1 = lineChartView.data?.dataSets[0] as? LineChartDataSet
            set1?.yVals = yVals
            lineChartView.data?.xValsObjc = xVals
            lineChartView.data?.notifyDataChanged()
            lineChartView.notifyDataSetChanged()
        }else{
            set1 = LineChartDataSet(yVals: yVals, label: "")
            set1?.lineDashLengths = [0.0, 0];
            set1?.highlightLineDashLengths = [0.0, 0.0];
            set1?.setColor(AppTheme.NEVO_SOLAR_YELLOW())
            set1?.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
            set1?.valueTextColor = UIColor.blackColor()
            set1?.lineWidth = 1.0;
            set1?.circleRadius = 0.0;
            //set1?.drawCirclesEnabled = false;
            set1?.drawValuesEnabled = false
            set1?.drawCircleHoleEnabled = false;
            
            set1?.valueFont = UIFont.systemFontOfSize(9.0)
            
            let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_YELLOW().CGColor,AppTheme.NEVO_SOLAR_GRAY().CGColor];
            let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
            set1?.fillAlpha = 1.0;
            set1?.fill = ChartFill.fillWithLinearGradient(gradient, angle: 90.0)
            set1?.drawFilledEnabled = true;
            
            
            var dataSets:[LineChartDataSet] = [];
            dataSets.append(set1!)
            
            let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
            lineChartView.data = data;
        }
    }
}
