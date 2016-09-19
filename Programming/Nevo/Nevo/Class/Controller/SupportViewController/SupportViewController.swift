//
//  SupportViewController.swift
//  Nevo
//
//  Created by leiyuncun on 16/1/14.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import NJKWebViewProgress

class SupportViewController: UIViewController,NJKWebViewProgressDelegate,UIWebViewDelegate {

    @IBOutlet weak var supportWebview: UIWebView!

    var progressView:NJKWebViewProgressView?
    var progressProxy:NJKWebViewProgress?

    init() {
        super.init(nibName: "SupportViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Support", comment: "")

        progressProxy = NJKWebViewProgress()
        supportWebview.delegate = progressProxy;
        progressProxy!.webViewProxyDelegate = self;
        progressProxy!.progressDelegate = self;

        let progressBarHeight:CGFloat = 2.0;
        let navigationBarBounds:CGRect = self.navigationController!.navigationBar.bounds;
        let barFrame:CGRect = CGRect(x: 0, y: navigationBarBounds.size.height - progressBarHeight, width: navigationBarBounds.size.width, height: progressBarHeight);
        progressView = NJKWebViewProgressView(frame: barFrame);
        progressView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth ,UIViewAutoresizing.flexibleTopMargin]


        let request:URLRequest = URLRequest(url: URL(string:"http://support.nevowatch.com/support/home")!)
        supportWebview.loadRequest(request)
    }

    override func viewDidAppear(_ animated: Bool) {
        //[self.navigationController.navigationBar addSubview:_progressView];
        self.navigationController!.navigationBar.addSubview(progressView!)
    }

    override func viewWillDisappear(_ animated: Bool)  {
        progressView?.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewProgress(_ webViewProgress:NJKWebViewProgress ,updateProgress progress:Float) {
        //[_progressView setProgress:progress animated:YES];
        //self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        progressView?.setProgress(progress, animated: true)
        self.navigationItem.title = supportWebview.stringByEvaluatingJavaScript(from: "document.title")
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
