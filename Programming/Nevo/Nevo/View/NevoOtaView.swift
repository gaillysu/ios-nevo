//
//  NevoOtaView.swift
//  Nevo
//
//  Created by ideas on 15/3/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NevoOtaView: UIView {

    private var mDelegate:ButtonManagerCallBack?
    
    @IBOutlet weak var backButton: UIButton!
    
    func buildView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate
        backButton.addTarget(self, action: Selector("BackAction:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func BackAction(back:UIButton) {
        mDelegate?.controllManager(back)
    }
    
    @IBAction func uploadFile(sender: AnyObject) {
        mDelegate?.controllManager("uploadFile")
    }
    @IBAction func selectWatchFile(sender: AnyObject) {
        mDelegate?.controllManager("selectWatchFile")
    }
    @IBAction func selectWatchDevice(sender: AnyObject) {
        mDelegate?.controllManager("selectWatchDevice")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
