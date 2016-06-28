//
//  TutorialPageFive.swift
//  Nevo
//
//  Created by Karl-John on 13/1/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import Foundation

class TutorialFiveViewController: UIViewController,SyncControllerDelegate {

    var progressView:CircleProgressView?
    var progresValue:CGFloat = 0.0
    var timer:NSTimer?

    @IBOutlet weak var watchImage: UIImageView!
    
    init() {
        super.init(nibName: "TutorialFiveViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        AppDelegate.getAppDelegate().connect()

    }

    override func viewWillAppear(animated: Bool) {
        if(timer == nil) {
            timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(TutorialFiveViewController.timerAction(_:)), userInfo: nil, repeats: true)
        }else {
            timer = nil
            timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(TutorialFiveViewController.timerAction(_:)), userInfo: nil, repeats: true)
            progressView?.setProgress(0.0)
        }
    }

    override func viewDidLayoutSubviews() {
        progressView = CircleProgressView()
        progressView!.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView?.frame = CGRectMake(watchImage!.frame.origin.x-5, watchImage!.frame.origin.y-5, watchImage.bounds.width+10, watchImage.bounds.width+10)
        progressView?.setProgress(0.0)
        self.view.layer.addSublayer(progressView!)
    }

    func timerAction(action:NSTimer) {
        progresValue+=0.1
        setProgress(progresValue)
        if(progresValue > 1){
            action.valid ? action.invalidate():()
            if(AppDelegate.getAppDelegate().isConnected()){
                delay(1.0) {
                    AppDelegate.getAppDelegate().restoreSavedAddress()
                    let tutorialSix = TutorialSixViewController()
                    self.navigationController?.pushViewController(tutorialSix, animated: true)
                }
            }else{
                var res:Bool = true
                for nvc:UIViewController in self.navigationController!.viewControllers {
                    if(nvc.isKindOfClass(TutorialSevenViewController.classForCoder())) {
                        res = false
                        self.navigationController?.popToViewController(nvc, animated: true)
                        return;
                    }
                }
                if(res) {
                    progresValue = 0.0
                    setProgress(0.0)
                    let tutorial:TutorialSevenViewController = TutorialSevenViewController()
                    self.navigationController?.pushViewController(tutorial, animated: true)
                }
            }

        }else{
            if(AppDelegate.getAppDelegate().isConnected()){
                action.valid ? action.invalidate():()
                delay(1.0) {
                    let tutorialSix = TutorialSixViewController()
                    self.navigationController?.pushViewController(tutorialSix, animated: true)
                }
            }
        }
    }

    /**
     set the progress of the progressView

     :param: progress
     :param: animated
     */
    func setProgress(progress: CGFloat){
        progressView?.setProgress(progress, Steps: 0, GoalStep: 0)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    /**
     Called when a packet is received from the device
     */
    func packetReceived(packet: NevoPacket) {

    }
    /**
     Called when a peripheral connects or disconnects
     */
    func connectionStateChanged(isConnected : Bool) {
        if(isConnected) {

        }
    }
    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(number:NSNumber) {

    }
    /**
     *  Data synchronization is complete callback
     */
    func syncFinished() {

    }
}