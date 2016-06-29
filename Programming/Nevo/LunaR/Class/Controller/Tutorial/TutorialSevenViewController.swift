//
//  TutorialPageSeven.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//
import UIKit
import Foundation

class TutorialSevenViewController: UIViewController {
    
    @IBOutlet weak var tryAgainButton: UIButton!

    init() {
        super.init(nibName: "TutorialSevenViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
    }
    @IBAction func tryAgainAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}