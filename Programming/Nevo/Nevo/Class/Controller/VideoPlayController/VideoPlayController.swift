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

class VideoPlayController: UIViewController,AVPlayerViewControllerDelegate {

    private let session:AVAudioSession = AVAudioSession.sharedInstance()
    private var player:AVPlayer = AVPlayer(URL: NSURL(string: "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/2533/4/112668560/310935973.mp4?token=56cfc526_0xc6b179c5920dc35f73c5e33ce8267e923976313d&play=1&filename=The+nevo+watch+-+Time+in+motion-Mobile.mp4")!)
    private let playerController:AVPlayerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        }catch {

        }

        playerController.player = player;
        playerController.videoGravity = AVLayerVideoGravityResizeAspect;
        if #available(iOS 9.0, *) {
            playerController.delegate = self
        } else {
            // Fallback on earlier versions
        };

        if #available(iOS 9.0, *) {
            playerController.allowsPictureInPicturePlayback = true
        } else {
            // Fallback on earlier versions
        };

        //画中画，iPad可用
        playerController.showsPlaybackControls = true;

        self.addChildViewController(playerController)
        playerController.view.translatesAutoresizingMaskIntoConstraints = true;    //AVPlayerViewController 内部可能是用约束写的，这句可以禁用自动约束，消除报错
        playerController.view.frame = self.view.bounds;
        //[self.view addSubview:_playerController.view];
        self.view.addSubview(playerController.view)
        
        playerController.player?.play()    //自动播放
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func playerViewControllerWillStartPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", __FUNCTION__);
    }

    func playerViewControllerDidStartPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", __FUNCTION__);
    }


    func playerViewController(playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: NSError) {
        NSLog("%s", __FUNCTION__);
    }

    func playerViewControllerWillStopPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", __FUNCTION__);
    }


    func playerViewControllerDidStopPictureInPicture(playerViewController: AVPlayerViewController) {
        NSLog("%s", __FUNCTION__);
    }

    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(playerViewController: AVPlayerViewController) -> Bool {
        return true;
    }


    func playerViewController(playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: (Bool) -> Void) {
        NSLog("%s", __FUNCTION__);
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
