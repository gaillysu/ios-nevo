//
//  MainTabBarController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {

    var items:[UIBarButtonItem] = []
    var selectedItem:UIButton!
    let FONT_RALEWAY_BOLD:UIFont! = UIFont(name:"Raleway-Thin", size: 23);

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        // Do any additional setup after loading the view.
        //var nav:UINavigationController!
        let viewArray:[AnyObject] = self.viewControllers!
        for nav in viewArray {
            let contll = (nav as! UINavigationController).topViewController
            if contll!.isKindOfClass(AlarmClockController){
                AppTheme.DLog("AlarmClockController:\(contll)")

            }

            if contll!.isKindOfClass(StepGoalSetingController){
                AppTheme.DLog("StepGoalSetingController:\(contll)")
                contll!.tabBarController?.selectedIndex = 0
            }

            if contll!.isKindOfClass(HomeController){
                AppTheme.DLog("HomeController:\(contll)")
            }

        }
        customInitTabbar()
    }

    func customInitTabbar(){
        self.tabBar.hidden = true

        let myTabbarView:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width+2, 64));
        myTabbarView.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 242, Blue: 242);
        self.view.addSubview(myTabbarView)


        let itemToolbar:UIToolbar = UIToolbar(frame: CGRectMake(0, 20, UIScreen.mainScreen().bounds.width, 44))
        itemToolbar.barStyle = UIBarStyle.BlackTranslucent
        itemToolbar.barTintColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 242, Blue: 242)
        itemToolbar.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 242, Blue: 242)
        myTabbarView.addSubview(itemToolbar)// 添加到view

        let imgArray:NSArray = NSArray(arrayLiteral: "STEPS","ALARM","SLEEP","SETTING")
        //"selectedGoalitem","selectedHomeitem","selectedAlarmitem"

        for (var i:Int = 0; i < imgArray.count; i++) {

            let width:CGFloat = imgArray.objectAtIndex(i).boundingRectWithSize(CGSizeMake(300, 100) , options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)], context: nil).size.width
            let item:UIButton  = UIButton(frame: CGRectMake(0, 0, width, 44))
            item.backgroundColor = UIColor.clearColor()
            item.titleLabel?.font = UIFont.systemFontOfSize(15)
            item.setTitle(imgArray[i] as? String, forState: UIControlState.Normal)
            item.setTitleColor(AppTheme.hexStringToColor("#4d4d4d"), forState: UIControlState.Selected)
            item.setTitleColor(AppTheme.hexStringToColor("#999999"), forState: UIControlState.Normal)

            if (i==0) {
                item.selected=true
                selectedItem=item
            }
            item.addTarget(self, action: Selector("tabbarItemClickAction:"), forControlEvents: UIControlEvents.TouchDown)
            item.tag = i;
            let itemButtonEmpty:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            itemButtonEmpty.tintColor = UIColor.clearColor()
            items.append(itemButtonEmpty)
            let itemButton:UIBarButtonItem = UIBarButtonItem(customView: item)
            items.append(itemButton)

        }
        itemToolbar.setItems(items, animated: true)
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
