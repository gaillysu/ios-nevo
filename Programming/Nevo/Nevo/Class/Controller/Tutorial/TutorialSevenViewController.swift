//
//  TutorialPageSeven.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialSevenViewController: UIViewController {
    
    @IBOutlet weak var tryAgainButton: UIButton!

    init() {
        super.init(nibName: "TutorialSevenViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
    }
    @IBAction func tryAgainAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
