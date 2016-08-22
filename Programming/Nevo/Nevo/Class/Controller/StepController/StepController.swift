//
//  StepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import Timepiece
import UIColor_Hex_Swift
import PagingMenuController
import XCGLogger
import CVCalendar
import SwiftEventBus
import LTNavigationBar

//let SELECTED_CALENDAR_NOTIFICATION = "SELECTED_CALENDAR_NOTIFICATION"
//private let CALENDAR_VIEW_TAG = 1800
private struct PagingMenuOptions: PagingMenuControllerCustomizable {
    
    private var componentType: ComponentType {
        return .PagingController(pagingControllers: pagingControllers)
    }
    
    private var pagingControllers: [UIViewController] {
        let viewController1 = StepGoalSetingController()
        viewController1.view.backgroundColor = UIColor(rgba: "#54575a")
        let viewController2 = StepsHistoryViewController()
        viewController2.view.backgroundColor = UIColor(rgba: "#54575a")
        let viewController3 = SleepHistoricalViewController()
        viewController3.view.backgroundColor = UIColor(rgba: "#54575a")
        let viewController4 = SolarIndicatorController()
        viewController4.view.backgroundColor = UIColor(rgba: "#54575a")
        //
        return [viewController1, viewController2,viewController3,viewController4]
    }
}

