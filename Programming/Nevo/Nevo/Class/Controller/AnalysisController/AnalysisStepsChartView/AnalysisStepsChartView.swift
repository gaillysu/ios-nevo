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
        rightAxis.enabled = true

        //let goal:UserGoal = UserGoal.getAll()[0] as! UserGoal
        let limitLine = ChartLimitLine(limit: Double(500),label: "Goal");
        limitLine.lineWidth = 1.5
        limitLine.labelPosition = ChartLimitLine.LabelPosition.LeftTop
        limitLine.valueFont = UIFont(name: "Helvetica-Light", size: 7)!
        limitLine.lineColor = UIColor.whiteColor()
        
        rightAxis.axisLineColor = UIColor.whiteColor()
        rightAxis.drawGridLinesEnabled = false;
        rightAxis.drawLimitLinesBehindDataEnabled = false
        rightAxis.drawLabelsEnabled = false;
        rightAxis.drawZeroLineEnabled = false
        
        //yAxis.axisMaxValue = Double(1000)
        //yAxis.axisMinValue = 0
        yAxis.axisLineColor = UIColor.whiteColor()
        yAxis.drawGridLinesEnabled = false
        yAxis.drawLabelsEnabled = false
        yAxis.drawZeroLineEnabled = true
        yAxis.addLimitLine(limitLine)
        
        xAxis.labelTextColor = UIColor.whiteColor();
        xAxis.axisLineColor = UIColor.whiteColor()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let marker:BalloonMarker = BalloonMarker(color: UIColor.getBaseColor(), font: UIFont(name: "Helvetica-Light", size: 11)!, insets: UIEdgeInsetsMake(8.0, 8.0, 15.0, 8.0))
        marker.minimumSize = CGSizeMake(60, 25);
        self.marker = marker;
    }
    
    func addDataPoint(name:String, entry:[Double]){
        xVals.append(name);
        yVals.append(entry)
    }
    
    func invalidateChart() {
        var dataSets:[LineChartDataSet] = []
        for mIndex in 0..<3 {
            var chartDataArray:[BarChartDataEntry] = []
            for (index,vlaue) in yVals.enumerate() {
                let chartData1:BarChartDataEntry = BarChartDataEntry(value: vlaue[mIndex], xIndex:index)
                chartDataArray.append(chartData1)
            }
            
            let lineChartDataSet = LineChartDataSet(yVals: chartDataArray, label: "");
            lineChartDataSet.setColor(UIColor.whiteColor())
            lineChartDataSet.lineWidth = 1.5
            lineChartDataSet.circleRadius = 0.0
            lineChartDataSet.drawCircleHoleEnabled = false
            lineChartDataSet.valueFont = UIFont.systemFontOfSize(9.0)
            
            let gradientColors = [UIColor.getTintColor(),UIColor.getBaseColor(),UIColor.getGreyColor()]
            lineChartDataSet.fillAlpha = 0.3;
            lineChartDataSet.fill = ChartFill.fillWithColor(gradientColors[mIndex])
            lineChartDataSet.drawFilledEnabled = true
            dataSets.append(lineChartDataSet)
        }
        
        let lineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        lineChartData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 7.0))
        lineChartData.setDrawValues(false)
        data = lineChartData
        animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    
    func reset(){
        xVals.removeAll();
        yVals.removeAll();
    }
}