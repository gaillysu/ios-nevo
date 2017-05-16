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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!

    init() {
        super.init(nibName: "TutorialSevenViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    @IBAction func tryAgainAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
