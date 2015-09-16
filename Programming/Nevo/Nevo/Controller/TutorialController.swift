//
//  TutorialController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//


class TutorialController: UIViewController {
    private var mTutorialView: TutorialView?
    //This controller is not displayed on the storyboard

    override func viewDidLoad() {
        super.viewDidLoad()

        //init TutorialView
        mTutorialView = TutorialView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height), delegate: self)
        self.view.addSubview(mTutorialView!)

        var longPush:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPushTask:"))
        mTutorialView?.addGestureRecognizer(longPush)
    }

    func longPushTask(longp:UIGestureRecognizer){
         self.performSegueWithIdentifier("Aid_Ota", sender: self)
    }
    
}
