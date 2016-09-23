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
        super.init(nibName: "TutorialOneViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }   

    override func viewDidLoad() {
        
        //controllManager(_:)
        let logPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TutorialOneViewController.logPressAction(_:)))
        self.view.addGestureRecognizer(logPress)
    }
    
    func logPressAction(_ sender:UITapGestureRecognizer) {
        let otaCont:OldOtaViewController = OldOtaViewController()
        let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
        self.present(navigation, animated: true, completion: nil)
    }
    
    @IBAction func activateYourNevoAction(_ sender: AnyObject) {
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
