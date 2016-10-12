//
//  TutorialPageFour.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialFourViewController: UIViewController{
    
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    
    init() {
        super.init(nibName: "TutorialFourViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        styleEvolve()
    }

    @IBAction func nextAction(_ sender: AnyObject) {
        let tutorialFive = TutorialFiveViewController()
        self.navigationController?.pushViewController(tutorialFive, animated: true)
    }
}

extension TutorialFourViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            nextButton.setTitleColor(UIColor.getBaseColor(), for: .normal)
        }
    }
}
