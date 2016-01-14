//
//  SupportViewController.swift
//  Nevo
//
//  Created by leiyuncun on 16/1/14.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SupportViewController: PublicClassController {

    @IBOutlet weak var supportWebview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Support", comment: "")

        let request:NSURLRequest = NSURLRequest(URL: NSURL(string:"http://support.nevowatch.com/support/home")!)
        supportWebview.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
