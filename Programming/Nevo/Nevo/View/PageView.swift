//
//  PageView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIkit

class PageView: UIView,UIScrollViewDelegate {

    let scrollView:UIScrollView = UIScrollView()

    let pageControll:UIPageControl = UIPageControl()

    //PageView background color
    let background:UIColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)

    //button background color
    let buttonBackground:UIColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.backgroundColor = background

        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.shouldGroupAccessibilityChildren = true
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        self.addSubview(scrollView)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*Display PageView content
      @param imageArray: The content of the load on the scrollView
    */
    func displayPageView(imageArray:NSArray){
        scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*CGFloat(imageArray.count), scrollView.frame.height)
        scrollView.contentOffset = CGPointMake(0, 0)
        for (var i=0; i<imageArray.count; i++) {
            //According to the actual size decided to pictures
            let poorSub:CGFloat = self.frame.size.width/2
            let guideImage:UIImageView = UIImageView(image: UIImage(named: String(imageArray[NSInteger(i)] as NSString)))
            guideImage.center = CGPointMake(CGFloat(i) * self.frame.size.width+poorSub, self.frame.size.height/2.0)
            guideImage.userInteractionEnabled = true;
            guideImage.backgroundColor = UIColor.clearColor();
            guideImage.image = UIImage(named: String(imageArray[NSInteger(i)] as NSString))
            scrollView.addSubview(guideImage)
        }
        displayPageControll(imageArray.count)

    }

    /*
    UIScrollViewDelegate
    */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //The current is calculated by what page
        let offset:CGFloat = scrollView.contentOffset.x / self.scrollView.frame.size.width
        let page:NSInteger = NSInteger(offset)
        pageControll.currentPage = Int(page)

        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: { () -> Void in
            if (page==2) {
                //page number 2 display startButton
                let startButton:UIButton = UIButton(frame: CGRectMake(0, self.pageControll.frame.origin.y+self.pageControll.frame.size.height, self.frame.size.width, self.pageControll.frame.size.height))
                startButton.backgroundColor = self.buttonBackground
                startButton .setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                startButton.titleLabel?.font = UIFont.systemFontOfSize(20)
                startButton.setTitle(NSLocalizedString("Scan", comment:"") , forState: UIControlState.Normal)
                startButton.addTarget(self, action: Selector("ScanAction:"), forControlEvents: UIControlEvents.TouchUpInside)
                startButton.enabled = true
                self.addSubview(startButton)
            }

            }) { (Bool) -> Void in

        }
    }

    /*
    PageControll
    @param numberOfPages:How many pages in total
    */
    func displayPageControll(numberOfPages:NSInteger){
        pageControll.frame = CGRectMake(0, scrollView.frame.size.height-100, self.frame.size.width, 50)
        pageControll.userInteractionEnabled=false
        pageControll.pageIndicatorTintColor = UIColor.grayColor()
        pageControll.backgroundColor = background
        pageControll.currentPageIndicatorTintColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        pageControll.numberOfPages = numberOfPages
        self.addSubview(pageControll)

    }

    //Scan button action
    func ScanAction(sender:UIButton){
        NSLog("ScanAction")
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.00, 0.00);
        }) { (Bool) -> Void in
            self.removeFromSuperview();
        }
        //SyncController(controller:self).sendRawPacket();
    }
}


