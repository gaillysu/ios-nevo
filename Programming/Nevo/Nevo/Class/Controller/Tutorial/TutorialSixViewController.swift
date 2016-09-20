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

    init() {
        super.init(nibName: "TutorialSixViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        print("LOLOL")
    }
    
    @IBAction func tapToContinueAction(_ sender: AnyObject) {
        //self.navigationController?.popToRootViewControllerAnimated(true)
        //let tutorialPageSeven = TutorialSevenViewController();
        //self.navigationController?.pushViewController(tutorialPageSeven, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
