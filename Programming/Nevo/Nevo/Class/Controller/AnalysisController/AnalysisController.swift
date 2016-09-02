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
            //chartsCollectionView.reloadData()
        }
    }
    
    func getStepsData()->[NSArray] {
        let dayDate:NSDate = NSDate()
        let thisWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-1) AND \(dayDate.endOfWeek.timeIntervalSince1970)")
        let lastWeekArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayDate.beginningOfWeek.timeIntervalSince1970-(86400.0*7)-1) AND \(dayDate.beginningOfWeek.timeIntervalSince1970)")
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
            if segmented.selectedSegmentIndex != 2 {
                var avgNumber:Int = 0
                if indexPath.row == 0 || indexPath.row == 1 {
                    avgNumber = 7
                }else{
                    avgNumber = 30
                }
                var avgSteps:Int = 0
                var totalSteps:Int = 0
                var avgCalores:Int = 0
                var avgTime:Int = 0
                
                if segmented.selectedSegmentIndex == 0 {
                    for (index,value) in (dataArray[indexPath.row] as! NSArray).enumerate() {
                        let usersteps:UserSteps = value as! UserSteps
                        avgSteps += usersteps.steps
                        totalSteps = usersteps.steps
                        avgCalores += Int(usersteps.calories)
                        avgTime += (usersteps.walking_duration+usersteps.running_duration)
                    }
                }
                
                contentTArray.replaceRange(Range(0..<1), with: ["\(avgSteps/avgNumber)"])
                contentTArray.replaceRange(Range(1..<2), with: ["\(totalSteps)"])
                contentTArray.replaceRange(Range(2..<3), with: ["\(avgCalores/avgNumber)"])
                contentTArray.replaceRange(Range(3..<4), with: ["\(avgTime/avgNumber)"])
                cell.updateChartData(dataArray[indexPath.row] as! NSArray,chartType: segmented.selectedSegmentIndex);
                contentCollectionView.reloadData()
            }
            
            return cell
        }else{
            let cell:AnalysisValueCell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisValue_Identifier", forIndexPath: indexPath) as! AnalysisValueCell
            cell.backgroundColor = UIColor.clearColor()
            cell.titleLabel.text = contentTitleArray[indexPath.row]
            cell.valueLabel.text = contentTArray[indexPath.row]
            return cell
        }
    }
}
