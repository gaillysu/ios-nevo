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

    init() {
        super.init(nibName: "TutorialFourViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
    }

    @IBAction func nextAction(sender: AnyObject) {
        let tutorialFive = TutorialFiveViewController()
        self.navigationController?.pushViewController(tutorialFive, animated: true)
    }
}