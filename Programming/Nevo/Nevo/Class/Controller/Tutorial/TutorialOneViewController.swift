//
//  TutorialPageOne.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialOneViewController: UIViewController{

    init() {
        super.init(nibName: "TutorialOneViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {   
    }
    
    @IBAction func activateYourNevoAction(sender: AnyObject) {
        let btEnabled = AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled()
        if(btEnabled){
            let tutorialThree = TutorialThreeViewController()
            self.navigationController?.pushViewController(tutorialThree, animated: true)
        }else{
            let tutorialTwo = TutorialTwoViewController()
            self.navigationController?.pushViewController(tutorialTwo, animated: true)
        }
    }
}