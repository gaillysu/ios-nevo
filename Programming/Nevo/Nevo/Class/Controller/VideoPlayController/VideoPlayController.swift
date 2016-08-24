//
//  VideoPlayController.swift
//  Nevo
//
//  Created by leiyuncun on 16/2/26.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayController: AVPlayerViewController,AVPlayerViewControllerDelegate {

    private let session:AVAudioSession = AVAudioSession.sharedInstance()

    init() {
        super.init(nibName: "VideoPlayController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()

        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        }catch {

        }

        self.player = AVPlayer(URL: NSURL(string: "http://nevowatch.com/wp-content/uploads/2016/03/video.mp4")!);
        self.videoGravity = AVLayerVideoGravityResizeAspect;
        if #available(iOS 9.0, *) {
            self.delegate = self
        } else {
            // Fallback on earlier versions
        };

        if #available(iOS 9.0, *) {
            self.allowsPictureInPicturePlayback = true
        } else {
            // Fallback on earlier versions
        };

        //画中画，iPad可用
        self.showsPlaybackControls = true;

        self.view.translatesAutoresizingMaskIntoConstraints = true;    // 内部可能是用约束写的，这句可以禁用自动约束，消除报错
        self.view.frame = self.view.bounds;

        self.videoGravity = AVLayerVideoGravityResizeAspect
        self.player?.play()    //自动播放
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation,duration:NSTimeInterval) {
        if(toInterfaceOrientation == UIInterfaceOrientation.LandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientation.LandscapeRight){
            //self.navigationController!.navigationBarHidden = true;
        }
    }
    
    func playerViewControllerWillStartPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", #function);
    }

    func playerViewControllerDidStartPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", #function);
    }


    func playerViewController(playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: NSError) {
        NSLog("%s", #function);
    }

    func playerViewControllerWillStopPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", #function);
    }


    func playerViewControllerDidStopPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", #function);
    }

    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(playerViewController: AVPlayerViewController) -> Bool {
        return true;
    }


    func playerViewController(playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: (Bool) -> Void) {
        NSLog("%s", #function);
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
