//
//  SolarIndicatorController.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/1.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Charts

class SolarIndicatorController: PublicClassController {

    @IBOutlet weak var textCollection: UICollectionView!
    @IBOutlet weak var pieChartView: PieChartView!
    fileprivate var onTitle:[String] = ["Timer on Battery","Timer on Solar"]
    fileprivate var onValue:[Double] = [130,250]
    
    init() {
        super.init(nibName: "SolarIndicatorController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textCollection.backgroundColor = UIColor.white
        textCollection.register(UINib(nibName: "SolarInforViewCell",bundle: nil), forCellWithReuseIdentifier: "SolarInfor_Identifier")
        
        self.setupPieChartView(pieChartView)
        pieChartView.legend.enabled = false;
        pieChartView.delegate = self
        self.updateChartData()
        pieChartView.animate(xAxisDuration: 1.4, easingOption: ChartEasingOption.EaseOutBack)
        pieChartView.backgroundColor = UIColor.whiteColor()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        pieChartView.animate(xAxisDuration: 1.4, easingOption: ChartEasingOption.EaseOutBack)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - UICollectionViewDelegate
extension SolarIndicatorController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 40)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onTitle.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SolarInfor_Identifier", for: indexPath)
        cell.backgroundColor = UIColor.white
        (cell as! SolarInforViewCell).titleLabel.text = onTitle[(indexPath as NSIndexPath).row]
        if onValue.count>0 {
            (cell as! SolarInforViewCell).valueLabel.text = String(format: "%dh %dmin", Int(onValue[(indexPath as NSIndexPath).row])/60,Int(onValue[(indexPath as NSIndexPath).row])%60)
        }
        return cell
    }
}

// MARK: - ChartViewDelegate
extension SolarIndicatorController:ChartViewDelegate {
    func updateChartData() {
        pieChartView.data = nil
        self.setDataCount(2, range: 100)
    }

    func setupPieChartView(_ chartView:PieChartView) {
        
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.0
        chartView.transparentCircleRadiusPercent = 0.0
        chartView.descriptionText = ""
        chartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        chartView.drawCenterTextEnabled = true
        let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.center
        let centerText:NSMutableAttributedString = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
        
        centerText.setAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 13.0)!], range: NSMakeRange(0, centerText.length))
        centerText.addAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 11.0)!,NSForegroundColorAttributeName:UIColor.gray], range: NSMakeRange(10, centerText.length - 10))
        centerText.addAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-LightItalic", size: 11.0)!,NSForegroundColorAttributeName:UIColor(red: 51.0/255.0, green: 181.0/255.0, blue: 229.0/255.0, alpha: 1.0)], range: NSMakeRange(centerText.length - 19, 19))
        //let marker:BalloonMarker = BalloonMarker(color: UIColor.getBaseColor(), font: UIFont(name: "Helvetica-Light", size: 11)!, insets: UIEdgeInsetsMake(8.0, 8.0, 15.0, 8.0))
        //marker.minimumSize = CGSizeMake(60, 25);
        //chartView.marker = marker
        chartView.centerAttributedText = centerText
        chartView.drawCenterTextEnabled = false
        chartView.drawHoleEnabled = true;
        chartView.rotationAngle = 0.0;
        chartView.rotationEnabled = true;
        chartView.highlightPerTapEnabled = true;
        
        let l:ChartLegend = chartView.legend;
        l.position = ChartLegend.Position.RightOfChart;
        l.xEntrySpace = 7.0;
        l.yEntrySpace = 0.0;
        l.yOffset = 0.0;
        
    }
    
    func setDataCount(_ count:Int,range:Double) {
        let mult:Double = range
        var yVals1:[ChartDataEntry] = []
        for i:Int in 0..<count {
            let value:Double = Double(arc4random_uniform(UInt32(mult) + UInt32(mult/5)))
            yVals1.append(BarChartDataEntry(value: value , xIndex: i))
        }
        
        var xVals:[String] = []
        
        xVals.append("Solar")
        xVals.append("Battery")
        let dataSet:PieChartDataSet = PieChartDataSet(yVals: yVals1, label: "Election Results")
        dataSet.sliceSpace = 2.0;
        var colors:[UIColor] = [];
        colors.append(AppTheme.NEVO_SOLAR_YELLOW())
        colors.append(AppTheme.NEVO_SOLAR_DARK_GRAY())
        dataSet.colors = colors
        
        let data:PieChartData = PieChartData(xVals: xVals, dataSets: [dataSet])
        //data.highlightEnabled = false
        let pFormatter:NumberFormatter = NumberFormatter()
        pFormatter.numberStyle = NumberFormatter.Style.percent;
        pFormatter.maximumFractionDigits = 1;
        pFormatter.multiplier = 1.0;
        pFormatter.percentSymbol = " %";
        
        
        data.setValueFormatter(pFormatter)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 16.0))
        data.setValueTextColor(UIColor.whiteColor())
        pieChartView.data = data;
        pieChartView.highlightValues(nil)
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
    
    }
}
