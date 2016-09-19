//
//  TutorialPageThree.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialThreeViewController: UIViewController {

    init() {
        super.init(nibName: "TutorialThreeViewController", bundle: Bundle.mainBundle())
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
