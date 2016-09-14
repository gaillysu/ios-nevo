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
    
    private var xVals:[String] = []
    private var yVals:[ChartDataEntry] = []
    
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
        
        lineChartView.rightAxis.enabled = false;
        
        let xAxis:ChartXAxis = lineChartView.xAxis
        xAxis.labelTextColor = UIColor.blackColor();
        xAxis.axisLineColor = AppTheme.NEVO_SOLAR_GRAY()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFontOfSize(12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.minimumSize = CGSizeMake(80.0, 40.0);
        lineChartView.marker = marker;
        
        lineChartView.legend.form = ChartLegend.Form.Line
        lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    func setTitle(title:String) {
        titleLabel.text = title
    }
    
    func setContentValue(title:String) {
        titleLabel.text = title
    }
    
    func updateChartData(dataArray:NSArray,chartType:Int,rowIndex:Int,completionData:((totalValue:Float,totalCalores:Int,totalTime:Int) -> Void)) {
        lineChartView.data = nil
        xVals = []
        yVals = []
        
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
            break
            //self.setSloarDataCount(7, range: 50)
        default: break
        }
    }
    
    func setStepsDataCount(countArray:NSArray,type:Int,rowIndex:Int) {
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
                self.setChartViewLeftAxis(Double(maxValue+500), unitString: "")
            }
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+500), unitString: "")
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
            yVals.append(ChartDataEntry(value: steps, xIndex: i))
            xVals.append(dateString)
        }
        
        self.setYvalueData(rowIndex)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.blackColor()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFontOfSize(9.0)
        
        let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().CGColor,AppTheme.NEVO_SOLAR_YELLOW().CGColor];
        let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.CubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        //lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }

    func setSleepDataCount(countArray:NSArray,type:Int,rowIndex:Int) {
        sortArray.removeAllObjects()
        sortArray.addObjectsFromArray(countArray as [AnyObject])
        var weakeYVals:[ChartDataEntry] = []
        var lightYVals:[ChartDataEntry] = []
        var deepYVals:[ChartDataEntry] = []
        
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
            
            var sleepValue:Int = 0
            var weakeValue:Int = 0
            var lightValue:Int = 0
            var deepValue:Int = 0
            
            let mSleeps:UserSleep = sleeps as! UserSleep
            let sleepsValue1:[Int] = AppTheme.jsonToArray(mSleeps.hourlySleepTime) as! [Int]
            let sleepsValue2:[Int] = AppTheme.jsonToArray(mSleeps.hourlyWakeTime) as! [Int]
            let sleepsValue3:[Int] = AppTheme.jsonToArray(mSleeps.hourlyLightTime) as! [Int]
            let sleepsValue4:[Int] = AppTheme.jsonToArray(mSleeps.hourlyDeepTime) as! [Int]
            
            let date:NSDate = NSDate(timeIntervalSince1970: mSleeps.date)
            let dateString:String = date.stringFromFormat("dd/MM")
            
            if index>0 {
                let kSleeps:UserSleep = sortArray[index-1] as! UserSleep
                let value1:[Int] = AppTheme.jsonToArray(kSleeps.hourlySleepTime) as! [Int]
                let value2:[Int] = AppTheme.jsonToArray(kSleeps.hourlyWakeTime) as! [Int]
                let value3:[Int] = AppTheme.jsonToArray(kSleeps.hourlyLightTime) as! [Int]
                let value4:[Int] = AppTheme.jsonToArray(kSleeps.hourlyDeepTime) as! [Int]
                
                for (index2,value) in value1.enumerate() {
                    if index2>18 {
                        sleepValue += value
                        weakeValue += value2[index2]
                        lightValue += value3[index2]
                        deepValue += value4[index2]
                    }
                }
            }
            
            for (index2,value) in sleepsValue1.enumerate() {
                if index2<12 {
                    sleepValue += value
                    weakeValue += sleepsValue2[index2]
                    lightValue += sleepsValue3[index2]
                    deepValue += sleepsValue4[index2]
                }
            }
            //Calculate the maximum
            if sleepValue>maxValue {
                maxValue = sleepValue
            }
            
            //chart the maximum
            if index == countArray.count-1 {
                self.setChartViewLeftAxis(Double(maxValue/60+2), unitString: " hours")
            }
            
            xVals.append(dateString)
            yVals.append(ChartDataEntry(value: 0, xIndex: index))
            weakeYVals.append(ChartDataEntry(value: Double(weakeValue)/60, xIndex: index))
            lightYVals.append(ChartDataEntry(value: Double(lightValue)/60, xIndex: index))
            deepYVals.append(ChartDataEntry(value: Double(deepValue)/60, xIndex: index))
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+7), unitString: " hours")
        }
        
        if rowIndex == 0 || rowIndex == 1{
            if xVals.count<7 {
                for index:Int in xVals.count..<7 {
                    weakeYVals.append(ChartDataEntry(value: 0, xIndex: index))
                    lightYVals.append(ChartDataEntry(value: 0, xIndex: index))
                    deepYVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }
        
        if rowIndex == 2 {
            if xVals.count<30 {
                for index:Int in xVals.count..<30 {
                    weakeYVals.append(ChartDataEntry(value: 0, xIndex: index))
                    lightYVals.append(ChartDataEntry(value: 0, xIndex: index))
                    deepYVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }
        
        self.setYvalueData(rowIndex)
        
        let dataArray:[[ChartDataEntry]] = [weakeYVals,lightYVals,deepYVals]
        var dataSets:[LineChartDataSet] = [];
        
        for (index,values) in dataArray.enumerate() {
            let set1:LineChartDataSet = LineChartDataSet(yVals: values, label: "")
            set1.lineDashLengths = [0.0, 0];
            set1.highlightLineDashLengths = [0.0, 0.0];
            set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
            set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
            set1.valueTextColor = UIColor.blackColor()
            set1.lineWidth = 1.0;
            set1.circleRadius = 0.0;
            set1.drawValuesEnabled = false
            set1.drawCircleHoleEnabled = false;
            set1.valueFont = UIFont.systemFontOfSize(9.0)
            //set1.mode = LineChartDataSet.Mode.CubicBezier
            
            let gradientColors:[NSUIColor] = [UIColor.lightGrayColor(),AppTheme.NEVO_SOLAR_YELLOW(),AppTheme.NEVO_SOLAR_GRAY()];
            set1.fillAlpha = 0.5;
            set1.fill = ChartFill.fillWithColor(gradientColors[index])
            //fillWithLinearGradient(gradient, angle: 90.0)
            set1.drawFilledEnabled = true;
            dataSets.append(set1)
        }
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        lineChartView.data = data;
        lineChartView.legend.form = ChartLegend.Form.Line
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    func setSloarDataCount(countArray:NSArray,type:Int,rowIndex:Int){
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
                self.setChartViewLeftAxis(Double(maxValue+500), unitString: "")
            }
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+500), unitString: "")
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
            yVals.append(ChartDataEntry(value: steps, xIndex: i))
            xVals.append(dateString)
        }
        
        self.setYvalueData(rowIndex)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.blackColor()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFontOfSize(9.0)
        
        let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().CGColor,AppTheme.NEVO_SOLAR_YELLOW().CGColor];
        let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.CubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        //lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    func moveToWindow(count:Int,range:Double) {
        var xVals:[String] = []
        var yVals:[ChartDataEntry] = []
        for i:Int in 0..<count {
            xVals.append("\(i)")
        }
        
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
                self.setChartViewLeftAxis(Double(maxValue/60+2), unitString: " hours")
            }
        }
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.blackColor()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFontOfSize(9.0)
        set1.mode = LineChartDataSet.Mode.CubicBezier
        
        let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().CGColor,AppTheme.NEVO_SOLAR_YELLOW().CGColor];
        let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true;
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        lineChartView.data = data;
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    func setChartViewLeftAxis(maxValue:Double,unitString:String) {
        let leftAxis:ChartYAxis = lineChartView.leftAxis;
        leftAxis.axisMaxValue = maxValue;
        leftAxis.axisMinValue = 0.0;
        leftAxis.gridLineDashLengths = [0.0, 0.0];
        leftAxis.labelTextColor = UIColor.blackColor()
        
        leftAxis.labelCount = 5;
        leftAxis.valueFormatter = NSNumberFormatter();
        leftAxis.valueFormatter!.maximumFractionDigits = 1;
        leftAxis.valueFormatter!.negativeSuffix = unitString;
        leftAxis.valueFormatter!.positiveSuffix = unitString;
        leftAxis.labelPosition = ChartYAxis.LabelPosition.OutsideChart
        leftAxis.spaceTop = 0.15;
    }
    
    func setYvalueData(rowIndex:Int) {
        let dayTime:Double = 86400
        
        if rowIndex == 0{
            if xVals.count<7 {
                if xVals.count == 0 {
                    let dateString:String = NSDate().beginningOfWeek.stringFromFormat("dd/MM")
                    xVals.append(dateString)
                    yVals.append(ChartDataEntry(value: 0, xIndex: 0))
                }
                for index:Int in xVals.count..<7 {
                    let date:NSDate = xVals[xVals.count-1].dateFromFormat("dd/MM")!
                    let date2:NSDate = NSDate(timeIntervalSince1970: date.timeIntervalSince1970+dayTime)
                    let dateString:String = date2.stringFromFormat("dd/MM")
                    xVals.append(dateString)
                    yVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }
        
        if rowIndex == 1{
            let startTimeInterval:NSTimeInterval = NSDate().timeIntervalSince1970-(86400.0*7)
            if xVals.count<7 {
                for index:Int in 1..<7 {
                    if xVals.count==0 {
                        let dateString:String = NSDate(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    let startDate1:NSDate = xVals[index-1].dateFromFormat("dd/MM")!
                    let date2:NSDate = NSDate(timeIntervalSince1970: startDate1.timeIntervalSince1970+dayTime)
                    if xVals.count == index {
                        let dateString:String = date2.stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), atIndex: index)
                    }else{
                        let pDate:NSDate = xVals[index].dateFromFormat("dd/MM")!
                        
                        if pDate.day != date2.day{
                            let dateString:String = date2.stringFromFormat("dd/MM")
                            xVals.append(dateString)
                            yVals.insert(ChartDataEntry(value: 0, xIndex: index), atIndex: index)
                        }
                    }
                }
            }
        }
        
        if rowIndex == 2 {
            let startTimeInterval:NSTimeInterval = NSDate().timeIntervalSince1970-(86400.0*30)
            if xVals.count<30 {
                for index:Int in 0..<30 {
                    if xVals.count==0 {
                        let dateString:String = NSDate(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    
                    if index != 0 {
                        let startDate1:NSDate = xVals[index-1].dateFromFormat("dd/MM")!
                        let date2:NSDate = NSDate(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                        let date3:NSDate = NSDate(timeIntervalSince1970:startDate1.timeIntervalSince1970+dayTime)
                        if !date2.isEqualToDate(date3) {
                            let dateString:String = date2.stringFromFormat("dd/MM")
                            xVals.append(dateString)
                            yVals.insert(ChartDataEntry(value: 0, xIndex: index), atIndex: index)
                        }
                    }
                    
//                    if xVals.count == index {
//                        let dateString:String = date2.stringFromFormat("dd/MM")
//                        xVals.append(dateString)
//                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), atIndex: index)
//                    }else{
//                        let pDate:NSDate = xVals[index].dateFromFormat("dd/MM")!
//                        
//                        if pDate.day != date2.day{
//                            let dateString:String = date2.stringFromFormat("dd/MM")
//                            xVals.append(dateString)
//                            yVals.insert(ChartDataEntry(value: 0, xIndex: index), atIndex: index)
//                        }
//                    }
                }
            }
        }
    }
}
