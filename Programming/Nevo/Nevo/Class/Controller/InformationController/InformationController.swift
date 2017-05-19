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

class InformationController: UIViewController {

    static let MED_kISFromRegisterController: String = "MED_kISFromRegisterController"
    
    @IBOutlet weak var metricsSegment: UIView!
    @IBOutlet weak var dateOfbirth: AutocompleteField!
    @IBOutlet weak var heightTextField: AutocompleteField!
    @IBOutlet weak var weightTextfield: AutocompleteField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailLabel2: UILabel!
    
    @IBOutlet weak var policyLabel: UILabel!
    
    var segmentView:SMSegmentView?
    var registerInfo:[String:String] = [:]
    
    init() {
        super.init(nibName: "InformationController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("sign_up", comment: "")
        
        
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
    }
    
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        if segmentView == nil {
            let appearance = SMSegmentAppearance()
            appearance.titleOnSelectionColour       = UIColor.white
            appearance.titleOffSelectionColour      = UIColor.getBaseColor()
            appearance.segmentOnSelectionColour     = UIColor.getBaseColor()
            appearance.segmentOffSelectionColour    = UIColor.getGreyColor()
            appearance.titleOnSelectionFont         = UIFont.systemFont(ofSize: 12.0)
            appearance.titleOffSelectionFont        = UIFont.systemFont(ofSize: 12.0)
            appearance.contentVerticalMargin        = 10.0
            
            /*
             Init SMsegmentView
             Set divider colour and width here if there is a need
             */
            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, dividerColour: UIColor(white: 0.95, alpha: 0.3), dividerWidth: 1.0, segmentAppearance: appearance)
            segmentView!.layer.borderColor  = AppTheme.NEVO_SOLAR_YELLOW().cgColor
            segmentView!.layer.borderWidth  = 1.0
            segmentView?.layer.cornerRadius = 10
            
            segmentView!.addSegmentWithTitle(NSLocalizedString("Male", comment: ""), onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle(NSLocalizedString("Female", comment: ""), onSelectionImage: nil, offSelectionImage: nil)
            segmentView?.selectedSegmentIndex = 0
            metricsSegment.addSubview(segmentView!)
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
        if MEDNetworkManager.manager.networkState {
            if(AppTheme.isNull(dateOfbirth!.text!) || AppTheme.isNull(heightTextField.text!) || AppTheme.isNull(weightTextfield.text!)) {
                let banner = MEDBanner(title: NSLocalizedString("one_of_the_fields_are_empty", comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 0.6)
                return
            }
            
            let sex:Int = self.segmentView?.selectedSegmentIndex == 0 ? 1 : 0
            registerInfo["birthday"] = dateOfbirth!.text!
            
            // 字典中的数据格式原来是没有单位的数字
            registerInfo["length"] = "\(heightTextField!.text!.toInt())"
            registerInfo["weight"] = "\(weightTextfield!.text!.toInt())"
            
            registerInfo["sex"] = "\(sex)"
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(AppTheme.NEVO_SOLAR_YELLOW())
            
            //timeout
            let timeout:Timer = Timer.after(50.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
            
//            // let infoDict:[String:String] = ["email":email!.text!,"first_name":firstNameTextField!.text!,"last_name":lastNameTextField!.text!,"password":password.text!]
            MEDUserNetworkManager.createUser(firstName: registerInfo["first_name"]!, lastName: registerInfo["last_name"]!, email: registerInfo["email"]!, password: registerInfo["password"]!, birthday: registerInfo["birthday"]!, length: registerInfo["length"]!, weight: registerInfo["weight"]!, sex: sex, completion: { (status) in
                
                timeout.invalidate()
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                
                var message: String = ""
                switch status {
                case .SUCCESS:
                    message = NSLocalizedString("register_success", comment: "")
                    // 如果要加密，可以把加密后的密码存在 userDefault 里
                    // please don't care about the security. if necessary, we can encrypt the password before save
                    UserDefaults.standard.set(["email" : "\(self.registerInfo["email"]!)", "password" : "\(self.registerInfo["password"]!)"], forKey: InformationController.MED_kISFromRegisterController)
                    self.dismiss(animated: true, completion: nil)
                case .USER_EXIST:
                    message = NSLocalizedString("user_exist", comment: "")
                case .SIGNUP_FAILED:
                    message = NSLocalizedString("signup_failed", comment: "")
                }
                
                let banner = MEDBanner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:AppTheme.NEVO_SOLAR_YELLOW())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
            })
            
            
            /// 🚧🚧🚧
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
