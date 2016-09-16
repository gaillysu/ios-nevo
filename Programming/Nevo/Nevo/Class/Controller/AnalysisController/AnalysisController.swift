//
//  SleepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AnalysisController: PublicClassController {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    let titleArray:[String] = ["This week","Last week","Last 30 Day"]
    private var contentTitleArray:[String] = [NSLocalizedString("Average Steps", comment: ""), NSLocalizedString("Total Steps", comment: ""), NSLocalizedString("Average Calories", comment: ""),NSLocalizedString("Average Time", comment: "")]
    private var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
    private var dataArray:NSMutableArray = NSMutableArray(capacity:3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dict:[String : AnyObject] = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        segmented.setTitleTextAttributes(dict, forState: UIControlState.Selected)
        
        contentCollectionView.backgroundColor = UIColor.whiteColor()
        chartsCollectionView.backgroundColor = UIColor.clearColor()
        chartsCollectionView.registerNib(UINib(nibName: "AnalysisRadarViewCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisRadar_Identifier")
        chartsCollectionView.registerNib(UINib(nibName: "AnalysisLineChartCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisLineChart_Identifier")
        chartsCollectionView.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ChartsViewHeader_Identifier")
        contentCollectionView.registerNib(UINib(nibName: "AnalysisValueCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisValue_Identifier")
        dataArray.addObjectsFromArray(self.getStepsData())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AnalysisController {
    @IBAction func segmentedAction(sender: AnyObject) {
        let segment:UISegmentedControl = sender as! UISegmentedControl
        dataArray.removeAllObjects()
        if segment.selectedSegmentIndex == 0 {
            dataArray.addObjectsFromArray(self.getStepsData())
            chartsCollectionView.reloadData()
        }else if segment.selectedSegmentIndex == 1 {
            dataArray.addObjectsFromArray(self.getSleepData())
            chartsCollectionView.reloadData()
        }else{
            dataArray.addObjectsFromArray(self.getStepsData())
            chartsCollectionView.reloadData()
        }
    }
    
    func getStepsData()->[NSArray] {
        let dayDate:NSDate = NSDate()
        let thisWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
        let lastWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7+1)) AND \(dayDate.beginningOfWeek.timeIntervalSince1970+1)")
        let last30DayArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)) AND \(dayDate.endOfDay.timeIntervalSince1970)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
    
    func getSleepData()->[NSArray] {
        let nextDay:Double = 86401
        
        let dayDate:NSDate = NSDate()
        let thisWeekArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-nextDay) AND \(dayDate.endOfWeek.timeIntervalSince1970+nextDay)")
        let lastWeekArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7)-nextDay) AND \(dayDate.beginningOfWeek.timeIntervalSince1970+nextDay)")
        let last30DayArray:NSArray = UserSleep.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)-nextDay) AND \(dayDate.endOfDay.timeIntervalSince1970+nextDay)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
    
    func getSolarData()->[NSArray] {
        let dayDate:NSDate = NSDate()
        let thisWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-1) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
        let lastWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7)-1) AND \(dayDate.beginningOfWeek.timeIntervalSince1970)")
        let last30DayArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfDay.timeIntervalSince1970-(86400.0*30)) AND \(dayDate.endOfDay.timeIntervalSince1970)")
        return [thisWeekArray,lastWeekArray,last30DayArray]
    }
}

extension AnalysisController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        if collectionView.isEqual(chartsCollectionView) {
            return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height)
        }else{
            if segmented.selectedSegmentIndex == 2 {
                return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height/2.0)
            }
            return CGSizeMake(collectionView.frame.size.width/2.0, collectionView.frame.size.height/2.0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(chartsCollectionView){
            return titleArray.count
        }else{
            return contentTitleArray.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(chartsCollectionView) {
            let cell:AnalysisLineChartCell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisLineChart_Identifier", forIndexPath: indexPath) as! AnalysisLineChartCell
            cell.backgroundColor = UIColor.clearColor()
            cell.setTitle(titleArray[indexPath.row])
            if segmented.selectedSegmentIndex == 0 {
                contentTitleArray = [NSLocalizedString("Average Steps", comment: ""), NSLocalizedString("Total Steps", comment: ""), NSLocalizedString("Average Calories", comment: ""),NSLocalizedString("Average Time", comment: "")]
            }
            if segmented.selectedSegmentIndex == 1 {
                contentTitleArray = [NSLocalizedString("Average Sleep", comment: ""), NSLocalizedString("Total Sleep", comment: ""), NSLocalizedString("Average Wake", comment: ""),NSLocalizedString("Quality", comment: "")]
            }
            
            if segmented.selectedSegmentIndex == 2 {
                contentTitleArray = [NSLocalizedString("Average Timer on Battery", comment: ""), NSLocalizedString("Average Timer on Solar", comment: "")]
            }
            
            if segmented.selectedSegmentIndex != 2 {
                var avgNumber:Float = 0
                if indexPath.row == 0 || indexPath.row == 1 {
                    avgNumber = 7
                }else{
                    avgNumber = 30
                }
                
                cell.updateChartData(dataArray[indexPath.row] as! NSArray, chartType: segmented.selectedSegmentIndex,rowIndex:indexPath.row, completionData: { (totalValue, totalCalores, totalTime) in
                    self.contentTArray.replaceRange(Range(0..<1), with: [String(format: "%.1f",totalValue/avgNumber)])
                    self.contentTArray.replaceRange(Range(1..<2), with: [String(format: "%.1f",totalValue)])
                    self.contentTArray.replaceRange(Range(2..<3), with: [String(format: "%.1f",totalCalores/Int(avgNumber))])
                    self.contentTArray.replaceRange(Range(3..<4), with: [String(format: "%.1f",totalTime/Int(avgNumber))])
                });
                contentCollectionView.reloadData()
            }else{
                self.contentTArray.replaceRange(Range(0..<1), with: [String(format: "0")])
                self.contentTArray.replaceRange(Range(1..<2), with: [String(format: "0")])
                
                cell.updateChartData(dataArray[indexPath.row] as! NSArray, chartType: segmented.selectedSegmentIndex,rowIndex:indexPath.row, completionData: { (totalValue, totalCalores, totalTime) in
                
                });
                contentCollectionView.reloadData()
            }
            
            return cell
        }else{
            let cell:AnalysisValueCell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisValue_Identifier", forIndexPath: indexPath) as! AnalysisValueCell
            cell.backgroundColor = UIColor.clearColor()
            cell.titleLabel.text = contentTitleArray[indexPath.row]
            var unit:String = ""
            if segmented.selectedSegmentIndex == 1 {
                switch indexPath.row {
                case 0:
                    unit = "h"
                    break
                case 1:
                    unit = "h"
                    break
                case 2:
                    unit = "h"
                    break
                case 3:
                    unit = "%"
                    break
                default:
                    break
                }
            }
            //cell.valueLabel.text = contentTArray[indexPath.row]+" "+unit
            cell.updateLabel(contentTArray[indexPath.row]+" "+unit)
            return cell
        }
    }
}
