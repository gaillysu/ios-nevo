//
//  MyNevoHeaderView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoHeaderView: UIImageView {

    class func getMyNevoHeaderView()->UIImageView {
        let nibView:[Any] = Bundle.main.loadNibNamed("MyNevoHeaderView", owner: nil, options: nil)!
        return nibView[0] as! UIImageView
    }
}
