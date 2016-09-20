//
//  SyncBar.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit


protocol CancelSelectorDelegate:NSObjectProtocol {
    func cancelSelectorItem(_ sender:AnyObject)
}

class SyncBar: NSObject,CancelSelectorDelegate {

    class hudLoader: UIView {
        var statusLabel:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
        //var spinnerImage:UIImageView = UIImageView(frame: CGRectMake(0,0,60,60))
        var cancelButton:UIButton = UIButton(type: UIButtonType.custom)
        var BGColor:UIColor = AppTheme.hexStringToColor("#000000") //default black
        var cancelDelegate:CancelSelectorDelegate?
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.black
            self.LoadView()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        fileprivate func LoadView(){
            statusLabel = UILabel(frame: CGRect(x: 0,y: 0,width: self.frame.size.width-30,height: 30))
            statusLabel.backgroundColor = UIColor.clear
            statusLabel.textAlignment = NSTextAlignment.center
            self.addSubview(statusLabel)

            //spinnerImage = UIImageView(frame: CGRectMake(statusLabel.frame.origin.x+statusLabel.frame.size.width, 0, 30, 30))
            //spinnerImage.backgroundColor = UIColor.clearColor()
            //spinnerImage.image = UIImage(named: "spinner")
           // self.addSubview(spinnerImage)

            cancelButton.setImage(UIImage(named: "syncBar_cancel"), for: UIControlState())
            cancelButton.frame = CGRect(x: self.frame.size.width-30,y: 0,width: 30,height: 30)
            cancelButton.addTarget(self, action: #selector(hudLoader.cancelAction(_:)), for: UIControlEvents.touchUpInside)
            self.addSubview(cancelButton)
        }

        func cancelAction(_ sender:UIButton){
            cancelDelegate?.cancelSelectorItem(sender)
        }
        
    }

    class func getSyncBar()->SyncBar {
        let syncBar:SyncBar = SyncBar()
        return syncBar
    }

    fileprivate var statusText:String = ""
    var hud:hudLoader = hudLoader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
    var currentView:UIView?

    fileprivate override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cancelSelectorItem(_ sender:AnyObject){
        self.hideFromView(currentView!)
    }

    func isHudView()->Bool {
        if(currentView == nil) {
            return false
        }else {
            for view in currentView!.subviews {
                if(view.isEqual(hud)){
                    return true
                }
            }
        }
        return false
    }

    func setStatusLabel(_ label:String) {
        statusText = label
        hud.statusLabel.text = statusText
        hud.statusLabel.textColor = UIColor.white
    }

    func showHudAddedToView(_ view:UIView){
        currentView = view;
        hud = hudLoader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0))
        hud.cancelDelegate = self
        hud.statusLabel.text = statusText
        hud.statusLabel.textColor = UIColor.white
        view.addSubview(hud)
        //self.spinnerRotate()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.hud.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30)
            }) { (completion:Bool) -> Void in

        }

    }

    func hideFromView(_ view:UIView){
        self.hide(hud, from: view)
    }

    fileprivate func spinnerRotate(){
        let fullRotation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        fullRotation.fromValue = NSNumber(value: 0 as Float)
        fullRotation.toValue = NSNumber(value: Float((Double(360.0)*M_PI)/Double(180.0)) as Float)
        fullRotation.duration = 1.15
        fullRotation.repeatCount = .infinity
        //hud.spinnerImage.layer.addAnimation(fullRotation, forKey: "360")
    }

    fileprivate func hide(_ presentHud:hudLoader,from view:UIView){
        var presentHud = presentHud
        //hud.spinnerImage.removeFromSuperview()
        //hud.backgroundColor = AppTheme.hexStringToColor("#FF0000")
        presentHud = hud
        presentHud.statusLabel.text = statusText
        UIView .animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            presentHud.frame = CGRect(x: 0,y: 0, width: view.frame.size.width,height: 0);
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

