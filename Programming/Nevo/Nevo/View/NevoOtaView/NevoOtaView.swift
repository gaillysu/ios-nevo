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
    
    
    func buildView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate
    }
    
    
    @IBAction func back2Home(sender: AnyObject) {
        mDelegate?.controllManager("back2Home")
    }
    @IBAction func uploadFile(sender: AnyObject) {
        mDelegate?.controllManager("uploadFile")
    }
    @IBAction func selectWatchFile(sender: AnyObject) {
        mDelegate?.controllManager("selectWatchFile")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
