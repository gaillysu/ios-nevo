//
//  LineColorCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class LineColorCell: UITableViewCell {

    @IBOutlet weak var lineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineLabel.isHidden = true
    }
}
