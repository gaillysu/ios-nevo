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
    private var onTitle:[String] = ["Timer on Battery","Timer on Solar"]
    private var onValue:[Double] = [130,250]
    
    init() {
        super.init(nibName: "SolarIndicatorController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textCollection.registerNib(UINib(nibName: "SolarInforViewCell",bundle: nil), forCellWithReuseIdentifier: "SolarInfor_Identifier")
        
        self.setupPieChartView(pieChartView)
        pieChartView.legend.enabled = false;
        pieChartView.delegate = self
        self.updateChartData()
        pieChartView.animate(xAxisDuration: 1.4, easingOption: ChartEasingOption.EaseOutBack)
        pieChartView.backgroundColor = UIColor.getGreyColor()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor.getGreyColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - UICollectionViewDelegate
extension SolarIndicatorController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionView.frame.size.width, 40)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onTitle.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SolarInfor_Identifier", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        (cell as! SolarInforViewCell).titleLabel.text = onTitle[indexPath.row]
        if onValue.count>0 {
            (cell as! SolarInforViewCell).valueLabel.text = String(format: "%dh %dmin", Int(onValue[indexPath.row])/60,Int(onValue[indexPath.row])%60)
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

    func setupPieChartView(chartView:PieChartView) {
        
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.0
        chartView.transparentCircleRadiusPercent = 0.0
        chartView.descriptionText = ""
        chartView.setExtraOffsets(left: 5.0, top: 10.0, right: 5.0, bottom: 5.0)
        chartView.drawCenterTextEnabled = true
        let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.Center
        let centerText:NSMutableAttributedString = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
        
        centerText.setAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 13.0)!], range: NSMakeRange(0, centerText.length))
        centerText.addAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 11.0)!,NSForegroundColorAttributeName:UIColor.grayColor()], range: NSMakeRange(10, centerText.length - 10))
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
    
    func setDataCount(count:Int,range:Double) {
        let mult:Double = range
        var yVals1:[ChartDataEntry] = []
        for i:Int in 0..<count {
            let value:Double = Double(arc4random_uniform(UInt32(mult) + UInt32(mult/5)))
            yVals1.append(BarChartDataEntry(value: value , xIndex: i))
        }
        
        var xVals:[String] = []
        
        for i:Int in 0..<count {
            xVals.append("\(i)")
        }
        
        let dataSet:PieChartDataSet = PieChartDataSet(yVals: yVals1, label: "Election Results")
        dataSet.sliceSpace = 2.0;
        var colors:[UIColor] = [];
        colors.append(UIColor(red: 179/255, green: 126/255, blue: 189/255, alpha: 1))
        colors.append(UIColor.getBaseColor())
        dataSet.colors = colors
        
        let data:PieChartData = PieChartData(xVals: xVals, dataSets: [dataSet])
        //data.highlightEnabled = false
        let pFormatter:NSNumberFormatter = NSNumberFormatter()
        pFormatter.numberStyle = NSNumberFormatterStyle.PercentStyle;
        pFormatter.maximumFractionDigits = 1;
        pFormatter.multiplier = 1.0;
        pFormatter.percentSymbol = " %";
        
        
        data.setValueFormatter(pFormatter)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 11.0))
        data.setValueTextColor(UIColor.blackColor())
        pieChartView.data = data;
        pieChartView.highlightValues(nil)
    }

}
