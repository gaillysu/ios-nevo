//
//  TutorialPageOne.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialPageOne: UIViewController{
    
    @IBOutlet weak var activateYourNevoButton: UIButton!
    
    override func viewDidLoad() {
        activateYourNevoButton.backgroundColor = UIColor.clearColor()
        activateYourNevoButton.layer.cornerRadius = 5
        activateYourNevoButton.layer.borderWidth = 1
    }
    
    @IBAction func activateYourNevoAction(sender: AnyObject) {
        let btEnabled = AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled()
        if(btEnabled){
            let tutorialThree = TutorialPageThree()
            self.navigationController?.pushViewController(tutorialThree, animated: true)
        }else{
            let tutorialTwo = TutorialPageTwo()
            self.navigationController?.pushViewController(tutorialTwo, animated: true)
        }
    }
}