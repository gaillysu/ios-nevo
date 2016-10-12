//
//  TutorialPageSeven.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialSevenViewController: UIViewController {
    
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!

    init() {
        super.init(nibName: "TutorialSevenViewController", bundle: Bundle.main)
        styleEvolve()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
    }
    @IBAction func tryAgainAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TutorialSevenViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            tryAgainButton.backgroundColor = UIColor.getBaseColor()
        }
    }
}
