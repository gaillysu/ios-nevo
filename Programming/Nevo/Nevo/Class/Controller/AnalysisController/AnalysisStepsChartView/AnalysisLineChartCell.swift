//
//  AnalysisLineChartCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/9.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Charts

class AnalysisLineChartCell: UICollectionViewCell,ChartViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    fileprivate var sortArray:NSMutableArray = NSMutableArray()
    
    fileprivate var xVals:[String] = []
    fileprivate var yVals:[ChartDataEntry] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initChartView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            titleLabel.textColor = UIColor.white
        }
    }

    fileprivate func initChartView() {
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
        xAxis.labelTextColor = UIColor.black;
        xAxis.axisLineColor = AppTheme.NEVO_SOLAR_GRAY()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.bottom
        xAxis.labelFont = UIFont(name: "Raleway", size: 7)!
        
        lineChartView.legend.form = ChartLegend.Form.line
        lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.easeInOutCirc)
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            xAxis.labelTextColor = UIColor.white;
        }
    }
    
    func setTitle(_ title:String) {
        titleLabel.text = title.uppercased()
    }
    
    func setContentValue(_ title:String) {
        titleLabel.text = title
    }
    
    func updateChartData(_ dataArray:NSArray,chartType:Int,rowIndex:Int,completionData:((_ totalValue:Float,_ totalCalores:Int,_ totalTime:Double) -> Void)) {
        lineChartView.data = nil
        xVals = []
        yVals = []
        
        switch chartType {
        case 0:
            let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFont(ofSize: 12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
            marker.minimumSize = CGSize(width: 80.0, height: 40.0);
            marker.markerType = .stepsChartType
            lineChartView.marker = marker;
            var totalSteps:Int = 0
            var totalCalores:Int = 0
            var totalTime:Int = 0
            for value in dataArray {
                let usersteps:UserSteps = value as! UserSteps
                totalSteps += usersteps.steps
                totalCalores += Int(usersteps.calories)
                totalTime += (usersteps.walking_duration+usersteps.running_duration)
            }
            completionData(Float(totalSteps), totalCalores, Double(totalTime)/60.0)
            self.setStepsDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 1:
            let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont.systemFont(ofSize: 12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
            marker.minimumSize = CGSize(width: 80.0, height: 40.0);
            marker.markerType = .sleepChartType
            lineChartView.marker = marker;
            var totalValue:Int = 0
            var weakeValue:Int = 0
            var deepValue:Int = 0
            for value in dataArray {
                let userSleep:UserSleep = value as! UserSleep
                let sleepTime:[Int] = AppTheme.jsonToArray(userSleep.hourlySleepTime) as! [Int]
                let weakeSleepTime:[Int] = AppTheme.jsonToArray(userSleep.hourlyWakeTime) as! [Int]
                let deepSleepTime:[Int] = AppTheme.jsonToArray(userSleep.hourlyDeepTime) as! [Int]
                for value2 in sleepTime {
                    totalValue+=value2
                }
                
                for value3 in weakeSleepTime {
                    weakeValue+=value3
                }
                
                for value4 in deepSleepTime {
                    deepValue+=value4
                }
            }

            let isNan = (Double(deepValue)/Double(totalValue)).isNaN
            var quality:Double = isNan ? 0:(Double(deepValue)/Double(totalValue))*100
            if totalValue == 0 {
                quality = 0
            }
            
            completionData(Float(totalValue)/60.0, weakeValue, quality)
            self.setSleepDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        case 2:
            self.setSloarDataCount(dataArray, type: chartType,rowIndex:rowIndex)
        default: break
        }
    }
    
    func setStepsDataCount(_ countArray:NSArray,type:Int,rowIndex:Int) {
        sortArray.removeAllObjects()
        sortArray.addObjects(from: countArray as [AnyObject])
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSteps:UserSteps = sortArray.object(at: i) as! UserSteps;
                let jSteps:UserSteps = sortArray.object(at: j) as! UserSteps;
                let iStepsDate:Double = iSteps.date
                let jStepsDate:Double = jSteps.date
                
                //Time has sorted
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = sortArray.object(at: i) as! UserSteps;
                    sortArray.replaceObject(at: i, with: sortArray[j])
                    sortArray.replaceObject(at: j, with: temp)
                }
            }
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+1000), unitString: "")
        }
        
        for i:Int in 0..<sortArray.count {
            let usersteps:UserSteps = sortArray[i] as! UserSteps
            let date:Date = "\(usersteps.createDate)".dateFromFormat("yyyyMMdd")!
            let dateString:String = date.stringFromFormat("dd/MM")
            let stepsArray = AppTheme.jsonToArray(usersteps.hourlysteps)
            var steps:Double = 0
            for value in stepsArray {
                steps += Double((value as! NSNumber).doubleValue)
            }
            yVals.append(ChartDataEntry(value: steps, xIndex: i))
            xVals.append(dateString)
            NSLog("createDate:%@", usersteps.createDate)
            NSLog("Date:%@", Date(timeIntervalSince1970: usersteps.date).stringFromFormat("yy-MM-dd"))
            NSLog("index:\(i)")
            let iStepsValue:Int = Int(steps)
            //Calculate the maximum
            if iStepsValue>maxValue {
                maxValue = iStepsValue
            }
        }
        
        self.setChartViewLeftAxis(Double(maxValue-(maxValue%2)+800), unitString: "")
        
        self.setYvalueData(rowIndex,completionData: nil)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.black
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFont(ofSize: 9.0)
        
        var gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_YELLOW().cgColor,AppTheme.NEVO_SOLAR_GRAY().cgColor];
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            gradientColors = [UIColor.getTintColor().cgColor,UIColor.getBaseColor().cgColor];
        }
        let gradient:CGGradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.cubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        //lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }

    func setSleepDataCount(_ countArray:NSArray,type:Int,rowIndex:Int) {
        sortArray.removeAllObjects()
        sortArray.addObjects(from: countArray as [AnyObject])
        var weakeYVals:[ChartDataEntry] = []
        var lightYVals:[ChartDataEntry] = []
        var deepYVals:[ChartDataEntry] = []
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSleeps:UserSleep = sortArray.object(at: i) as! UserSleep;
                let jSleep:UserSleep = sortArray.object(at: j) as! UserSleep;
                let iSleepDate:Double = iSleeps.date
                let jSleepDate:Double = jSleep.date
                //Time has sorted
                if (iSleepDate > jSleepDate){
                    let temp:UserSleep = sortArray.object(at: i) as! UserSleep;
                    sortArray.replaceObject(at: i, with: sortArray[j])
                    sortArray.replaceObject(at: j, with: temp)
                }
            }
        }
        
        for (index,sleeps) in sortArray.enumerated() {
            
            var sleepValue:Int = 0
            var weakeValue:Int = 0
            var lightValue:Int = 0
            var deepValue:Int = 0
            
            let mSleeps:UserSleep = sleeps as! UserSleep
            let sleepsValue1:[Int] = AppTheme.jsonToArray(mSleeps.hourlySleepTime) as! [Int]
            let sleepsValue2:[Int] = AppTheme.jsonToArray(mSleeps.hourlyWakeTime) as! [Int]
            let sleepsValue3:[Int] = AppTheme.jsonToArray(mSleeps.hourlyLightTime) as! [Int]
            let sleepsValue4:[Int] = AppTheme.jsonToArray(mSleeps.hourlyDeepTime) as! [Int]
            
            let date:Date = Date(timeIntervalSince1970: mSleeps.date)
            let dateString:String = date.stringFromFormat("dd/MM")
            
            if index>0 {
                let kSleeps:UserSleep = sortArray[index-1] as! UserSleep
                let value1:[Int] = AppTheme.jsonToArray(kSleeps.hourlySleepTime) as! [Int]
                let value2:[Int] = AppTheme.jsonToArray(kSleeps.hourlyWakeTime) as! [Int]
                let value3:[Int] = AppTheme.jsonToArray(kSleeps.hourlyLightTime) as! [Int]
                let value4:[Int] = AppTheme.jsonToArray(kSleeps.hourlyDeepTime) as! [Int]
                
                for (index2,value) in value1.enumerated() {
                    if index2>18 {
                        sleepValue += value
                        weakeValue += value2[index2]
                        lightValue += value3[index2]
                        deepValue += value4[index2]
                    }
                }
            }
            
            for (index2,value) in sleepsValue1.enumerated() {
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
                self.setChartViewLeftAxis(Double(maxValue/60+2), unitString: " "+NSLocalizedString("hours", comment: ""))
            }
            
            xVals.append(dateString)
            weakeYVals.append(ChartDataEntry(value: (Double(weakeValue)/60).to2Double(), xIndex: index))
            lightYVals.append(ChartDataEntry(value: (Double(lightValue)/60).to2Double(), xIndex: index))
            deepYVals.append(ChartDataEntry(value: (Double(deepValue)/60).to2Double(), xIndex: index))
            yVals.append(ChartDataEntry(value: 0, xIndex: index))
        }
        
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+7), unitString: " "+NSLocalizedString("hours", comment: ""))
        }else{
            if maxValue == 0 {
                self.setChartViewLeftAxis(Double(maxValue+7), unitString: " "+NSLocalizedString("hours", comment: ""))
            }
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
        
        self.setYvalueData(rowIndex) { (yvalsIndex, replace) in
            if replace {
                //CRASH crash
                if weakeYVals.count > 0{
                    let weakeDataentry:ChartDataEntry = weakeYVals[yvalsIndex]
                    let lightDataentry:ChartDataEntry = lightYVals[yvalsIndex]
                    let deepDataentry:ChartDataEntry = deepYVals[yvalsIndex]
                    weakeYVals.replaceSubrange(yvalsIndex..<yvalsIndex+1, with: [ChartDataEntry(value: weakeDataentry.value.to2Double(), xIndex: yvalsIndex)])
                    lightYVals.replaceSubrange(yvalsIndex..<yvalsIndex+1, with: [ChartDataEntry(value: lightDataentry.value.to2Double(), xIndex: yvalsIndex)])
                    deepYVals.replaceSubrange(yvalsIndex..<yvalsIndex+1, with: [ChartDataEntry(value: deepDataentry.value.to2Double(), xIndex: yvalsIndex)])
                }else{
                    weakeYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                    lightYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                    deepYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                }
                
            }else{
                weakeYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                lightYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
                deepYVals.insert(ChartDataEntry(value: 0, xIndex: yvalsIndex), at: yvalsIndex)
            }
        }
        
        let dataArray:[[ChartDataEntry]] = [weakeYVals,lightYVals,deepYVals]
        var dataSets:[LineChartDataSet] = [];
        
        for (index,values) in dataArray.enumerated() {
            let set1:LineChartDataSet = LineChartDataSet(yVals: values, label: "")
            set1.lineDashLengths = [0.0, 0];
            set1.highlightLineDashLengths = [0.0, 0.0];
            set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
            set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
            set1.valueTextColor = UIColor.black
            set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
            set1.lineWidth = 1.0;
            set1.circleRadius = 0.0;
            set1.drawValuesEnabled = false
            set1.drawCircleHoleEnabled = false;
            set1.valueFont = UIFont.systemFont(ofSize: 9.0)
            //set1.mode = LineChartDataSet.Mode.CubicBezier
            
            var gradientColors:[UIColor] = [UIColor.lightGray,AppTheme.NEVO_SOLAR_YELLOW(),AppTheme.NEVO_SOLAR_GRAY()];
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                gradientColors = [UIColor.lightGray,UIColor.getTintColor(),UIColor.getBaseColor()];
            }
            set1.fillAlpha = 0.5;
            set1.fill = ChartFill.fillWithColor(gradientColors[index])
            //fillWithLinearGradient(gradient, angle: 90.0)
            set1.drawFilledEnabled = true;
            dataSets.append(set1)
        }
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        lineChartView.data = data;
        lineChartView.legend.form = ChartLegend.Form.line
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }
    
    /**
     Set sloar chart data
     
     - parameter countArray: data
     - parameter type:       chart type(this week,last week)
     - parameter rowIndex:   chart index
     */
    func setSloarDataCount(_ countArray:NSArray,type:Int,rowIndex:Int){
        sortArray.removeAllObjects()
        sortArray.addObjects(from: countArray as [AnyObject])
        
        var maxValue:Int = 0
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSteps:UserSteps = sortArray.object(at: i) as! UserSteps;
                let jSteps:UserSteps = sortArray.object(at: j) as! UserSteps;
                let iStepsDate:Double = iSteps.date
                let jStepsDate:Double = jSteps.date
                let iStepsValue:Int = iSteps.steps
                
                //Calculate the maximum
                if iStepsValue>maxValue {
                    maxValue = 0
                }
                //Time has sorted
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = sortArray.object(at: i) as! UserSteps;
                    sortArray.replaceObject(at: i, with: sortArray[j])
                    sortArray.replaceObject(at: j, with: temp)
                }
            }
            //chart the maximum
            if i == countArray.count-1 {
                self.setChartViewLeftAxis(Double(maxValue+7), unitString: " "+NSLocalizedString("hours", comment: ""))
            }
        }
         
        if sortArray.count == 0 {
            self.setChartViewLeftAxis(Double(maxValue+1), unitString: " "+NSLocalizedString("hours", comment: ""))
        }
        
        for i:Int in 0..<sortArray.count {
            let usersteps:UserSteps = sortArray[i] as! UserSteps
            let date:Date = "\(usersteps.createDate)".dateFromFormat("yyyyMMdd")!
            let dateString:String = date.stringFromFormat("dd/MM")
            
            let steps:Double = 0
            yVals.append(ChartDataEntry(value: steps, xIndex: i))
            xVals.append(dateString)
        }
        
        self.setYvalueData(rowIndex,completionData:nil)
        
        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
        set1.lineDashLengths = [0.0, 0];
        set1.highlightLineDashLengths = [0.0, 0.0];
        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1.setCircleColor(AppTheme.NEVO_SOLAR_GRAY())
        set1.valueTextColor = UIColor.black
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        //set1?.drawCirclesEnabled = false;
        set1.drawValuesEnabled = false
        set1.drawCircleHoleEnabled = false;
        set1.valueFont = UIFont.systemFont(ofSize: 9.0)
        
        var gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().cgColor,AppTheme.NEVO_SOLAR_YELLOW().cgColor];
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            gradientColors = [UIColor.getBaseColor().cgColor,UIColor.getTintColor().cgColor];
        }
        
        let gradient:CGGradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1;
        set1.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        set1.drawFilledEnabled = true
        set1.mode = LineChartDataSet.Mode.cubicBezier
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: [set1])
        data.setDrawValues(false)
        lineChartView.data = data;
        //lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutCirc)
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }
    
    /**
     Set on the left side of the Chart data units
     
     - parameter maxValue:   Max value
     - parameter unitString: unit
     */
    func setChartViewLeftAxis(_ maxValue:Double,unitString:String) {
        let leftAxis:ChartYAxis = lineChartView.leftAxis;
        leftAxis.axisMaxValue = maxValue;
        leftAxis.axisMinValue = 0.0;
        leftAxis.gridLineDashLengths = [0.0, 0.0];
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont(name: "Raleway", size: 10)!
        
        //leftAxis.labelCount = 5;
        leftAxis.valueFormatter = NumberFormatter();
        leftAxis.valueFormatter!.maximumFractionDigits = 1;
        leftAxis.valueFormatter!.negativeSuffix = unitString;
        leftAxis.valueFormatter!.positiveSuffix = unitString;
        leftAxis.labelPosition = ChartYAxis.LabelPosition.outsideChart
        leftAxis.spaceTop = 0.15;
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            leftAxis.labelTextColor = UIColor.white;
        }
    }
    
    /**
     set Chart Yvalue
     
     - parameter rowIndex: Which one Chart
     */
    func setYvalueData(_ rowIndex:Int,completionData:((_ yvalsIndex:Int,_ replace:Bool) -> Void)?) {
        let dayTime:Double = 86400
        
        if rowIndex == 0{
            if xVals.count<7 {
                if xVals.count == 0 {
                    let dateString:String = Date().beginningOfWeek.stringFromFormat("dd/MM")
                    xVals.append(dateString)
                    yVals.append(ChartDataEntry(value: 0, xIndex: 0))
                }
                for index:Int in xVals.count..<7 {
                    let date:Date = xVals[xVals.count-1].dateFromFormat("dd/MM")!
                    let date2:Date = Date(timeIntervalSince1970: date.timeIntervalSince1970+dayTime)
                    let dateString:String = date2.stringFromFormat("dd/MM")
                    xVals.append(dateString)
                    yVals.append(ChartDataEntry(value: 0, xIndex: index))
                }
            }
        }
        
        if rowIndex == 1{
            let startTimeInterval:TimeInterval = Date().beginningOfDay.timeIntervalSince1970-(86400.0*7)
            if xVals.count<7 {
                for index:Int in 0..<7 {
                    if xVals.count==0 {
                        let dateString:String = Date(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    
                    var getIndex:Int = index
                    if index>=xVals.count {
                        getIndex = index-1
                    }
                    let startDate1:Date = xVals[getIndex].dateFromFormat("dd/MM")!
                    let date2:Date = Date(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                    let dateString1:String = startDate1.stringFromFormat("dd/MM")
                    let dateString2:String = date2.stringFromFormat("dd/MM")
                    
                    if dateString1 != dateString2 {
                        xVals.insert(dateString2, at: index)
                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), at: index)
                        completionData?(index,false)
                    }else{
                        let dataentry:ChartDataEntry = yVals[index]
                        yVals.replaceSubrange(index..<index+1, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: index)])
                        completionData?(index,true)
                    }
                    
                    if index == 6 {
                        let dataentry:ChartDataEntry = yVals[yVals.count-1]
                        yVals.replaceSubrange(yVals.count-1..<yVals.count, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: yVals.count-1)])
                        completionData?(yVals.count-1,true)
                    }
                }
            }
        }
        
        if rowIndex == 2 {
            let startTimeInterval:TimeInterval = Date().beginningOfDay.timeIntervalSince1970-(dayTime*30)-1
            if xVals.count<30 {
                for index:Int in 0..<30 {
                    if xVals.count==0 {
                        let dateString:String = Date(timeIntervalSince1970: startTimeInterval).stringFromFormat("dd/MM")
                        xVals.append(dateString)
                        yVals.append(ChartDataEntry(value: 0, xIndex: index))
                    }
                    var indexValue:Int = index
                    var getIndex:Int = index
                    if index>=xVals.count {
                        getIndex = index-1
                    }
                    let startDate1:Date = xVals[getIndex].dateFromFormat("dd/MM")!
                    let date2:Date = Date(timeIntervalSince1970:startTimeInterval+dayTime*Double(index))
                    let dateString1:String = startDate1.stringFromFormat("dd/MM")
                    let dateString2:String = date2.stringFromFormat("dd/MM")
                    
                    if dateString1 != dateString2 {
                        xVals.insert(dateString2, at: index)
                        yVals.insert(ChartDataEntry(value: 0, xIndex: index), at: index)
                        completionData?(index,false)
                    }else{
                        let dataentry:ChartDataEntry = yVals[index]
                        yVals.replaceSubrange(index..<index+1, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: index)])
                        completionData?(index,true)
                    }
                    
                    if index == 29 {
                        let dataentry:ChartDataEntry = yVals[yVals.count-1]
                        yVals.replaceSubrange(yVals.count-1..<yVals.count, with: [ChartDataEntry(value: dataentry.value.to2Double(), xIndex: yVals.count-1)])
                        completionData?(yVals.count-1,true)
                    }
                }
            }
        }
    }
}
