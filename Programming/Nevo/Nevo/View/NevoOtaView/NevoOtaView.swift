//
//  NevoOtaView.swift
//  Nevo
//
//  Created by ideas on 15/3/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NevoOtaView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titleBgView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var selectFileButton: UIButton!

    private var mDelegate:ButtonManagerCallBack?
    
    
    func buildView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate
        title.text = NSLocalizedString("Firmware Upgrade", comment:"")
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
