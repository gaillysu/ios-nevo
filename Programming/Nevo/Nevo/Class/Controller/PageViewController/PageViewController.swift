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
    fileprivate var goalArray:[Int] = []
    var calendarView:CVCalendarView?
    var menuView:CVCalendarMenuView?
    var titleView:StepsTitleView?
    
    fileprivate var pagingControllers: [UIViewController] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController1 = StepGoalSetingController()
        viewController1.view.backgroundColor = UIColor.white
        let viewController2 = StepsHistoryViewController()
        viewController2.view.backgroundColor = UIColor.white
        let viewController3 = SleepHistoricalViewController()
        viewController3.view.backgroundColor = UIColor.white
        let viewController4 = SolarIndicatorController()
        viewController4.view.backgroundColor = UIColor.white
        pagingControllers = [viewController1, viewController2,viewController3,viewController4]
        
        if((UIDevice.current.systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge();
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
        self.view.backgroundColor = UIColor.white
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonAction(_:)))
        rightItem.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        
        let rightSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        rightSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = [rightSpacer,rightItem]
        
        let leftItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_radio"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonAction(_:)))
        leftItem.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        
        let leftSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        leftSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = [leftSpacer,leftItem]
        
        self.dataSource = self;
        self.setViewControllers([pagingControllers[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: true) { (fines) in
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        if titleView == nil {
            self.initTitleView()
            let leftButton:UIButton = UIButton(type: UIButtonType.system)
            leftButton.setImage(UIImage(named: "left_button"), for: UIControlState())
            leftButton.tag = 1900
            leftButton.frame = CGRect(x: 0, y: 0, width: 35, height: 125)
            leftButton.imageEdgeInsets = UIEdgeInsets(top: (125.0-30.0)/2.0, left: 10, bottom: (125.0-30.0)/2.0, right: 10)
            leftButton.addTarget(self, action: #selector(slidingAction(_:)), for: UIControlEvents.touchUpInside)
            leftButton.tintColor = UIColor.getWhiteBaseColor()
            leftButton.center = CGPoint(x: leftButton.frame.size.width/2.0, y: self.view.frame.size.height/2.0-70)
            self.view.addSubview(leftButton)
            
            let rightButton:UIButton = UIButton(type: UIButtonType.system)
            rightButton.setImage(UIImage(named: "right_button"), for: UIControlState())
            rightButton.tag = 1910
            rightButton.frame = CGRect(x: 0, y: 0, width: 35, height: 125)
            rightButton.imageEdgeInsets = UIEdgeInsets(top: (125.0-30.0)/2.0, left: 10, bottom: (125.0-30.0)/2.0, right: 10)
            rightButton.addTarget(self, action: #selector(slidingAction(_:)), for: UIControlEvents.touchUpInside)
            rightButton.tintColor = UIColor.getWhiteBaseColor()
            rightButton.center = CGPoint(x: UIScreen.main.bounds.size.width-rightButton.frame.size.width/2.0, y: self.view.frame.size.height/2.0-70)
            self.view.addSubview(rightButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slidingAction(_ sender:UIButton) {
        
    }
    
    func leftBarButtonAction(_ rightBar:UIBarButtonItem) {
        let videoPlay:VideoPlayController = VideoPlayController()
        self.present(videoPlay, animated: true, completion: nil)
    }
    
    func rightBarButtonAction(_ rightBar:UIBarButtonItem){
        let actionSheet:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let array:NSArray = Presets.getAll()
        for pArray in array {
            let model:Presets = pArray as! Presets
            if(model.status){
                let titleString:String = " \(model.steps) " + NSLocalizedString("steps_unit", comment: "")
                let alertAction2:UIAlertAction = UIAlertAction(title: titleString, style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
                    if((action.title! as NSString).isEqual(to: titleString)){
                        UserDefaults.standard.set(model.steps, forKey: NUMBER_OF_STEPS_GOAL_KEY)
                        self.setGoal(NumberOfStepsGoal(steps: model.steps))
                    }
                }
                alertAction2.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                actionSheet.addAction(alertAction2)
            }
        }
        
        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        alertAction.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
        //alertAction.setValue(UIImage(named: "google"), forKey: "Image")
        //alertAction.setValue(true, forKey: "checked")
        actionSheet.addAction(alertAction)
        
        self.present(actionSheet, animated: true, completion:nil)
    }
    
    func setGoal(_ goal:Goal) {
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
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: StepGoalSetingController.self) {
            return pagingControllers[1]
        }else if viewController.isKind(of: StepsHistoryViewController.self) {
            return pagingControllers[2]
        }else if viewController.isKind(of: SleepHistoricalViewController.self) {
            return pagingControllers[3]
        }
        
        return nil
        
    }
    
    //返回当前页面的上一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: SolarIndicatorController.self) {
            return pagingControllers[2]
        }else if viewController.isKind(of: SleepHistoricalViewController.self) {
            return pagingControllers[1]
        }else if viewController.isKind(of: StepsHistoryViewController.self) {
            return pagingControllers[0]
        }
        return nil
    }
}

// MARK: - Title View
extension PageViewController {
    
    func initTitleView() {
        titleView = StepsTitleView.getStepsTitleView(CGRect(x: 0,y: 0,width: 190,height: 50))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.string(from: Date())), \(Date().day)"
        titleView?.setCalendarButtonTitle(dateString)
        self.navigationItem.titleView = titleView
        titleView!.buttonResultHandler = { result -> Void in
            let clickButton:UIButton = result as! UIButton
            if (result!.isEqual(self.titleView!.calendarButton) && clickButton.isSelected) {
                self.showCalendar()
            }else if (result!.isEqual(self.titleView!.calendarButton) && !clickButton.isSelected) {
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
            let calendarBackGroundView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: self.view.frame.size.height))
            calendarBackGroundView.alpha = 0
            calendarBackGroundView.backgroundColor = UIColor(white: 120/255.0, alpha: 0.5)
            calendarBackGroundView.tag = CALENDAR_VIEW_TAG
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            calendarBackGroundView.addGestureRecognizer(tap)
            self.view.addSubview(calendarBackGroundView)
            
            let fillView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 260))
            fillView.backgroundColor = UIColor.getCalendarColor()
            calendarBackGroundView.addSubview(fillView)
            
            self.menuView = CVCalendarMenuView(frame: CGRect(x: 10, y: 20, width: UIScreen.main.bounds.size.width - 20, height: 20))
            self.menuView?.dayOfWeekTextColor = UIColor.black
            self.menuView?.dayOfWeekFont = UIFont.systemFont(ofSize: 15)
            self.menuView?.backgroundColor = UIColor.getCalendarColor()
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)
            
            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRect(x: 10, y: 40, width: UIScreen.main.bounds.size.width - 20, height: 220))
            self.calendarView?.backgroundColor = UIColor.getCalendarColor()
            calendarView?.isHidden = false
            fillView.addSubview(calendarView!)
            self.calendarView!.calendarAppearanceDelegate = self
            self.calendarView!.animatorDelegate = self
            self.calendarView!.calendarDelegate = self
            
            // Commit frames' updates
            self.calendarView!.commitCalendarViewUpdate()
            self.menuView!.commitMenuViewUpdate()
            
            calendarView?.coordinator.selectedDayView?.selectionView?.shape = CVShape.Rect
            
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                calendarBackGroundView.alpha = 1
            }) { (finish) in
                
            }
            
        }else {
            view?.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
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
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                view?.alpha = 0
            }) { (finish) in
                view?.isHidden = true
            }
        }
    }
    
    /**
     Click on the calendar the blanks
     - parameter recognizer: recognizer description
     */
    func tapAction(_ recognizer:UITapGestureRecognizer) {
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
    }
}

// MARK: - CVCalendarViewDelegate, CVCalendarMenuViewDelegate
extension PageViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        dayView.selectionView?.shape = CVShape.Rect
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
        let dayDate:Date = dayView.date!.convertedDate()!
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
    
    func presentedDateUpdated(_ date: CVDate) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.string(from: date.convertedDate()!)), \(date.day)"
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
        return UIColor.black
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return AppTheme.NEVO_SOLAR_YELLOW()
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor{
        return AppTheme.NEVO_SOLAR_YELLOW()
    }
    
    func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor {
        return UIColor.black
    }
    
    /// Text color.
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return UIColor.white
    }
    
    //    func dayLabelPresentWeekdayTextColor() -> UIColor {
    //        return UIColor.whiteColor()
    //    }
    
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return UIColor.white
    }
}
