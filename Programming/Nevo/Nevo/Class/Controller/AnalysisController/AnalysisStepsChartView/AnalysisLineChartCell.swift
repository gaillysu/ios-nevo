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
        
        lineChartView.delegate = self;
        
        lineChartView.descriptionText = "";
        lineChartView.noDataTextDescription = "You need to provide data for the chart.";
        
        lineChartView.dragEnabled = false;
        lineChartView.setScaleEnabled(false)
        lineChartView.pinchZoomEnabled = false;
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.enabled = true
        lineChartView.drawGridBackgroundEnabled = false;
        
        // x-axis limit line
        let llXAxis:ChartLimitLine = ChartLimitLine(limit: 10.0, label: "index 10")
        llXAxis.lineWidth = 4.0;
        llXAxis.lineDashLengths = [(10.0), (10.0), (0.0)];
        llXAxis.labelPosition = ChartLimitLine.LabelPosition.RightBottom;
        llXAxis.valueFont = UIFont.systemFontOfSize(10.0)
        
        let ll1:ChartLimitLine = ChartLimitLine(limit: 15000.0, label: "Goal: 15000")
        ll1.lineWidth = 2.0;
        ll1.lineDashLengths = [0.0, 0.0];
        ll1.lineColor = UIColor.blackColor()
        ll1.labelPosition = ChartLimitLine.LabelPosition.LeftTop;
        ll1.valueFont = UIFont.systemFontOfSize(10.0)
        
        let leftAxis:ChartYAxis = lineChartView.leftAxis;
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(ll1)
        leftAxis.axisMaxValue = 22000.0;
        leftAxis.axisMinValue = 0.0;
        leftAxis.gridLineDashLengths = [0.0, 0.0];
        leftAxis.labelTextColor = UIColor.blackColor()
        //leftAxis.axisLineColor = UIColor.whiteColor()
        //leftAxis.gridColor = UIColor.whiteColor()
        leftAxis.drawZeroLineEnabled = true;
        leftAxis.drawLimitLinesBehindDataEnabled = true;
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawLabelsEnabled = true
        lineChartView.rightAxis.enabled = true;
        
        let rightAxis:ChartYAxis = lineChartView.rightAxis;
        rightAxis.drawZeroLineEnabled = false;
        rightAxis.drawLimitLinesBehindDataEnabled = true;
        rightAxis.axisLineColor = AppTheme.NEVO_SOLAR_GRAY()
        rightAxis.drawGridLinesEnabled = false;
        rightAxis.drawLimitLinesBehindDataEnabled = false
        rightAxis.drawLabelsEnabled = false;
        rightAxis.drawZeroLineEnabled = false
        
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
        lineChartView.animate(xAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInOutQuart)
    }

    func setTitle(title:String) {
        titleLabel.text = title
    }
    
    func updateChartData(dataArray:NSArray,chartType:Int) {
        lineChartView.data = nil
        
        switch chartType {
        case 0:
            self.setStepsDataCount(dataArray, range: 100)
        case 1:
            self.setStepsDataCount(dataArray, range: 100)
        case 2:
            self.setStepsDataCount(dataArray, range: 100)
        default: break
        }
    }
    
    func setStepsDataCount(countArray:NSArray,range:Double) {
        var xVals:[String] = []
        var yVals:[ChartDataEntry] = []
        sortArray.addObjectsFromArray(countArray as [AnyObject])
        
        for i:Int in 0 ..< countArray.count {
            /**
             *  Data sorting,Small to large sort
             */
            for j:Int in i ..< countArray.count {
                let iSteps:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                let jSteps:UserSteps = sortArray.objectAtIndex(j) as! UserSteps;
                let iStepsDate:Double = iSteps.date
                let jStepsDate:Double = jSteps.date
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = sortArray.objectAtIndex(i) as! UserSteps;
                    sortArray.replaceObjectAtIndex(i, withObject: sortArray[j])
                    sortArray.replaceObjectAtIndex(j, withObject: temp)
                }
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
            //let mult:Double = range + 10000.0
            //let val:Double = Double(arc4random_uniform(UInt32(mult)) + 3000)
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

    func setSleepDataCount(count:Int,range:Double) {
        var xVals:[String] = []
        for i:Int in 0..<count {
            xVals.append("\(i)")
        }
        
        var yVals:[ChartDataEntry] = []
        
        for i:Int in 0..<count {
            let mult:Double = range + 10000.0
            let val:Double = Double(arc4random_uniform(UInt32(mult)) + 3000)
            yVals.append(ChartDataEntry(value: val, xIndex: i))
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
    
    func setSloarDataCount(count:Int,range:Double) {
        var xVals:[String] = []
        for i:Int in 0..<count {
            xVals.append("\(i)")
        }
        
        var yVals:[ChartDataEntry] = []
        
        for i:Int in 0..<count {
            let mult:Double = range + 10000.0
            let val:Double = Double(arc4random_uniform(UInt32(mult)) + 3000)
            yVals.append(ChartDataEntry(value: val, xIndex: i))
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
