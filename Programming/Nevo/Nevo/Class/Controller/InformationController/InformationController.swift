//
//  InformationController.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SMSegmentView
import AutocompleteField
import Timepiece
import XCGLogger
import BRYXBanner
import MRProgress
import SwiftyTimer
import SwiftyJSON

class InformationController: UIViewController,SMSegmentViewDelegate {

    @IBOutlet weak var metricsSegment: UIView!
    @IBOutlet weak var dateOfbirth: AutocompleteField!
    @IBOutlet weak var heightTextField: AutocompleteField!
    @IBOutlet weak var weightTextfield: AutocompleteField!
    
    var segmentView:SMSegmentView?
    var registerInfor:[String:String] = [:]
    
    init() {
        super.init(nibName: "InformationController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Register"
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(rightAction(_:)))
        self.navigationItem.rightBarButtonItem = leftButton
        
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.backgroundColor = UIColor.whiteColor()
        dateOfbirth.inputView = datePicker
        datePicker.addTarget(self, action: #selector(selectedDateAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        heightTextField.keyboardType = UIKeyboardType.NumberPad;
        weightTextfield.keyboardType = UIKeyboardType.NumberPad
    }
    
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        let segmentProperties = ["OnSelectionBackgroundColour": AppTheme.NEVO_SOLAR_YELLOW(),"OffSelectionBackgroundColour": UIColor.whiteColor(),"OnSelectionTextColour": UIColor.whiteColor(),"OffSelectionTextColour": AppTheme.NEVO_SOLAR_YELLOW()]
        if segmentView == nil {
            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 1.0, segmentProperties: segmentProperties)
            segmentView!.delegate = self
            segmentView!.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
            segmentView!.layer.borderWidth = 1.0
            segmentView?.layer.cornerRadius = 10
            
            // Add segments
            segmentView!.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
            segmentView?.selectSegmentAtIndex(0)
            metricsSegment.addSubview(segmentView!)
        }
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    // MARK: - SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        debugPrint("Select segment at index: \(index)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func rightAction(sender:UIBarButtonItem) {
        self.registerRequest()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dateOfbirth.resignFirstResponder()
        heightTextField.resignFirstResponder()
        weightTextfield.resignFirstResponder()
    }
    
    func selectedDateAction(date:UIDatePicker) {
        NSLog("date:\(date.date)")
        dateOfbirth.text = date.date.stringFromFormat("yyyy-MM-dd")
    }
    
    func registerRequest() {
        if AppDelegate.getAppDelegate().network!.isReachable {
            if(AppTheme.isNull(dateOfbirth!.text!) || AppTheme.isNull(heightTextField.text!) || AppTheme.isNull(weightTextfield.text!)) {
                let banner = Banner(title: NSLocalizedString("One of the fields are empty.", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 0.6)
                return
            }
            
            let sex:Int = self.segmentView?.indexOfSelectedSegment == 0 ? 1 : 0
            registerInfor["birthday"] = dateOfbirth!.text!
            registerInfor["length"] = heightTextField!.text!
            registerInfor["weight"] = weightTextfield!.text!
            registerInfor["sex"] = "\(sex)"
            
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            view.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
            
            //timeout
            let timeout:NSTimer = NSTimer.after(50.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
            
            HttpPostRequest.LunaRPostRequest("http://nevo.karljohnchow.com/user/create", data: ["user":registerInfor]) { (result) in
                
                timeout.invalidate()
                
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                
                let json = JSON(result)
                var message = json["message"].stringValue
                let status = json["status"].intValue
                let user:[String : JSON] = json["user"].dictionaryValue
                
                if(user.count>0) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "y-M-d h:m:s.000000"
                    let birthdayJSON = user["birthday"]
                    let birthdayBeforeParsed = birthdayJSON!["date"].stringValue
                    
                    let birthdayDate = dateFormatter.dateFromString(birthdayBeforeParsed)
                    dateFormatter.dateFormat = "y-M-d"
                    let birthday = dateFormatter.stringFromDate(birthdayDate!)
                    let sex = user["sex"]!.intValue == 1 ? true : false;
                    if(status > 0 && UserProfile.getAll().count == 0) {
                        message = NSLocalizedString("register_success", comment: "");
                        let userprofile:UserProfile = UserProfile(keyDict: ["id":user["id"]!.intValue,"first_name":user["first_name"]!.stringValue,"last_name":user["last_name"]!.stringValue,"length":user["length"]!.intValue,"email":user["email"]!.stringValue,"sex": sex, "weight":(user["weight"]?.floatValue)!, "birthday":birthday])
                        userprofile.add({ (id, completion) in
                        })
                        self.dismissViewControllerAnimated(true, completion: nil)
                        //self.navigationController?.popViewControllerAnimated(true)
                    }else{
                        
                        
                        switch status {
                        case -1:
                            message = NSLocalizedString("access_denied", comment: "");
                        case -2:
                            message = "";
                        case -3:
                            message = NSLocalizedString("user_exist", comment: "");
                            break
                        
                        default: message = NSLocalizedString("signup_failed", comment: "")
                        }
                    }
                    
                }else{
                    if message.isEmpty {
                        message = NSLocalizedString("no_network", comment: "")
                    }
                    
                }
                
                let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
            }
        }else{
            XCGLogger.defaultInstance().debug("注册的时候没有网络")
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.Cross, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            NSTimer.after(0.6.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
        }
    }
}

extension InformationController:UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == nil {
            return;
        }
        if textField.isEqual(heightTextField) {
            
        }
        
        if textField.isEqual(weightTextfield) {
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
}