class StepController: PublicClassController,UIActionSheetDelegate {
    
    
    private var rightItem:UIBarButtonItem?
    private var goalArray:[Int] = []
    //var viewControllers:[UIViewController] = []
    var pagingMenuController:PagingMenuController?
    var calendarView:CVCalendarView?
    var menuView:CVCalendarMenuView?
    var titleView:StepsTitleView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.getGreyColor())
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.view.backgroundColor = UIColor.getGreyColor()

        self.initTitleView()
        
        rightItem = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(rightBarButtonAction(_:)))
        rightItem?.tintColor = UIColor(rgba: "#7ED8D1")
        self.navigationItem.rightBarButtonItem = rightItem


        if(!AppDelegate.getAppDelegate().isConnected() && AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled()){
            let banner = Banner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.5)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let options = PagingMenuOptions()
        if pagingMenuController == nil {
            pagingMenuController = PagingMenuController(options: options)
            pagingMenuController!.view.backgroundColor = UIColor(rgba: "#54575a")
            pagingMenuController!.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.view.frame.size.height)
            self.addChildViewController(pagingMenuController!)
            view.addSubview(pagingMenuController!.view)
            pagingMenuController!.didMoveToParentViewController(self)
            view.backgroundColor = UIColor(rgba: "#54575a")
            
            let leftButton:UIButton = UIButton(type: UIButtonType.System)
            leftButton.setImage(UIImage(named: "left_button"), forState: UIControlState.Normal)
            leftButton.tag = 1900
            leftButton.frame = CGRectMake(0, 0, 35, 125)
            leftButton.imageEdgeInsets = UIEdgeInsets(top: (125.0-30.0)/2.0, left: 10, bottom: (125.0-30.0)/2.0, right: 10)
            leftButton.addTarget(self, action: #selector(slidingAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            pagingMenuController!.view.addSubview(leftButton)
            leftButton.tintColor = UIColor.getWhiteBaseColor()
            leftButton.center = CGPointMake(leftButton.frame.size.width/2.0, self.view.frame.size.height/2.0-70)
            
            let rightButton:UIButton = UIButton(type: UIButtonType.System)
            rightButton.setImage(UIImage(named: "right_button"), forState: UIControlState.Normal)
            rightButton.tag = 1910
            rightButton.frame = CGRectMake(0, 0, 35, 125)
            rightButton.imageEdgeInsets = UIEdgeInsets(top: (125.0-30.0)/2.0, left: 10, bottom: (125.0-30.0)/2.0, right: 10)
            rightButton.addTarget(self, action: #selector(slidingAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            pagingMenuController!.view.addSubview(rightButton)
            rightButton.tintColor = UIColor.getWhiteBaseColor()
            rightButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-rightButton.frame.size.width/2.0, self.view.frame.size.height/2.0-70)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let array:NSArray = Presets.getAll()
        goalArray.removeAll()
        for pArray in array {
            let model:Presets = pArray as! Presets
            if(model.status){
                goalArray.append(model.steps)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func slidingAction(sender:UIButton) {
        if sender.tag == 1900 {
            if pagingMenuController!.currentPage != 0 {
                pagingMenuController?.moveToMenuPage(pagingMenuController!.currentPage-1)
            }
        }
        
        if sender.tag == 1910 {
            pagingMenuController?.moveToMenuPage(pagingMenuController!.currentPage+1)
        }
    }
    
    // MARK: - rightBarButtonAction
    func leftBarButtonAction(leftBar:UIBarButtonItem){
        let videoPlay:VideoPlayController = VideoPlayController();
        self.presentViewController(videoPlay, animated: true) { () -> Void in

        }
    }

    func rightBarButtonAction(rightBar:UIBarButtonItem){
        if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
            
            let actionSheet:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

            let array:NSArray = Presets.getAll()
            for pArray in array {
                let model:Presets = pArray as! Presets
                if(model.status){
                    let titleString:String = " \(model.steps) " + NSLocalizedString("steps_unit", comment: "")
                    let alertAction2:UIAlertAction = UIAlertAction(title: titleString, style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                        if((action.title! as NSString).isEqualToString(titleString)){
                            NSUserDefaults.standardUserDefaults().setObject(model.steps, forKey: NUMBER_OF_STEPS_GOAL_KEY)
                            self.setGoal(NumberOfStepsGoal(steps: model.steps))
                        }
                    }
                    alertAction2.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                    actionSheet.addAction(alertAction2)
                }
            }
            
            let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            alertAction.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
            //alertAction.setValue(UIImage(named: "google"), forKey: "Image")
            //alertAction.setValue(true, forKey: "checked")
            actionSheet.addAction(alertAction)
            
            self.presentViewController(actionSheet, animated: true, completion:nil)
        }else{
            let actionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
            for steps in goalArray {
                actionSheet.addButtonWithTitle("\(steps) steps")
            }
            for button:UIView in actionSheet.subviews{
                button.tintColor = UIColor.getBaseColor()
                button.backgroundColor = UIColor.getBaseColor()
            }
            actionSheet.layer.backgroundColor = UIColor.getBaseColor().CGColor
            actionSheet.tintColor = UIColor.getBaseColor()
            actionSheet.actionSheetStyle = UIActionSheetStyle.Default;
            actionSheet.showInView(self.view)
        }
    }
    
    func getCurrentVC() -> UIViewController {
        var result:UIViewController?
        
        var window:UIWindow = UIApplication.sharedApplication().keyWindow!
        if (window.windowLevel != UIWindowLevelNormal){
            let windows:NSArray = UIApplication.sharedApplication().windows;
            for tmpWin in windows {
                if (tmpWin.windowLevel == UIWindowLevelNormal){
                    window = tmpWin as! UIWindow;
                    break;
                }
            }
        }
        
        let frontView:UIView = window.subviews[0]
        let nextResponder = frontView.nextResponder()
        
        if nextResponder!.isKindOfClass(UIViewController.classForCoder()) {
            result = nextResponder as? UIViewController
        }else{
            result = window.rootViewController
        }
        
        return result!;
    }
    // MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex != 0){
            NSUserDefaults.standardUserDefaults().setObject(goalArray[buttonIndex-1], forKey: NUMBER_OF_STEPS_GOAL_KEY)
            setGoal(NumberOfStepsGoal(steps: goalArray[buttonIndex-1]))
        }
    }

    func willPresentActionSheet(actionSheet: UIActionSheet){
        for subViwe in actionSheet.subviews{
            subViwe.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            if(subViwe.isKindOfClass(UIButton.classForCoder())){
                let button:UIButton = subViwe as! UIButton
                button.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            }
        }
    }

    func setGoal(goal:Goal) {
        if(AppDelegate.getAppDelegate().isConnected()){
            let banner = Banner(title: NSLocalizedString("syncing_goal", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
            AppDelegate.getAppDelegate().setGoal(goal)
        }else{
            let banner = Banner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
        }

    }
}

// MARK: - Title View
extension StepController {
    
    func initTitleView() {
        titleView = StepsTitleView.getStepsTitleView(CGRectMake(0,0,190,50))
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.stringFromDate(NSDate())), \(NSDate().day)"
        titleView?.setCalendarButtonTitle(dateString)
        self.navigationItem.titleView = titleView
        titleView!.buttonResultHandler = { result -> Void in
            let clickButton:UIButton = result as! UIButton
            if (result!.isEqual(self.titleView!.calendarButton) && clickButton.selected) {
                self.showCalendar()
            }else if (result!.isEqual(self.titleView!.calendarButton) && !clickButton.selected) {
                self.dismissCalendar()
            }else if (result!.isEqual(self.titleView!.nextButton)) {
                self.calendarView!.loadNextView()
            }else if (result!.isEqual(self.titleView!.backButton)) {
                self.calendarView!.loadPreviousView()
            }
        }
    }
    
    func showCalendar() {
        let view = self.view.viewWithTag(CALENDAR_VIEW_TAG)
        if(view == nil) {
            let calendarBackGroundView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,self.view.frame.size.height))
            calendarBackGroundView.alpha = 0
            calendarBackGroundView.backgroundColor = UIColor.clearColor()
            calendarBackGroundView.tag = CALENDAR_VIEW_TAG
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            calendarBackGroundView.addGestureRecognizer(tap)
            pagingMenuController!.view.addSubview(calendarBackGroundView)
            
            let fillView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,260))
            fillView.backgroundColor = UIColor(rgba: "#3a3739").colorWithAlphaComponent(1)
            calendarBackGroundView.addSubview(fillView)
            
            self.menuView = CVCalendarMenuView(frame: CGRectMake(10, 20, UIScreen.mainScreen().bounds.size.width - 20, 20))
            self.menuView?.dayOfWeekTextColor = UIColor.whiteColor()
            self.menuView?.dayOfWeekFont = UIFont.systemFontOfSize(15)
            self.menuView?.backgroundColor = UIColor(rgba: "#3a3739").colorWithAlphaComponent(1)
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)
            
            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRectMake(10, 40, UIScreen.mainScreen().bounds.size.width - 20, 220))
            self.calendarView?.backgroundColor = UIColor(rgba: "#3a3739").colorWithAlphaComponent(1)
            calendarView?.hidden = false
            fillView.addSubview(calendarView!)
            self.calendarView!.calendarAppearanceDelegate = self
            self.calendarView!.animatorDelegate = self
            self.calendarView!.calendarDelegate = self
            
            // Commit frames' updates
            self.calendarView!.commitCalendarViewUpdate()
            self.menuView!.commitMenuViewUpdate()
            
            calendarView?.coordinator.selectedDayView?.selectionView?.shape = CVShape.Rect
            
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                calendarBackGroundView.alpha = 1
            }) { (finish) in
                
            }
            
        }else {
            view?.hidden = false
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                view?.alpha = 1
            }) { (finish) in
            }
        }
    }
    
    /**
     Finish the selected calendar call
     */
    func dismissCalendar() {
        let view = pagingMenuController!.view.viewWithTag(CALENDAR_VIEW_TAG)
        if(view != nil) {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                view?.alpha = 0
            }) { (finish) in
                view?.hidden = true
            }
        }
    }
    
    /**
     Click on the calendar the blanks
     - parameter recognizer: recognizer description
     */
    func tapAction(recognizer:UITapGestureRecognizer) {
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
    }
}

// MARK: - CVCalendarViewDelegate, CVCalendarMenuViewDelegate
extension StepController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func dayOfWeekTextUppercase() -> Bool {
        return false
    }
    // MARK: Optional methods
    func shouldShowWeekdaysOut() -> Bool {
        return false
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        dayView.selectionView?.shape = CVShape.Rect
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
        let dayDate:NSDate = dayView.date!.convertedDate()!
        SwiftEventBus.post(SELECTED_CALENDAR_NOTIFICATION, userInfo: ["selectedDate":dayDate])
        
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return false
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return true
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return false
    }
    
    func presentedDateUpdated(date: CVDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.stringFromDate(date.convertedDate()!)), \(date.day)"
        titleView?.setCalendarButtonTitle(dateString)
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return false
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .VeryShort
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
}

// MARK: - CVCalendarViewAppearanceDelegate
extension StepController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor(rgba: "#7ED8D1")
    }
    
    /// Text color.
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
//    func dayLabelPresentWeekdayTextColor() -> UIColor {
//        return UIColor.whiteColor()
//    }
    
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
}