//
//  UnitTableViewCell.swift
//  Nevo
//
//  Created by Cloud on 2016/12/12.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UnitTableViewCell: UITableViewCell {

    @IBOutlet weak var unitSegmented: SMSegmentView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let appearance = SMSegmentAppearance()
        appearance.titleOnSelectionColour       = UIColor.white
        appearance.titleOffSelectionColour      = UIColor.getBaseColor()
        appearance.segmentOnSelectionColour     = UIColor.getBaseColor()
        appearance.segmentOffSelectionColour    = UIColor.getGreyColor()
        appearance.titleOnSelectionFont         = UIFont.systemFont(ofSize: 12.0)
        appearance.titleOffSelectionFont        = UIFont.systemFont(ofSize: 12.0)
        appearance.contentVerticalMargin        = 10.0
        
        unitSegmented.segmentAppearance         = appearance
        unitSegmented.backgroundColor           = UIColor.getBaseColor()
        unitSegmented.layer.cornerRadius        = 5.0
        unitSegmented.layer.borderColor         = UIColor.getBaseColor().cgColor
        unitSegmented.layer.borderWidth         = 1.0
        
        unitSegmented.addSegmentWithTitle(NSLocalizedString("Metrics", comment: ""), onSelectionImage: nil, offSelectionImage: nil)
        unitSegmented.addSegmentWithTitle(NSLocalizedString("imperial", comment: ""), onSelectionImage: nil, offSelectionImage: nil)
        unitSegmented.addTarget(self, action: #selector(segmentViewAction(segmentVie:)), for: .valueChanged)
        
        if let value = UserDefaults.standard.object(forKey: "UserSelectedUnit") {
            let index:Int = value as! Int
            unitSegmented.selectedSegmentIndex = index
        }else{
            unitSegmented.selectedSegmentIndex = 0;
        }
    }

    func segmentViewAction(segmentVie:SMSegmentView) {
        let userDefault:UserDefaults = UserDefaults.standard
        userDefault.set(unitSegmented.selectedSegmentIndex, forKey: "UserSelectedUnit")
        userDefault.synchronize()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
