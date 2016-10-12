//
//  TutorialPageThree.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialThreeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var nextStepButton: UIButton!
    
    
    init() {
        super.init(nibName: "TutorialThreeViewController", bundle: Bundle.main)
        styleEvolve()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
    }
    
    @IBAction func nextAction(_ sender: AnyObject) {
        let tutorialFour = TutorialFourViewController()
        self.navigationController?.pushViewController(tutorialFour, animated: true)

    }
}

extension TutorialThreeViewController {
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
