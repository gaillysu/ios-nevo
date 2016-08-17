//
//  SleepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepController: PublicClassController {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    let titleArray:[String] = ["This week","Last week","Last 30 Day"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dict:[String : AnyObject] = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        segmented.setTitleTextAttributes(dict, forState: UIControlState.Selected)
        
        chartsCollectionView.backgroundColor = UIColor.clearColor()
        chartsCollectionView.registerNib(UINib(nibName: "AnalysisRadarViewCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisRadar_Identifier")
        chartsCollectionView.registerNib(UINib(nibName: "AnalysisLineChartCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisLineChart_Identifier")
        chartsCollectionView.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ChartsViewHeader_Identifier")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SleepController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisLineChart_Identifier", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        (cell as! AnalysisLineChartCell).setTitle(titleArray[indexPath.row])
        return cell
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisRadar_Identifier", forIndexPath: indexPath)
//        cell.backgroundColor = UIColor.clearColor()
//        return cell
    }
}
