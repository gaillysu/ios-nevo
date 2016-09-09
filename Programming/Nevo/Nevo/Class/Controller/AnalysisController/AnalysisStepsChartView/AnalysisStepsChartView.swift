//
//  AnalysisStepsChartView.swift
//  Drone
//
//  Created by Karl-John on 29/4/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Charts

class AnalysisStepsChartView: LineChartView {

    private var xVals:[String] = [];
    private var yVals:[[Double]] = [];
    
    func drawSettings(xAxis:ChartXAxis, yAxis:ChartYAxis, rightAxis:ChartYAxis){
        noDataText = NSLocalizedString("no_sleep_data", comment: "")
        descriptionText = ""
        dragEnabled = false
        setScaleEnabled(false)
        pinchZoomEnabled = false
        legend.enabled = false
        self.rightAxis.enabled = false;
        
        //rightAxis.enabled = true
        rightAxis.axisLineColor = UIColor.whiteColor()
        rightAxis.drawGridLinesEnabled = false;
        rightAxis.drawLimitLinesBehindDataEnabled = false
        rightAxis.drawLabelsEnabled = false;
        rightAxis.drawZeroLineEnabled = false

        yAxis.axisLineColor = UIColor.whiteColor()
        yAxis.drawGridLinesEnabled = false
        yAxis.drawLabelsEnabled = false
        yAxis.drawZeroLineEnabled = true
        
        xAxis.labelTextColor = UIColor.blackColor();
        xAxis.axisLineColor = UIColor.blackColor()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        
        //let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont(name: "Helvetica-Light", size: 11)!, insets: UIEdgeInsetsMake(8.0, 8.0, 15.0, 8.0))
        //marker.minimumSize = CGSizeMake(60, 25);
        //self.marker = marker;
    }
    
    func addDataPoint(name:String, entry:[Double]){
        xVals.append(name);
        yVals.append(entry)
    }
    
    func invalidateChart() {
        var dataSets:[LineChartDataSet] = []
        var chartDataArray:[BarChartDataEntry] = []
        var maxValue:Double = 0
        for (index,vlaue) in yVals.enumerate() {
            let chartData1:BarChartDataEntry = BarChartDataEntry(value: 60-vlaue[2], xIndex:index)
            chartDataArray.append(chartData1)
            
            if maxValue < 60-vlaue[2]{
               maxValue = 60-vlaue[2]
            }
        }
        
        self.setLeftAxisLimitLine(maxValue)
        
        let lineChartDataSet = LineChartDataSet(yVals: chartDataArray, label: "");
        lineChartDataSet.setColor(UIColor.whiteColor())
        lineChartDataSet.lineWidth = 1.5
        lineChartDataSet.circleRadius = 0.0
        lineChartDataSet.mode = LineChartDataSet.Mode.CubicBezier
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.valueFont = UIFont.systemFontOfSize(9.0)
        let gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().CGColor,AppTheme.NEVO_SOLAR_YELLOW().CGColor];
        let gradient:CGGradientRef = CGGradientCreateWithColors(nil, gradientColors, nil)!
        lineChartDataSet.fillAlpha = 1;
        lineChartDataSet.fill = ChartFill.fillWithLinearGradient(gradient, angle: 80.0)
        lineChartDataSet.drawFilledEnabled = true
        dataSets.append(lineChartDataSet)
        
        let lineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        lineChartData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 7.0))
        lineChartData.setDrawValues(false)
        data = lineChartData
        animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    private func setLeftAxisLimitLine(max:Double) {
        // x-axis limit line
        let leftAxis:ChartYAxis = self.leftAxis;
        leftAxis.labelCount = 3
        leftAxis.removeAllLimitLines()
        let valueString:[String] = ["Deep Sleep","Light Sleep","Awake"]
        
        let ll1:ChartLimitLine = ChartLimitLine(limit: Double(5), label: valueString[0])
        ll1.lineWidth = 0.5;
        ll1.lineDashLengths = [0.0, 0.0];
        ll1.lineColor = UIColor.blackColor()
        ll1.labelPosition = ChartLimitLine.LabelPosition.LeftTop;
        ll1.valueFont = UIFont.systemFontOfSize(10.0)
        leftAxis.addLimitLine(ll1)
        
        let ll2:ChartLimitLine = ChartLimitLine(limit: max/2.0+5, label: valueString[1])
        ll2.lineWidth = 0.5;
        ll2.lineDashLengths = [0.0, 0.0];
        ll2.lineColor = UIColor.blackColor()
        ll2.labelPosition = ChartLimitLine.LabelPosition.LeftTop;
        ll2.valueFont = UIFont.systemFontOfSize(10.0)
        leftAxis.addLimitLine(ll2)
        
        let ll3:ChartLimitLine = ChartLimitLine(limit: max/2.0+5, label: valueString[1])
        ll3.lineWidth = 0.5;
        ll3.lineDashLengths = [0.0, 0.0];
        ll3.lineColor = UIColor.blackColor()
        ll3.labelPosition = ChartLimitLine.LabelPosition.LeftTop;
        ll3.valueFont = UIFont.systemFontOfSize(10.0)
        leftAxis.addLimitLine(ll3)
        
    }
    
    func getYVals()->[[Double]]{
        return yVals;
    }
    
    func getXVals()->[String]{
        return xVals;
    }
    
    func reset(){
        xVals.removeAll();
        yVals.removeAll();
    }
}