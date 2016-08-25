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
    private var contentTitleArray:[String] = [NSLocalizedString("AVG Steps", comment: ""), NSLocalizedString("Total Steps", comment: ""), NSLocalizedString("AVG Calories", comment: ""),NSLocalizedString("AVG Time", comment: "")]
    private var contentTArray:[String] = [NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: ""),NSLocalizedString("--", comment: "")]
    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisLineChart_Identifier", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.clearColor()
            (cell as! AnalysisLineChartCell).setTitle(titleArray[indexPath.row])
            return cell
        }else{
            let cell:AnalysisValueCell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisValue_Identifier", forIndexPath: indexPath) as! AnalysisValueCell
            cell.backgroundColor = UIColor.clearColor()
            cell.titleLabel.text = contentTitleArray[indexPath.row]
            return cell
        }
    }
}
