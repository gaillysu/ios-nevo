//
//  StepsCalButton.swift
//  Nevo
//
//  Created by Quentin on 14/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class StepsCalButton: UIButton {
    override func awakeFromNib() {
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 25, y: 12.5, width: 25, height: 25)
    }
}
