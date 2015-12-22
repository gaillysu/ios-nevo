//
//  SyncBar.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit


protocol CancelSelectorDelegate:NSObjectProtocol {
    func cancelSelectorItem(sender:AnyObject)
}

class SyncBar: NSObject,CancelSelectorDelegate {

    class hudLoader: UIView {
        var statusLabel:UILabel = UILabel(frame: CGRectMake(0,0,60,60))
        //var spinnerImage:UIImageView = UIImageView(frame: CGRectMake(0,0,60,60))
        var cancelButton:UIButton = UIButton(type: UIButtonType.Custom)
        var BGColor:UIColor = AppTheme.hexStringToColor("#000000") //default black
        var cancelDelegate:CancelSelectorDelegate?
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.blackColor()
            self.LoadView()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func LoadView(){
            statusLabel = UILabel(frame: CGRectMake(0,0,self.frame.size.width-30,30))
            statusLabel.backgroundColor = UIColor.clearColor()
            statusLabel.textAlignment = NSTextAlignment.Center
            self.addSubview(statusLabel)

            //spinnerImage = UIImageView(frame: CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width, 0, 30, 30))
            //spinnerImage.backgroundColor = UIColor.clearColor()
            //spinnerImage.image = UIImage(named: "spinner")
           // self.addSubview(spinnerImage)

            cancelButton.setImage(UIImage(named: "syncBar_cancel"), forState: UIControlState.Normal)
            cancelButton.frame = CGRectMake(self.frame.size.width-30,0,30,30)
            cancelButton.addTarget(self, action: Selector("cancelAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(cancelButton)
        }

        func cancelAction(sender:UIButton){
            cancelDelegate?.cancelSelectorItem(sender)
        }
        
    }

    class func getSyncBar()->SyncBar {
        let syncBar:SyncBar = SyncBar()
        return syncBar
    }

    var statusText:String = ""
    var hud:hudLoader = hudLoader(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 30))
    var currentView:UIView?

    private override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cancelSelectorItem(sender:AnyObject){
        self.hideFromView(currentView!)
    }

    func showHudAddedToView(view:UIView){
        currentView = view;
        hud = hudLoader(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 0))
        hud.cancelDelegate = self
        hud.statusLabel.text = statusText
        hud.statusLabel.textColor = UIColor.whiteColor()
        view.addSubview(hud)
        //self.spinnerRotate()
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.hud.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 30)
            }) { (completion:Bool) -> Void in

        }

    }

    func hideFromView(view:UIView){
        self.hide(hud, from: view)
    }

    private func spinnerRotate(){
        let fullRotation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        fullRotation.fromValue = NSNumber(float: 0)
        fullRotation.toValue = NSNumber(float: Float((Double(360.0)*M_PI)/Double(180.0)))
        fullRotation.duration = 1.15
        fullRotation.repeatCount = .infinity
        //hud.spinnerImage.layer.addAnimation(fullRotation, forKey: "360")
    }

    private func hide(var presentHud:hudLoader,from view:UIView){
        //hud.spinnerImage.removeFromSuperview()
        //hud.backgroundColor = AppTheme.hexStringToColor("#FF0000")
        presentHud = hud
        presentHud.statusLabel.text = statusText
        UIView .animateWithDuration(1, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            presentHud.frame = CGRectMake(0,0, view.frame.size.width,0);
            }) { (finished:Bool) -> Void in
                presentHud.removeFromSuperview()
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}

