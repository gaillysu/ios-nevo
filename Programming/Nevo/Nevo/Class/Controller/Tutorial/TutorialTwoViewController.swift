//
//  TutorialPageTwo.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialTwoViewController: UIViewController {

    @IBOutlet weak var turnBluetoothOnButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    
    
    init() {
        super.init(nibName: "TutorialTwoViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        styleEvolve()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
//            centerImageView.image = AppTheme.GET_RESOURCES_IMAGE("tutorial_lunar_2")
        }
    }
    
    @IBAction func turnBluetoothOnAction(_ sender: AnyObject) {
        let tutorialTwo = TutorialThreeViewController()
        self.navigationController?.pushViewController(tutorialTwo, animated: true)
    }
}

extension TutorialTwoViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            turnBluetoothOnButton.backgroundColor = UIColor.getBaseColor()
            turnBluetoothOnButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
}
