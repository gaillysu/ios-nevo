//
//  TutorialPageFour.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialPageFour: UIViewController{
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        
    }

    @IBAction func nextAction(sender: AnyObject) {
        let tutorialFive = TutorialPageFive()
        self.navigationController?.pushViewController(tutorialFive, animated: true)
    }
}