//
//  SetingDefaultCell.swift
//  Nevo
//
//  Created by Cloud on 2017/5/22.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

class SetingDefaultCell: UITableViewCell {
    var model:(cellName:String,imageName:String,setingType:SetingType)? {
        didSet{
            textLabel?.text = model!.cellName
            imageView?.image = UIImage(named: model!.imageName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.white
        textLabel?.textColor = UIColor.black
        textLabel!.backgroundColor = UIColor.clear
        accessoryType = .disclosureIndicator
        viewDefaultColorful()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
