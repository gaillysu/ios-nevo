    //
//  PageViewController.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/17.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import UIColor_Hex_Swift
import CVCalendar
import SwiftEventBus
import LTNavigationBar
import SnapKit
import RealmSwift
import Solar
 

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
        if((UIDevice.current.systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge();
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
        
        reloadPageControll()
        
        //set_goal
        let rightItem:UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("set_goal", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonAction(_:)))
        
        let rightSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        rightSpacer.width = 0;
        self.navigationItem.rightBarButtonItems = [rightSpacer,rightItem]
        
        let leftItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_radio"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonAction(_:)))
        
        let leftSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        leftSpacer.width = -10;
        
        leftItem.viewDefaultColorful()
        rightItem.viewDefaultColorful()
        viewDefaultColorful()
        
        // MARK: - SET WATCH_ID NOTIFICATION
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_WATCHID_DIDCHANGE_KEY) { (notification) in
            //let dict:[String:Int] = notification.userInfo as! [String : Int]
            self.reloadPageControll()
            self.setNumberOfPages()
        }
    }
    
    override func viewDidLayoutSubviews() {
        if titleView == nil {
            self.initTitleView()
            self.bulidPageControl()
        }
        
        tabBarController?.tabBar.subviewsSatisfy(theCondition: { (v) -> (Bool) in
            return v.frame.height == 0.5
        }, do: { (v) in
            
        })
    }
    
    deinit {
        SwiftEventBus.unregister(self, name: EVENT_BUS_WATCHID_DIDCHANGE_KEY)
    }
    
    func reloadPageControll() {
        pagingControllers.removeAll()
        
        let viewController1 = getDashBoardController()
        viewController1.view.tag = 0
        let viewController2 = StepsHistoryViewController()
        viewController2.view.tag = 1
        let viewController3 = SleepHistoricalViewController()
        viewController3.view.tag = 2
        
        pagingControllers = [viewController1, viewController2,viewController3]
        
        let value:Int = ConnectionManager.manager.getWatchID()
        
        if value>1 {
            let viewController4 = SolarIndicatorController()
            viewController4.view.tag = pagingControllers.count
            pagingControllers.append(viewController4)
        }
        
        self.delegate = self
        self.dataSource = self;
        self.setViewControllers([pagingControllers[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { (fines) in
        }
        self.bulidPageControl()
    }
    
    func leftBarButtonAction(_ rightBar:UIBarButtonItem) {
        let videoPlay:VideoPlayController = VideoPlayController()
        self.present(videoPlay, animated: true, completion: nil)
    }
    
    func rightBarButtonAction(_ rightBar:UIBarButtonItem){
        
        let actionSheet:MEDAlertController = MEDAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.isSetSubView = true;
        
        let array = MEDUserGoal.getAll()
        for pArray in array {
            let model:MEDUserGoal = pArray as! MEDUserGoal
            if(model.status){
                let titleString:String = "\(model.label): \(model.stepsGoal) " + NSLocalizedString("steps_unit", comment: "")
                let alertAction2:AlertAction = AlertAction(title: titleString, style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
                    if((action.title! as NSString).isEqual(to: titleString)){
                        UserDefaults.standard.set(model.stepsGoal, forKey: NUMBER_OF_STEPS_GOAL_KEY)
                        self.setGoal(NumberOfStepsGoal(steps: model.stepsGoal))
                    }
                }
                alertAction2.setValue(UIColor.baseColor, forKey: "titleTextColor")
                actionSheet.addAction(alertAction2)
            }
        }
        
        let alertAction:AlertAction = AlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        alertAction.setValue(UIColor.baseColor, forKey: "titleTextColor")
        actionSheet.addAction(alertAction)
        
        self.present(actionSheet, animated: true, completion:nil)
    }
    
    func setGoal(_ goal:Goal) {
        if ConnectionManager.manager.isConnected {
            let banner = MEDBanner(title: NSLocalizedString("syncing_goal", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
            ConnectionManager.manager.setGoal(goal)
        }else{
            let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
        }
        
    }
}

extension PageViewController {
    func bulidPageControl() {
        if let pageView = self.view.viewWithTag(1900) {
            return
        }
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
        pageControl.tag = 1900
        pageControl.numberOfPages = pagingControllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.baseColor
        pageControl.addTarget(self, action: #selector(pageAction(_ :)), for: UIControlEvents.valueChanged)
        
        pageControl.isUserInteractionEnabled = false
        
        self.view.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
        }
        
        pageControl.currentPageIndicatorTintColor = UIColor.baseColor
    }
    
    func setNumberOfPages() {
        for view in self.view.subviews {
            if view is  UIPageControl{
                let page:UIPageControl = view as! UIPageControl
                page.numberOfPages = pagingControllers.count
                break
            }
        }
    }
    
    func setCurrentPageIndex(_ index:Int) {
        for view in self.view.subviews {
            if view is  UIPageControl{
                let page:UIPageControl = view as! UIPageControl
                page.currentPage = index
                page.size(forNumberOfPages: index)
                break
            }
        }
    }
    
    func pageAction(_ pageControl: UIPageControl) {
        print("currentPage is \(pageControl.currentPage)")
    }
}

extension PageViewController: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    //返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        self.setCurrentPageIndex(viewController.view.tag)
        if viewController.isKind(of: getDashBoardController().classForCoder) {
            return pagingControllers[1]
        }else if viewController.isKind(of: StepsHistoryViewController.self) {
            return pagingControllers[2]
        }else if viewController.isKind(of: SleepHistoricalViewController.self) {
            if pagingControllers.count>3 {
                return pagingControllers[3]
            }
            return nil
        }
        return nil
    }
    
    //返回当前页面的上一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        self.setCurrentPageIndex(viewController.view.tag)
        if viewController.isKind(of: StepsHistoryViewController.self) {
            return pagingControllers[0]
        }else if viewController.isKind(of: SleepHistoricalViewController.self) {
            return pagingControllers[1]
        }else if viewController.isKind(of: SolarIndicatorController.self){
            return pagingControllers[2]
        }else {
            if pagingControllers.count>3 {
                return pagingControllers[3]
            }
            return nil
        }
    }
}

// MARK: - Title View
extension PageViewController {
    
    func initTitleView() {
        titleView = StepsTitleView.getStepsTitleView(CGRect(x: 0,y: 0,width: 190,height: 50))
        let dateString = "\(Date().stringFromFormat("MMM")), \(Date().day)"
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
            
            let fillView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 240))
            calendarBackGroundView.addSubview(fillView)
            
            self.menuView = CVCalendarMenuView(frame: CGRect(x: 0, y: 5, width: UIScreen.main.bounds.size.width, height: 30))
            self.menuView?.dayOfWeekFont = UIFont.systemFont(ofSize: 15)
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)
            
            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRect(x: 0, y: (self.menuView?.frame.origin.y)! + (self.menuView?.frame.height)!, width: UIScreen.main.bounds.size.width, height: fillView.frame.height - (self.menuView?.frame.height)!))
            
            calendarView?.isHidden = false
            fillView.addSubview(calendarView!)
            self.calendarView!.calendarAppearanceDelegate = self
            self.calendarView!.animatorDelegate = self
            self.calendarView!.calendarDelegate = self
            
            // Commit frames' updates
            self.calendarView!.commitCalendarViewUpdate()
            self.menuView!.commitMenuViewUpdate()
            
            fillView.backgroundColor = UIColor.getCalendarColor()
            self.calendarView?.backgroundColor = UIColor.getCalendarColor()
            self.menuView?.backgroundColor = UIColor.getCalendarColor()
            self.menuView?.dayOfWeekTextColor = UIColor.black
            
            calendarView?.coordinator.selectedDayView?.selectionView?.shape = CVShape.rect
            
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
    
    func dayOfWeekTextColor() -> UIColor{
        return UIColor.gray
    }
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .sunday
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
    
    func shouldSelectDayView(_ dayView: DayView) -> Bool {
        let dayDate:Date = dayView.date!.convertedDate(calendar: Calendar.current)!
        
        let nowDate:Date = Date()
        
        if (dayDate - nowDate) > 0 {
            if dayDate.year == nowDate.year && dayDate.month == nowDate.month && dayDate.day == nowDate.day {
                return true
            } else {
                return false
            }
            
        } else {
            return true
        }
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        dayView.selectionView?.shape = CVShape.rect
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
        let dayDate:Date = dayView.date!.convertedDate(calendar: Calendar.current)!
        
        let nowDate:Date = Date()
        if (dayDate.year >= nowDate.year) && (dayDate.month >= nowDate.month) && (dayDate.day > dayDate.day) {
        }
        
        SwiftEventBus.post(SELECTED_CALENDAR_NOTIFICATION, userInfo: ["selectedDate":dayDate])
        
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return false
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return true
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return false
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.string(from: date.convertedDate(calendar: Calendar.current)!)), \(date.day)"
        titleView?.setCalendarButtonTitle(dateString)
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return false
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .short
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
        return UIColor.baseColor
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor{
        return UIColor.baseColor
    }
    
    func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor {
        return UIColor.black
    }
    
    
    /// Text color.
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return UIColor.white
    }
    
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return UIColor.white
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor?{
        return UIColor.baseColor
    }
}

extension PageViewController {
    func getDashBoardController() -> UIViewController {
        return StepGoalSetingController()
    }
}
