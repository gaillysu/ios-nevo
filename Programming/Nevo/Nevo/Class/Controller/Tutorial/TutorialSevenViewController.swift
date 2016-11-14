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
        styleEvolve()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.setLunaRtext()
        }
    }
    
    @IBAction func tryAgainAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension TutorialSevenViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            tryAgainButton.backgroundColor = UIColor.getBaseColor()
            centerImageView.image =  AppTheme.GET_RESOURCES_IMAGE("lunar_not_connect")
        }
    }
    
    func setLunaRtext() {
        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "nevo watch", with: "LunaR")
        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "nevo", with: "LunaR")
        
        detailLabel.text = detailLabel.text?.replacingOccurrences(of: "nevo watch", with: "LunaR")
        detailLabel.text = detailLabel.text?.replacingOccurrences(of: "nevo", with: "LunaR")
    }

}
