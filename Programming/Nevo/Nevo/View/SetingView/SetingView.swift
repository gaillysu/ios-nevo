//
//  SetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetingView: UIView {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var SetingTableView: UITableView!
    private var mDelegate:ButtonManagerCallBack?

    func buliudView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate

    }

    @IBAction func buttonAction(sender: AnyObject) {
        
        mDelegate?.controllManager(sender)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
