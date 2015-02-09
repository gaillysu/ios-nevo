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
    func displayPageView(pageArray:[UIView]){
        scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*CGFloat(pageArray.count), scrollView.frame.height)
        scrollView.contentOffset = CGPointMake(0, 0)
        for (var i=0; i<pageArray.count; i++) {
            //According to the actual size decided to pictures
            
            var page = pageArray[NSInteger(i)]
            
            scrollView.addSubview(page)
            
            page.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
            
            page.center = CGPointMake(CGFloat(i) * self.frame.size.width+self.frame.size.width/2, self.frame.size.height/2.0)
            
        }
        displayPageControll(pageArray.count)

    }

    /*
    UIScrollViewDelegate
    */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //The current is calculated by what page
        let offset:CGFloat = scrollView.contentOffset.x / self.scrollView.frame.size.width
        let page:NSInteger = NSInteger(offset)
        pageControll.currentPage = Int(page)

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

}


