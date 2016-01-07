//
//  StepHistoricalView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class StepHistoricalView: UIView,ChartViewDelegate {

    @IBOutlet weak var chartView: BarChartView!
    private var queryModel:NSMutableArray = NSMutableArray()
    private let sleepArray:NSMutableArray = NSMutableArray();
    private let detailArray:NSMutableArray = NSMutableArray(capacity:1);

    func bulidStepHistoricalView(delegate:StepHistoricalViewController,modelArray:NSArray,navigation:UINavigationItem){
        queryModel.addObjectsFromArray(modelArray as [AnyObject])

        // MARK: - chartView?.marker
        chartView!.descriptionText = " ";
        chartView?.noDataText = NSLocalizedString("no_step_data", comment: "")
        chartView!.noDataTextDescription = "";
        chartView!.pinchZoomEnabled = false
        chartView!.drawGridBackgroundEnabled = false;
        chartView!.drawBarShadowEnabled = false;
        let xScale:CGFloat = CGFloat(queryModel.count)/7.0;//integer/integer = integer,float/float = float
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
                let iStepsModel:UserSteps = queryModel.objectAtIndex(i) as! UserSteps;
                let jStepsModel:UserSteps = queryModel.objectAtIndex(j) as! UserSteps;
                let iStepsDate:Double = iStepsModel.date
                let jStepsDate:Double = jStepsModel.date
                if (iStepsDate > jStepsDate){
                    let temp:UserSteps = queryModel.objectAtIndex(i) as! UserSteps;
                    queryModel.replaceObjectAtIndex(i, withObject: queryModel[j])
                    queryModel.replaceObjectAtIndex(j, withObject: temp)

                }
            }
        }
        //计算睡眠时间以中午12点为计算起点,

        for (var i:Int = 0; i < queryModel.count; i++){
            let seleModel:UserSteps = queryModel.objectAtIndex(i) as! UserSteps;
            let val1:Double  = Double(seleModel.steps);
            if(val1 == 0){
                continue
            }
            let mDateString:String = String(format: "%.0f", seleModel.date)
            let date:NSDate = NSDate(timeIntervalSince1970: seleModel.date)
            //mDateString.dateFromFormat("yyyyMMdd")!
            let dateString:NSString = date.stringFromFormat("yyyyMMdd")
            //stringFromDate(date) as NSString
            xVal.append("\(dateString.substringWithRange(NSMakeRange(6, 2)))/\(dateString.substringWithRange(NSMakeRange(4, 2)))")
            yVal.append(BarChartDataEntry(values: [val1], xIndex:i))
        }

        //According to at least seven days of data
        if(yVal.count<7){
            for (var s:Int  = yVal.count; s < 7; s++){
                xVal.append(" ")
                yVal.append(BarChartDataEntry(values: [0], xIndex:sleepArray.count))
            }
        }

        //柱状图表
        //ChartColorTemplates.getDeepSleepColor()
        let set1:BarChartDataSet  = BarChartDataSet(yVals: yVal, label: "")
        //每个数据区块的颜色
        set1.colors = [ChartColorTemplates.getStepsColor()];
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.highLightAlpha = 1
        set1.barSpace = 0.05;
        let dataSets:[BarChartDataSet] = [set1];

        let data:BarChartData = BarChartData(xVals: xVal, dataSets: dataSets)
        data.setDrawValues(false);//false 显示柱状图数值否则不显示

        chartView?.data = data;
        chartView?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
        chartView?.moveViewToX(yVal.count)
    }

    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {

        chartView.highlightValue(xIndex: entry.xIndex, dataSetIndex: dataSetIndex, callDelegate: false)

    }
    
    private func calculateMinutes(time:Double) -> (hours:Int,minutes:Int){
        return (Int(time),Int(60*(time%1)));
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
