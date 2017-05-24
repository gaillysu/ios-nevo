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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    init() {
        super.init(nibName: "TutorialSixViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func tapToContinueAction(_ sender: AnyObject) {
        if let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            UIApplication.shared.keyWindow?.rootViewController = mainController
        }
    }
}
