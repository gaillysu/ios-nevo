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
    fileprivate var realm:Realm?
    fileprivate var goalArray:[Int] = []
    var calendarView:CVCalendarView?
    var menuView:CVCalendarMenuView?
    var titleView:StepsTitleView?
    fileprivate var selectedController:UIViewController?
    fileprivate var pagingControllers: [UIViewController] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if((UIDevice.current.systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge();
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
        
        realm = try! Realm()
        
        let viewController1 = StepGoalSetingController()
        viewController1.view.tag = 0
        viewController1.view.backgroundColor = UIColor.white
        let viewController2 = StepsHistoryViewController()
        viewController2.view.tag = 1
        viewController2.view.backgroundColor = UIColor.white
        let viewController3 = SleepHistoricalViewController()
        viewController3.view.tag = 2
        viewController3.view.backgroundColor = UIColor.white
        
        
        pagingControllers = [viewController1, viewController2,viewController3]
        selectedController = pagingControllers[0]
        
        if UserDefaults.standard.object(forKey: "WATCHNAME_KEY") != nil {
            let value:Int = UserDefaults.standard.object(forKey: "WATCHNAME_KEY") as! Int
            if value>1 {
                let viewController4 = SunriseSetController()
                viewController4.view.tag = 3
                viewController4.view.backgroundColor = UIColor.white
                pagingControllers.append(viewController4)
                
                let viewController5 = SolarIndicatorController()
                viewController5.view.tag = 4
                viewController5.view.backgroundColor = UIColor.white
                pagingControllers.append(viewController5)
            }
        }
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonAction(_:)))
        rightItem.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        
        let rightSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        rightSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = [rightSpacer,rightItem]
        
        let leftItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_radio"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonAction(_:)))
        leftItem.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        
        let leftSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        leftSpacer.width = -10;
