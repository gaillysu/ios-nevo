//
//  InformationController.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import MRProgress
import SwiftyTimer
import SwiftyJSON
import XCGLogger

class InformationController: UIViewController,SMSegmentViewDelegate {

    @IBOutlet weak var metricsSegment: UIView!
    @IBOutlet weak var dateOfbirth: AutocompleteField!
    @IBOutlet weak var heightTextField: AutocompleteField!
    @IBOutlet weak var weightTextfield: AutocompleteField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailLabel2: UILabel!
    
    @IBOutlet weak var policyLabel: UILabel!
    
    var segmentView:SMSegmentView?
    var registerInfor:[String:String] = [:]
    
    init() {
        super.init(nibName: "InformationController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Register", comment: "")
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightAction(_:)))
        self.navigationItem.rightBarButtonItem = leftButton
        
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.backgroundColor = UIColor.white
        dateOfbirth.inputView = datePicker
        datePicker.addTarget(self, action: #selector(selectedDateAction(_:)), for: UIControlEvents.valueChanged)
        datePicker.maximumDate = NSDate() as Date
        
//        heightTextField.keyboardType = UIKeyboardType.numberPad;
//        weightTextfield.keyboardType = UIKeyboardType.numberPad
        let heightPickerView = UIPickerView()
        heightPickerView.dataSource = self
        heightPickerView.delegate = self
        heightTextField.inputView = heightPickerView
        let weightPickerView = UIPickerView()
        weightPickerView.dataSource = self
        weightPickerView.delegate = self
        weightTextfield.inputView = weightPickerView
        
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getGreyColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            detailLabel.backgroundColor = UIColor.clear
            detailLabel.textColor = UIColor.white
            detailLabel2.backgroundColor = UIColor.clear
            detailLabel2.textColor = UIColor.white
            
            policyLabel.backgroundColor = UIColor.clear
            policyLabel.textColor = UIColor.getBaseColor()
            
            dateOfbirth.backgroundColor = UIColor.getLightBaseColor()
            dateOfbirth.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            dateOfbirth.textColor = UIColor.white
            heightTextField.backgroundColor = UIColor.getLightBaseColor()
            heightTextField.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            heightTextField.textColor = UIColor.white
            weightTextfield.backgroundColor = UIColor.getLightBaseColor()
            weightTextfield.setValue(UIColor.white, forKeyPath: "placeholderLabel.textColor")
            weightTextfield.textColor = UIColor.white
        }
    }
    
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        let segmentProperties = ["OnSelectionBackgroundColour": AppTheme.NEVO_SOLAR_YELLOW(),"OffSelectionBackgroundColour": UIColor.white,"OnSelectionTextColour": UIColor.white,"OffSelectionTextColour": AppTheme.NEVO_SOLAR_YELLOW()]
        if segmentView == nil {
            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 1.0, segmentProperties: segmentProperties)
            segmentView!.delegate = self
            segmentView!.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().cgColor
            segmentView!.layer.borderWidth = 1.0
            segmentView?.layer.cornerRadius = 10
            
            segmentView!.addSegmentWithTitle(NSLocalizedString("Male", comment: ""), onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle(NSLocalizedString("Female", comment: ""), onSelectionImage: nil, offSelectionImage: nil)
            segmentView?.selectSegmentAtIndex(0)
            metricsSegment.addSubview(segmentView!)
            
            if !AppTheme.isTargetLunaR_OR_Nevo() {
                segmentView?.layer.borderColor = UIColor.getBaseColor().cgColor
                
                segmentView?.segmentOnSelectionColour = UIColor.getBaseColor()
                segmentView?.segmentOffSelectionColour = UIColor.getGreyColor()
                segmentView?.segmentOnSelectionTextColour = UIColor.white
                segmentView?.segmentOffSelectionTextColour = UIColor.getBaseColor()

            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    // MARK: - SMSegmentViewDelegate
    func segmentView(_ segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        debugPrint("Select segment at index: \(index)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func rightAction(_ sender:UIBarButtonItem) {
        self.registerRequest()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dateOfbirth.resignFirstResponder()
        heightTextField.resignFirstResponder()
        weightTextfield.resignFirstResponder()
    }
    
    func selectedDateAction(_ date:UIDatePicker) {
        NSLog("date:\(date.date)")
        
        dateOfbirth.text = date.date.stringFromFormat("yyyy-MM-dd")
        
        let languages = NSLocale.preferredLanguages
        print(languages)
        if let currentLang = languages.first {
            let langsArray = ["zh", "zh-Hans", "zh-Hant", "zh-Hans-CN", "zh-Hant-CN"]
            if langsArray.contains(currentLang) {
                dateOfbirth.text = date.date.stringFromFormat("yyyy-MM-dd")
            } else {
                dateOfbirth.text = date.date.stringFromFormat("dd-MM-yyyy")
            }
        }
    }
    
    func registerRequest() {
        if AppDelegate.getAppDelegate().network!.isReachable {
            if(AppTheme.isNull(dateOfbirth!.text!) || AppTheme.isNull(heightTextField.text!) || AppTheme.isNull(weightTextfield.text!)) {
                // Add segments
                //"one_of_the_fields_are_empty."
                //"two_password_is_not_the_same"
                //"please_wait"
                let banner = MEDBanner(title: NSLocalizedString("one_of_the_fields_are_empty", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 0.6)
                return
            }
            
            let sex:Int = self.segmentView?.indexOfSelectedSegment == 0 ? 1 : 0
            registerInfor["birthday"] = dateOfbirth!.text!
            
            // 字典中的数据格式原来是没有单位的数字
            registerInfor["length"] = "\(heightTextField!.text!.toInt())"
            registerInfor["weight"] = "\(weightTextfield!.text!.toInt())"
            
            registerInfor["sex"] = "\(sex)"
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
            
            //timeout
            let timeout:Timer = Timer.after(50.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
            
            HttpPostRequest.postRequest("user/create", data: ["user":registerInfor as AnyObject]) { (result) in
                
                timeout.invalidate()
                
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                
                let json = JSON(result)
                var message = json["message"].stringValue
                let status = json["status"].intValue
                let user:[String : JSON] = json["user"].dictionaryValue
                
                if(user.count>0) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "y-M-d h:m:s.000000"
                    let birthdayJSON = user["birthday"]
                    let birthdayBeforeParsed = birthdayJSON!["date"].stringValue
                    
                    let birthdayDate = dateFormatter.date(from: birthdayBeforeParsed)
                    dateFormatter.dateFormat = "y-M-d"
                    let birthday = dateFormatter.string(from: birthdayDate!)
                    let sex = user["sex"]!.intValue == 1 ? true : false;
                    if(status > 0 && UserProfile.getAll().count == 0) {
                        message = NSLocalizedString("register_success", comment: "");
                        let userprofile:UserProfile = UserProfile(keyDict: ["id":user["id"]!.intValue,"first_name":user["first_name"]!.stringValue,"last_name":user["last_name"]!.stringValue,"length":user["length"]!.intValue,"email":user["email"]!.stringValue,"sex": sex, "weight":(user["weight"]?.floatValue)!, "birthday":birthday])
                        userprofile.add({ (id, completion) in
                        })
                        self.dismiss(animated: true, completion: nil)
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
                        default:
                            message = NSLocalizedString("signup_failed", comment: "")
                        }
                    }
                    
                }else{
                    if message.isEmpty {
                        message = NSLocalizedString("no_network", comment: "")
                    } else {
                        switch status {
                        case -1:
                            message = NSLocalizedString("access_denied", comment: "");
                        case -2:
                            message = "";
                        case -3:
                            message = NSLocalizedString("user_exist", comment: "");
                        default:
                            message = NSLocalizedString("signup_failed", comment: "")
                        }
                    }
                    
                }
                
                let banner = MEDBanner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
            }
        }else{
            XCGLogger.default.debug("注册的时候没有网络")
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
    }
}

// MARK: - PICKERVIEW
extension InformationController:UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            if pickerView == heightTextField.inputView {
                return 251
            } else {
                return 121
            }
            
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            if pickerView == heightTextField.inputView {
                return "CM"
            } else {
                return "KG"
            }
        } else {
            if pickerView == heightTextField.inputView {
                return "\(row + 50)"
            } else {
                return "\(row + 30)"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == heightTextField.inputView {
            heightTextField.text = "\(row + 50)  CM"
        } else {
            weightTextfield.text = "\(row + 30)  KG"
        }
    }
}


extension InformationController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil {
            return;
        }
        if textField.isEqual(heightTextField) {
            if let height = textField.text?.toInt() {
                if height > 300 {
                    textField.text = "300  CM"
                } else if height < 50 {
                    textField.text = "50  CM"
                }
            }
        }
        
        if textField.isEqual(weightTextfield) {
            if let weight = textField.text?.toInt() {
                if weight > 150 {
                    textField.text = "150  KG"
                } else if weight < 30 {
                    textField.text = "30  KG"
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
}
