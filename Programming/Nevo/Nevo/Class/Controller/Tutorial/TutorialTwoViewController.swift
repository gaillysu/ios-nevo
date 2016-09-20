//
//  TutorialPageTwo.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialTwoViewController: UIViewController {

    @IBOutlet weak var turnBluetoothOnButton: UIButton!

    init() {
        super.init(nibName: "TutorialTwoViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
    }
    
    @IBAction func turnBluetoothOnAction(_ sender: AnyObject) {
        let tutorialTwo = TutorialThreeViewController()
        self.navigationController?.pushViewController(tutorialTwo, animated: true)
    }
}
