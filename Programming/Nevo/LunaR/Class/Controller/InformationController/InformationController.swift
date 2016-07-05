//
//  InformationController.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SMSegmentView

class InformationController: UIViewController,SMSegmentViewDelegate {

    @IBOutlet weak var metricsSegment: UIView!
    var segmentView:SMSegmentView?
    
    
    init() {
        super.init(nibName: "InformationController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Register"
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor(rgba: "#54575a"))
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(rightAction(_:)))
        self.navigationItem.rightBarButtonItem = leftButton
    }
    
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        let segmentProperties = ["OnSelectionBackgroundColour": UIColor(rgba: "#7ED8D1"),"OffSelectionBackgroundColour": UIColor.whiteColor(),"OnSelectionTextColour": UIColor.whiteColor(),"OffSelectionTextColour": UIColor(rgba: "#95989A")]
        if segmentView == nil {
            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 1.0, segmentProperties: segmentProperties)
            segmentView!.delegate = self
            segmentView!.layer.borderColor = UIColor(rgba: "#7ED8D1").CGColor
            segmentView!.layer.borderWidth = 1.0
            segmentView?.layer.cornerRadius = 10
            
            // Add segments
            segmentView!.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
            segmentView?.selectSegmentAtIndex(0)
            metricsSegment.addSubview(segmentView!)
        }
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    // MARK: - SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        debugPrint("Select segment at index: \(index)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func rightAction(sender:UIBarButtonItem) {
        
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
