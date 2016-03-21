//
//  HomeTutorialController.swift
//  Nevo
//
//  Created by leiyuncun on 16/2/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class HomeTutorialController: UIViewController {

    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var activateButton: UIButton!


    init() {
        super.init(nibName: "HomeTutorialController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        takeButton.layer.borderColor = UIColor.whiteColor().CGColor

    }

    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonManager(sender: AnyObject) {
        if(sender.isEqual(activateButton)){
            let tutorialOne:TutorialOneViewController = TutorialOneViewController()
            self.navigationController?.pushViewController(tutorialOne, animated: true)
        }

        if(sender.isEqual(takeButton)){
            if(AppDelegate.getAppDelegate().getNetworkState()){
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
                let videoPlay:VideoPlayController = VideoPlayController();
                self.presentViewController(videoPlay, animated: true) { () -> Void in

                }
            }else{
                let tutorialOne:TutorialOneViewController = TutorialOneViewController()
                self.navigationController?.pushViewController(tutorialOne, animated: true)
            }

        }
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
