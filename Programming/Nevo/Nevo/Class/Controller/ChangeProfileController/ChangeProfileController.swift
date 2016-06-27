//
//  ChangeProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/4/6.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import MRProgress
import SwiftyTimer
import SwiftyJSON
import XCGLogger
import BRYXBanner

class ChangeProfileController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var changeTextfield: AutocompleteField!
    var changeName:String = ""
    var changeField:String = ""
    private var weightArray:NSMutableArray = NSMutableArray()
    private var textPostFix:String = ""
    
    init() {
        super.init(nibName: "ChangeProfileController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.8, alpha: 1)
        self.navigationItem.title = "Change "+changeName
        changeTextfield.placeholder = "Change "+changeName
        changeTextfield.backgroundColor = UIColor.whiteColor()
        let save:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveChangeAction(_:)))
        self.navigationItem.rightBarButtonItem = save
    }
    
    override func viewDidLayoutSubviews() {
        if changeField == "first_name"{
            
        }
        
        if changeField == "last_name"{
            
        }
        
        if changeField == "weight"{
            weightArray = generatePickerData(35, rangeEnd: 150, interval: 0)
            textPostFix = " KG"
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            picker.backgroundColor = UIColor.whiteColor()
            changeTextfield.inputView = picker
        }
        
        if changeField == "length"{
            weightArray = generatePickerData(100, rangeEnd: 220, interval: 0)
            textPostFix = " cm"
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            picker.backgroundColor = UIColor.whiteColor()
            changeTextfield.inputView = picker
        }
        
    }
    
    func saveChangeAction(sender:AnyObject) {
        let userArray:NSArray = UserProfile.getAll()
        let profile:UserProfile = userArray.objectAtIndex(0) as! UserProfile
        if changeField == "first_name" && changeTextfield.text != nil{
            profile.first_name = changeTextfield.text!
        }
        
        if changeField == "last_name" && changeTextfield.text != nil{
            profile.last_name = changeTextfield.text!
        }
        
        if changeField == "weight" && changeTextfield.text != nil{
            profile.weight = Int(changeTextfield.text!)!
        }
        
        if changeField == "length" && changeTextfield.text != nil{
            profile.length = Int(changeTextfield.text!)!
        }
        
        profile.update()
        self.updateUserProfile(profile) { (result) in
            if result {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {

    }
    
    private func generatePickerData(rangeBegin: Int,rangeEnd: Int, interval: Int)->NSMutableArray{
        let data:NSMutableArray = NSMutableArray();
        for i in rangeBegin...rangeEnd{
            if(interval > 0){
                if i % interval == 0 {
                    data.addObject("\(i)")
                }
            }else{
                data.addObject("\(i)")
            }
        }
        return data;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weightArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(weightArray[row])"+textPostFix
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeTextfield.text = "\(weightArray[row])"
    }
    
    
    func updateUserProfile(profile:UserProfile, completion:(result:Bool) -> Void){
        if AppDelegate.getAppDelegate().network!.isReachable {
            if !AppDelegate.getAppDelegate().isConnected() {
                let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.Cross, animated: true)
                view.setTintColor(UIColor.getBaseColor())
                NSTimer.after(0.6.second) {
                    view.dismiss(true)
                }
                return
            }
            
            
            var loadingIndicator:MRProgressOverlayView = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            loadingIndicator.setTintColor(UIColor.getBaseColor())
            
            HttpPostRequest.putRequest("http://nevo.karljohnchow.com/user/update", data: ["user":["id":profile.id, "first_name":profile.first_name,"last_name":profile.last_name,"email":profile.email,"length":profile.length,"birthday":profile.birthday]]) { (result) in
                let json = JSON(result)
                let message = json["message"].stringValue
                let status = json["status"].intValue
                let user:[String : JSON] = json["user"].dictionaryValue
                if(status > 0 && user.count > 0) {
                    completion(result: true)
                    loadingIndicator.dismiss(true, completion: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }else{
                    completion(result: false)
                    XCGLogger.defaultInstance().debug("Request error");
                    loadingIndicator.dismiss(true)
                    let banner:Banner = Banner(title: NSLocalizedString("not_update", comment: ""), subtitle: "", image: nil, backgroundColor: UIColor.getBaseColor(), didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3)
                }
            }
        }else{
            completion(result: false)
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.Cross, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            let timeout:NSTimer = NSTimer.after(0.6.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
        }
    }
}
