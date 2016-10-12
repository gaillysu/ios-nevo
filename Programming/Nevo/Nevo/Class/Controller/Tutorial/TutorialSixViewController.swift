//
//  TutorialPageSix2.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialSixViewController: UIViewController{
    
    @IBOutlet weak var tapToContinueButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!
    
    init() {
        super.init(nibName: "TutorialSixViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        print("LOLOL")
        
        styleEvolve()
    }
    
    @IBAction func tapToContinueAction(_ sender: AnyObject) {
        //self.navigationController?.popToRootViewControllerAnimated(true)
        //let tutorialPageSeven = TutorialSevenViewController();
        //self.navigationController?.pushViewController(tutorialPageSeven, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

extension TutorialSixViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            tapToContinueButton.backgroundColor = UIColor.getBaseColor()
        }
    }
}
