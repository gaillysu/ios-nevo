//
//  SolarIndicatorController.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/1.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import KDCircularProgress
import Charts

class SolarIndicatorController: PublicClassController {

    @IBOutlet weak var textCollection: UICollectionView!
    @IBOutlet weak var solarProgress: KDCircularProgress!
    @IBOutlet weak var chartView: LineChartView!
    
    init() {
        super.init(nibName: "SolarIndicatorController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
