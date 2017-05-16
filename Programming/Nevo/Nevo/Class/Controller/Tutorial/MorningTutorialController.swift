//
//  MorningTutorialController.swift
//  Nevo
//
//  Created by leiyuncun on 16/2/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class MorningTutorialController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var nextStepButton: UIButton!
    
    init() {
        super.init(nibName: "MorningTutorialController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

