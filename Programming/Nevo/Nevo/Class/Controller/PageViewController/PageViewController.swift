//
//  PageViewController.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/17.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import Timepiece
import UIColor_Hex_Swift
import XCGLogger
import CVCalendar
import SwiftEventBus
import LTNavigationBar

let SELECTED_CALENDAR_NOTIFICATION = "SELECTED_CALENDAR_NOTIFICATION"
private let CALENDAR_VIEW_TAG = 1800

class PageViewController: UIPageViewController,UIActionSheetDelegate {
    private var goalArray:[Int] = []
    var calendarView:CVCalendarView?
    var menuView:CVCalendarMenuView?
    var titleView:StepsTitleView?
    
    private var pagingControllers: [UIViewController] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController1 = StepGoalSetingController()
        viewController1.view.backgroundColor = UIColor.whiteColor()
        let viewController2 = StepsHistoryViewController()
        viewController2.view.backgroundColor = UIColor.whiteColor()
        let viewController3 = SleepHistoricalViewController()
        viewController3.view.backgroundColor = UIColor.whiteColor()
        let viewController4 = SolarIndicatorController()
        viewController4.view.backgroundColor = UIColor.whiteColor()
        pagingControllers = [viewController1, viewController2,viewController3,viewController4]
        
        if((UIDevice.currentDevice().systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge.None;
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
        self.view.backgroundColor = UIColor.whiteColor()
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(rightBarButtonAction(_:)))
        rightItem.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        
        let rightSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        rightSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = [rightSpacer,rightItem]
        
        let leftItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_radio"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(leftBarButtonAction(_:)))
        leftItem.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        
        let leftSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        leftSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = [leftSpacer,leftItem]
        
        self.dataSource = self;
        self.setViewControllers([pagingControllers[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true) { (fines) in
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        if titleView == nil {
            self.initTitleView()
            let leftButton:UIButton = UIButton(type: UIButtonType.System)
            leftButton.setImage(UIImage(named: "left_button"), forState: UIControlState.Normal)
            leftButton.tag = 1900
            leftButton.frame = CGRectMake(0, 0, 35, 125)
            leftButton.imageEdgeInsets = UIEdgeInsets(top: (125.0-30.0)/2.0, left: 10, bottom: (125.0-30.0)/2.0, right: 10)
            leftButton.addTarget(self, action: #selector(slidingAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            leftButton.tintColor = UIColor.getWhiteBaseColor()
            leftButton.center = CGPointMake(leftButton.frame.size.width/2.0, self.view.frame.size.height/2.0-70)
            self.view.addSubview(leftButton)
            
            let rightButton:UIButton = UIButton(type: UIButtonType.System)
            rightButton.setImage(UIImage(named: "right_button"), forState: UIControlState.Normal)
            rightButton.tag = 1910
            rightButton.frame = CGRectMake(0, 0, 35, 125)
            rightButton.imageEdgeInsets = UIEdgeInsets(top: (125.0-30.0)/2.0, left: 10, bottom: (125.0-30.0)/2.0, right: 10)
            rightButton.addTarget(self, action: #selector(slidingAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            rightButton.tintColor = UIColor.getWhiteBaseColor()
            rightButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-rightButton.frame.size.width/2.0, self.view.frame.size.height/2.0-70)
            self.view.addSubview(rightButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slidingAction(sender:UIButton) {
        
    }
    
    func leftBarButtonAction(rightBar:UIBarButtonItem) {
        let videoPlay:VideoPlayController = VideoPlayController()
        self.presentViewController(videoPlay, animated: true, completion: nil)
    }
    
    func rightBarButtonAction(rightBar:UIBarButtonItem){
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

extension PageViewController: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    //返回当前页面的下一个页面
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if viewController.isKindOfClass(StepGoalSetingController) {
            return pagingControllers[1]
        }else if viewController.isKindOfClass(StepsHistoryViewController) {
            return pagingControllers[2]
        }else if viewController.isKindOfClass(SleepHistoricalViewController) {
            return pagingControllers[3]
        }
        
        return nil
        
    }
    
    //返回当前页面的上一个页面
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKindOfClass(SolarIndicatorController) {
            return pagingControllers[2]
        }else if viewController.isKindOfClass(SleepHistoricalViewController) {
            return pagingControllers[1]
        }else if viewController.isKindOfClass(StepsHistoryViewController) {
            return pagingControllers[0]
        }
        return nil
    }
}

// MARK: - Title View
extension PageViewController {
    
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
            self.view.addSubview(calendarBackGroundView)
            
            let fillView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,260))
            fillView.backgroundColor = UIColor.getCalendarColor()
            calendarBackGroundView.addSubview(fillView)
            
            self.menuView = CVCalendarMenuView(frame: CGRectMake(10, 20, UIScreen.mainScreen().bounds.size.width - 20, 20))
            self.menuView?.dayOfWeekTextColor = UIColor.blackColor()
            self.menuView?.dayOfWeekFont = UIFont.systemFontOfSize(15)
            self.menuView?.backgroundColor = UIColor.getCalendarColor()
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)
            
            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRectMake(10, 40, UIScreen.mainScreen().bounds.size.width - 20, 220))
            self.calendarView?.backgroundColor = UIColor.getCalendarColor()
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
        let view = self.view.viewWithTag(CALENDAR_VIEW_TAG)
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
extension PageViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
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
extension PageViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return UIColor.blackColor()
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return AppTheme.NEVO_SOLAR_YELLOW()
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor{
        return AppTheme.NEVO_SOLAR_YELLOW()
    }
    
    func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor {
        return UIColor.blackColor()
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