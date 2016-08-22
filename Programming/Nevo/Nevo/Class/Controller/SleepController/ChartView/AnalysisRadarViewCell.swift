//
//  AnalysisRadarViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/9.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Charts

class AnalysisRadarViewCell: UICollectionViewCell,ChartViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var radarChartView: RadarChartView!
    
    var parties:[String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        parties = [
        "Party A", "Party B", "Party C", "Party D", "Party E", "Party F",
        "Party G", "Party H", "Party I", "Party J", "Party K", "Party L",
        "Party M", "Party N", "Party O", "Party P", "Party Q", "Party R",
        "Party S", "Party T", "Party U", "Party V", "Party W", "Party X",
        "Party Y", "Party Z"
        ];
        
        radarChartView.delegate = self;
        
        radarChartView.descriptionText = "";
        radarChartView.webLineWidth = 0.75;
        radarChartView.innerWebLineWidth = 0.375;
        radarChartView.webAlpha = 1.0;
        
        let marker:BalloonMarker = BalloonMarker(color: UIColor(white: 180/255.0, alpha: 1.0), font: UIFont.systemFontOfSize(12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.minimumSize = CGSizeMake(80.0, 40.0);
        radarChartView.marker = marker;
        
        let xAxis:ChartXAxis = radarChartView.xAxis;
        xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 9.0)!
        xAxis.labelTextColor = UIColor.whiteColor()
        
        let yAxis:ChartYAxis = radarChartView.yAxis;
        yAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 9.0)!
        yAxis.labelTextColor = UIColor.whiteColor()
        yAxis.labelCount = 5;
        yAxis.axisMinValue = 0.0;
        
        let l:ChartLegend = radarChartView.legend;
        l.position = ChartLegend.Position.RightOfChart;
        l.font = UIFont(name: "HelveticaNeue-Light", size: 10.0)!
        l.xEntrySpace = 7.0;
        l.yEntrySpace = 5.0;
        
        self.updateChartData()
        radarChartView.animate(xAxisDuration: 1.4, easingOption: ChartEasingOption.EaseOutBack)

    }

    func updateChartData() {
        radarChartView.data = nil
        self.setChartData()
    }
    
    func setChartData() {
        let mult:Double = 150.0;
        let count:Int = 9;
        
        var yVals1:[ChartDataEntry] = [];
        var yVals2:[ChartDataEntry] = [];
        
        for i:Int in 0..<count {
            yVals1.append(ChartDataEntry(value: Double(arc4random_uniform(UInt32(mult)) + UInt32(mult)/2), xIndex: i))
            yVals2.append(ChartDataEntry(value: Double(arc4random_uniform(UInt32(mult)) + UInt32(mult)/2), xIndex: i))
        }

        
        var xVals:[String] = [];
        for i:Int in 0..<count {
            xVals.append(parties[i%parties.count])
        }
        
        let set1:RadarChartDataSet = RadarChartDataSet(yVals: yVals1, label: "Set 1")
        set1.setColor(UIColor.getBaseColor())
        set1.fillColor = UIColor.getBaseColor();
        set1.drawFilledEnabled = true;
        set1.lineWidth = 0.3;
        
        let set2:RadarChartDataSet = RadarChartDataSet(yVals: yVals2, label: "Set 2")

        set2.setColor(UIColor.getTintColor())
        set2.fillColor = UIColor.getTintColor()
        set2.drawFilledEnabled = true;
        set2.lineWidth = 0.3;
        
        let data:RadarChartData = RadarChartData(xVals: xVals, dataSets: [set1, set2])
        data.setValueTextColor(UIColor.whiteColor())
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8.0))
        data.setDrawValues(false)
        radarChartView.data = data;
    }

}
