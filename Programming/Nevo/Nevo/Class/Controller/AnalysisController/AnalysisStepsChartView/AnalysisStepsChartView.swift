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

    fileprivate var xVals:[String] = [];
    fileprivate var yVals:[[Double]] = [];
    
    func drawSettings(_ xAxis:XAxis, yAxis:YAxis, rightAxis:YAxis){
        noDataText = NSLocalizedString("no_sleep_data", comment: "")
        chartDescription?.text = ""
        dragEnabled = false
        setScaleEnabled(false)
        pinchZoomEnabled = false
        legend.enabled = false
        self.rightAxis.enabled = false;
        
        //rightAxis.enabled = true
        rightAxis.axisLineColor = UIColor.white
        rightAxis.drawGridLinesEnabled = false;
        rightAxis.drawLimitLinesBehindDataEnabled = false
        rightAxis.drawLabelsEnabled = false;
        rightAxis.drawZeroLineEnabled = false

        yAxis.axisMaximum = 65
        yAxis.axisMinimum = 0
        yAxis.axisLineColor = UIColor.white
        yAxis.drawGridLinesEnabled = false
        yAxis.drawLabelsEnabled = false
        yAxis.drawZeroLineEnabled = true
        
        xAxis.labelTextColor = UIColor.black;
        xAxis.axisLineColor = UIColor.black
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 10)!
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            xAxis.labelTextColor = UIColor.white;
            xAxis.axisLineColor = UIColor.white
            yAxis.axisLineColor = UIColor.white
            yAxis.labelTextColor = UIColor.white
        }
        //let marker:BalloonMarker = BalloonMarker(color: AppTheme.NEVO_SOLAR_YELLOW(), font: UIFont(name: "Helvetica-Light", size: 11)!, insets: UIEdgeInsetsMake(8.0, 8.0, 15.0, 8.0))
        //marker.minimumSize = CGSizeMake(60, 25);
        //self.marker = marker;
    }
    
    func addDataPoint(_ name:String, entry:[Double]){
        xVals.append(name);
        yVals.append(entry)
    }
    
    func invalidateChart() {
        var dataSets:[LineChartDataSet] = []
        var chartDataArray:[BarChartDataEntry] = []
        
        for (index,vlaue) in yVals.enumerated() {
            //vlaue[2]->Deep Sleep, vlaue[1]->Light Sleep, vlaue[0]->Weake Sleep
            let chartData1:BarChartDataEntry = BarChartDataEntry(x: Double(index), y: vlaue[2])
            chartDataArray.append(chartData1)
        }
        
        let formatter:ChartFormatter = ChartFormatter(xVals)
        let xaxis:XAxis = XAxis()
        for (index,vlaue) in xVals.enumerated() {
            let array = (vlaue as String).components(separatedBy: ":")
            _ = formatter.stringForValue(Double(index), axis: nil)
        }
        xaxis.valueFormatter = formatter
        self.xAxis.valueFormatter = xaxis.valueFormatter
        
        self.setLeftAxisLimitLine(65)
        
        let lineChartDataSet = LineChartDataSet(values: chartDataArray, label: "");
        lineChartDataSet.setColor(UIColor.white)
        lineChartDataSet.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        lineChartDataSet.lineWidth = 1.5
        lineChartDataSet.circleRadius = 0.0
        lineChartDataSet.mode = LineChartDataSet.Mode.cubicBezier
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.valueFont = UIFont.systemFont(ofSize: 9.0)
        var gradientColors:[CGColor] = [AppTheme.NEVO_SOLAR_GRAY().cgColor,AppTheme.NEVO_SOLAR_YELLOW().cgColor];
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            gradientColors = [UIColor.getBaseColor().cgColor,UIColor.getLightBaseColor().cgColor];
        }
        
        let gradient:CGGradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        lineChartDataSet.fillAlpha = 1;
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 80.0)
        lineChartDataSet.drawFilledEnabled = true
        dataSets.append(lineChartDataSet)
        
        let lineChartData = LineChartData(dataSets: dataSets)
            //LineChartData(xVals: xVals, dataSets: dataSets)
        lineChartData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 7.0))
        lineChartData.setDrawValues(false)
        data = lineChartData
        animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }
    
    fileprivate func setLeftAxisLimitLine(_ max:Double) {
        // x-axis limit line
        let leftAxis:YAxis = self.leftAxis;
        leftAxis.labelCount = 3
        leftAxis.removeAllLimitLines()
        let valueString:[String] = [NSLocalizedString("Awake", comment: ""),NSLocalizedString("light_sleep", comment: ""),NSLocalizedString("deep_sleep", comment: "")]
        
        let ll1:ChartLimitLine = ChartLimitLine(limit: Double(5), label: valueString[0])
        ll1.lineWidth = 0.5;
        ll1.lineDashLengths = [0.0, 0.0];
        ll1.lineColor = UIColor.black
        ll1.labelPosition = ChartLimitLine.LabelPosition.leftTop;
        ll1.valueFont = UIFont.systemFont(ofSize: 10.0)
        leftAxis.addLimitLine(ll1)
        
        let ll2:ChartLimitLine = ChartLimitLine(limit: max/2.0-5, label: valueString[1])
        ll2.lineWidth = 0.5;
        ll2.lineDashLengths = [0.0, 0.0];
        ll2.lineColor = UIColor.black
        ll2.labelPosition = ChartLimitLine.LabelPosition.leftTop;
        ll2.valueFont = UIFont.systemFont(ofSize: 10.0)
        leftAxis.addLimitLine(ll2)
        
        let ll3:ChartLimitLine = ChartLimitLine(limit: max-5, label: valueString[2])
        ll3.lineWidth = 0.5;
        ll3.lineDashLengths = [0.0, 0.0];
        ll3.lineColor = UIColor.black
        ll3.labelPosition = ChartLimitLine.LabelPosition.leftTop;
        ll3.valueFont = UIFont.systemFont(ofSize: 10.0)
        leftAxis.addLimitLine(ll3)
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            ll1.lineColor = UIColor.white
            ll1.valueTextColor = UIColor.white
            ll2.lineColor = UIColor.white
            ll2.valueTextColor = UIColor.white
            ll3.lineColor = UIColor.white
            ll3.valueTextColor = UIColor.white
        }
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