//        self.navigationItem.leftBarButtonItems = [leftSpacer,leftItem]
        
        self.delegate = self
        self.dataSource = self;
        self.setViewControllers([pagingControllers[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: true) { (fines) in
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo(){
            self.view.backgroundColor = UIColor.getGreyColor()
            leftItem.tintColor = UIColor.getBaseColor()
            rightItem.tintColor = UIColor.getBaseColor()
        }else{
            self.view.backgroundColor = UIColor.white
        }
        
        // MARK: - SET WATCH_ID NOTIFICATION
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_WATCHID_DIDCHANGE_KEY) { (notification) in
            let dict:[String:Int] = notification.userInfo as! [String : Int]
        }
    }
    
    override func viewDidLayoutSubviews() {
        if titleView == nil {
            self.initTitleView()
            self.bulidPageControl()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leftBarButtonAction(_ rightBar:UIBarButtonItem) {
        let videoPlay:VideoPlayController = VideoPlayController()
        self.present(videoPlay, animated: true, completion: nil)
    }
    
    func rightBarButtonAction(_ rightBar:UIBarButtonItem){
        if selectedController!.isKind(of: SunriseSetController.self) {
            let addWorldClock:AddWorldClockViewController = AddWorldClockViewController()
            addWorldClock.didSeletedCityDelegate = self
            addWorldClock.hidesBottomBarWhenPushed = true
            let nav:UINavigationController = UINavigationController(rootViewController: addWorldClock)
            self.present(nav, animated: true, completion: nil)
            //self.navigationController?.pushViewController(addWorldClock, animated: true)
        }else{
            let actionSheet:ActionSheetView = ActionSheetView(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSheet.isSetSubView = true;
            
            let array:NSArray = Presets.getAll()
            for pArray in array {
                let model:Presets = pArray as! Presets
                if(model.status){
                    let titleString:String = " \(model.steps) " + NSLocalizedString("steps_unit", comment: "")
                    let alertAction2:AlertAction = AlertAction(title: titleString, style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
                        if((action.title! as NSString).isEqual(to: titleString)){
                            UserDefaults.standard.set(model.steps, forKey: NUMBER_OF_STEPS_GOAL_KEY)
                            self.setGoal(NumberOfStepsGoal(steps: model.steps))
                        }
                    }
                    if !AppTheme.isTargetLunaR_OR_Nevo() {
                        alertAction2.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
                    }else{
                        alertAction2.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
                    }
                    actionSheet.addAction(alertAction2)
                }
            }
            
            let alertAction:AlertAction = AlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                alertAction.setValue(UIColor.getBaseColor(), forKey: "titleTextColor")
            }else{
                alertAction.setValue(AppTheme.NEVO_SOLAR_YELLOW(), forKey: "titleTextColor")
            }
            //alertAction.setValue(UIImage(named: "google"), forKey: "Image")
            //alertAction.setValue(true, forKey: "checked")
            actionSheet.addAction(alertAction)
            
            self.present(actionSheet, animated: true, completion:nil)
        }
    }
    
    func setGoal(_ goal:Goal) {
        if(AppDelegate.getAppDelegate().isConnected()){
            let banner = MEDBanner(title: NSLocalizedString("syncing_goal", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
            AppDelegate.getAppDelegate().setGoal(goal)
        }else{
            let banner = MEDBanner(title: NSLocalizedString("no_watch_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: AppTheme.NEVO_SOLAR_YELLOW())
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
        }
        
    }
}

extension PageViewController:WorldClockDidSelectedDelegate{
    func didSelectedLocalTimeZone(_ cityId:Int){
        let citiesArray:[City] = Array(realm!.objects(City.self).filter("selected = true"))
        let city = citiesArray[0]
        
        let solar = Solar(latitude: city.lat,
                          longitude: city.lng)
        let sunrise = solar!.sunrise
        let sunset = solar!.sunset
        let offset = String(format: "%.0f", (sunrise!.timeIntervalSince1970-sunset!.timeIntervalSince1970)/3600)
        if AppDelegate.getAppDelegate().isConnected() {
            let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: offset.toInt())
            AppDelegate.getAppDelegate().sendRequest(setWordClock)
        }
        
    }
}

extension PageViewController {
    func bulidPageControl() {
        let pageControl = UIPageControl(frame: CGRect(x: 100, y: UIScreen.main.bounds.size.height-44, width: 100, height: 20))
        pageControl.numberOfPages = pagingControllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        pageControl.addTarget(self, action: #selector(pageAction(_ :)), for: UIControlEvents.valueChanged)
        
        pageControl.isUserInteractionEnabled = false
        
        self.view.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            pageControl.currentPageIndicatorTintColor = UIColor.getBaseColor()
        }else{
            pageControl.currentPageIndicatorTintColor = AppTheme.NEVO_SOLAR_YELLOW()
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
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        selectedController = previousViewControllers.first
    }
    
    //返回当前页面的下一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.setCurrentPageIndex(viewController.view.tag)
        if viewController.isKind(of: StepGoalSetingController.self) {
            selectedController = pagingControllers[1]
            return selectedController
        }else if viewController.isKind(of: StepsHistoryViewController.self) {
            selectedController = pagingControllers[2]
            return selectedController
        }else if viewController.isKind(of: SleepHistoricalViewController.self) {
            if pagingControllers.count>3 {
                selectedController = pagingControllers[3]
                return selectedController
            }
            return nil
        }else if viewController.isKind(of: SunriseSetController.self) {
            if pagingControllers.count>4 {
                selectedController = pagingControllers[4]
                return selectedController
            }
            return nil
        }
        
        return nil
        
    }
    
    //返回当前页面的上一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.setCurrentPageIndex(viewController.view.tag)
        if viewController.isKind(of: SolarIndicatorController.self){
            selectedController = pagingControllers[3]
            return selectedController
        }else if viewController.isKind(of: SunriseSetController.self) {
            selectedController = pagingControllers[2]
            return selectedController
        }else if viewController.isKind(of: SleepHistoricalViewController.self) {
            selectedController = pagingControllers[1]
            return selectedController
        }else if viewController.isKind(of: StepsHistoryViewController.self) {
            selectedController = pagingControllers[0]
            return selectedController
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
            calendarBackGroundView.addSubview(fillView)
            
            self.menuView = CVCalendarMenuView(frame: CGRect(x: 10, y: 20, width: UIScreen.main.bounds.size.width - 20, height: 20))
            self.menuView?.dayOfWeekFont = UIFont.systemFont(ofSize: 15)
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)
            
            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRect(x: 10, y: 40, width: UIScreen.main.bounds.size.width - 20, height: 220))
            
            calendarView?.isHidden = false
            fillView.addSubview(calendarView!)
            self.calendarView!.calendarAppearanceDelegate = self
            self.calendarView!.animatorDelegate = self
            self.calendarView!.calendarDelegate = self
            
            // Commit frames' updates
            self.calendarView!.commitCalendarViewUpdate()
            self.menuView!.commitMenuViewUpdate()
            
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                self.calendarView?.backgroundColor = UIColor.getLightBaseColor()
                fillView.backgroundColor = UIColor.getLightBaseColor()
                self.menuView?.backgroundColor = UIColor.getLightBaseColor()
                self.menuView?.dayOfWeekTextColor = UIColor.white
            }else{
                fillView.backgroundColor = UIColor.getCalendarColor()
                self.calendarView?.backgroundColor = UIColor.getCalendarColor()
                self.menuView?.backgroundColor = UIColor.getCalendarColor()
                self.menuView?.dayOfWeekTextColor = UIColor.black
            }
            
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
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            return UIColor.white
        }else{
            return UIColor.gray
        }
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
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        dayView.selectionView?.shape = CVShape.rect
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
        let dayDate:Date = dayView.date!.convertedDate()!
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
        let dateString = "\(formatter.string(from: date.convertedDate()!)), \(date.day)"
        titleView?.setCalendarButtonTitle(dateString)
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return false
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .veryShort
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
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            return UIColor.white
        }else{
            return UIColor.black
        }
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            return UIColor.getBaseColor()
        }else{
            return AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor{
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            return UIColor.getBaseColor()
        }else{
            return AppTheme.NEVO_SOLAR_YELLOW()
        }
    }
    
    func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            return UIColor.white
        }else{
            return UIColor.black
        }
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
