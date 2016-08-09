//
//  SleepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepController: PublicClassController {
    
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartsCollectionView.backgroundColor = UIColor.clearColor()
        chartsCollectionView.registerNib(UINib(nibName: "AnalysisRadarViewCell",bundle: nil), forCellWithReuseIdentifier: "AnalysisRadar_Identifier")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SleepController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.width)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnalysisRadar_Identifier", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
}
