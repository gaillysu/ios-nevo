//
//  SleepTutorialController.swift
//  Nevo
//
//  Created by leiyuncun on 16/2/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SleepTutorialController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var centerImageView: UIImageView!
    
    init() {
        super.init(nibName: "SleepTutorialController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        styleEvolve()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonManager(_ sender: AnyObject) {
//        let nav:MorningTutorialController = MorningTutorialController()
//        self.presentViewController(nav, animated: true) { () -> Void in
//
//        }
        self.dismiss(animated: true) { () -> Void in
            
        }
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

extension SleepTutorialController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            nextStepButton.setTitleColor(UIColor.getBaseColor(), for: .normal)
        }
    }
}
