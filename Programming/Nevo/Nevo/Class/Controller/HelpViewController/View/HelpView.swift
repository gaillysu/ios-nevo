//
//  HelpView.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/29.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class HelpView: UIView {

    @IBOutlet weak var titleBgView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var helpWebView: UIWebView!

    private var mDelegate:ButtonManagerCallBack?

    func bulidHelpView(delegate:ButtonManagerCallBack){
        mDelegate = delegate

        title.text = NSLocalizedString("Help",comment: "")
        title.font = AppTheme.FONT_SFCOMPACTDISPLAY_LIGHT(mSize: 25)
        title.textAlignment = NSTextAlignment.Center

        let fileArray = AppTheme.GET_FIRMWARE_FILES("help")
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! NSURL
            let fileName:String? = (selectedFile.path! as NSString).lastPathComponent
            //let fileExtension:String? = selectedFile.pathExtension
            if fileName=="index.html"{
                let request:NSURLRequest = NSURLRequest(URL: NSURL(fileURLWithPath: selectedFile.path!))
                helpWebView.loadRequest(request)
            }
        }

    }

    @IBAction func ButtonAction(sender: AnyObject) {
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
