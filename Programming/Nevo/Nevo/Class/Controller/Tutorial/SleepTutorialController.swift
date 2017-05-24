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
        self.dismiss(animated: true) { () -> Void in
        }
    }
}

extension SleepTutorialController {
    fileprivate func styleEvolve() {
        
    }
}
