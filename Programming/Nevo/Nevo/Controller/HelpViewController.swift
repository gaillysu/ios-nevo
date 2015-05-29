//
//  HelpViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/29.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController,ButtonManagerCallBack {

    @IBOutlet var helpView: HelpView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        helpView.bulidHelpView(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if sender.isEqual(helpView.backButton){
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    func webViewDidStartLoad(webView: UIWebView){

    }

    func webViewDidFinishLoad(webView: UIWebView){

    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError){

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
