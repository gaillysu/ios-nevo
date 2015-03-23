//
//  MainTabBarController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {

    var items:NSMutableArray!
    var selectedItem:UIButton!
    let FONT_RALEWAY_BOLD:UIFont! = UIFont(name:"Raleway-Thin", size: 23);

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        // Do any additional setup after loading the view.
        var nav:UINavigationController!
        let viewArray:[AnyObject] = self.viewControllers!
        for nav in viewArray {
            var contll = (nav as UINavigationController).topViewController
            if contll.isKindOfClass(AlarmClockController){
                NSLog("AlarmClockController:\(contll)")

            }

            if contll.isKindOfClass(StepGoalSetingController){
                NSLog("StepGoalSetingController:\(contll)")
            }

            if contll.isKindOfClass(HomeController){
                NSLog("HomeController:\(contll)")
                contll.tabBarController?.selectedIndex = 1
            }

        }
        customInitTabbar()
    }

    func customInitTabbar(){
        self.tabBar.hidden = true
        
        let myTabbarView:UIView = UIView(frame: CGRectMake(-1, self.view.frame.size.height-99, UIScreen.mainScreen().bounds.size.width+2, 100));
        myTabbarView.backgroundColor = UIColor.whiteColor();
        myTabbarView.layer.borderWidth = 1.0;
        myTabbarView.layer.borderColor = UIColor.grayColor().CGColor;
        self.view.addSubview(myTabbarView)

        let itemView:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width-50, myTabbarView.frame.size.height));
        itemView.backgroundColor = UIColor.whiteColor()
        itemView.center = CGPointMake(myTabbarView.frame.size.width/2.0, myTabbarView.frame.size.height/2.0)
        myTabbarView.addSubview(itemView)
        if (items == nil) {
            items = NSMutableArray(capacity: 4)
        }
        let imgArray:NSArray = NSArray(arrayLiteral: "goalitem","homeitem","alarmitem")
        let selectImgArray:NSArray = NSArray(arrayLiteral: "selectedGoalitem","selectedHomeitem","selectedAlarmitem")

        for (var i:Int = 0; i < imgArray.count; i++) {

            var itemWidth:CGFloat = itemView.frame.size.width/CGFloat(imgArray.count)
            var item:UIButton  = UIButton(frame:  CGRectMake(itemWidth*CGFloat(i), 0, itemWidth, itemView.frame.size.height))
            item.backgroundColor = UIColor.clearColor()
            item.setImage(UIImage(named: selectImgArray[i] as String), forState: UIControlState.Selected)
            item.setImage(UIImage(named: selectImgArray[i] as String), forState: UIControlState.Highlighted)
            item.setImage(UIImage(named: imgArray[i] as String), forState: UIControlState.Normal)
            
            if (i==1) {
                item.selected=true
                selectedItem=item
            }
            item.addTarget(self, action: Selector("tabbarItemClickAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            itemView.addSubview(item)
            item.tag = i;
            items.addObject(item)

        }


    }

    func tabbarItemClickAction(item:UIButton) {
        item.selected = true
        if ((selectedItem) != nil && !item.isEqual(selectedItem)) {
            selectedItem.selected = false
        }
        selectedItem = item;

        self.selectedIndex = item.tag;
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
