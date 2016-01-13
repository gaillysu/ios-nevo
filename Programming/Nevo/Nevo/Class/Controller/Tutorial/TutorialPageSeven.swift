//
//  TutorialPageSeven.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialPageSeven: UIViewController {
    
    @IBOutlet weak var tryAgainButton: UIButton!
    
    override func viewDidLoad() {
        
    }
    @IBAction func tryAgainAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}