//
//  TutorialPageSix2.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialPageSix2: UIViewController{
    
    @IBOutlet weak var tapToContinueButton: UIButton!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func tapToContinueAction(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}