//
//  TutorialPageThree.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialThreeViewController: UIViewController {
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        let tutorialFour = TutorialFourViewController()
        self.navigationController?.pushViewController(tutorialFour, animated: true)

    }
}