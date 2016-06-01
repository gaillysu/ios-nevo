//
//  ChangeProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/4/6.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField

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
        
        if changeField == "lenght"{
            weightArray = generatePickerData(100, rangeEnd: 220, interval: 0)
            textPostFix = " cm"
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            picker.backgroundColor = UIColor.whiteColor()
            changeTextfield.inputView = picker
        }
        
        if changeField == "age"{
            weightArray = generatePickerData(10, rangeEnd: 75, interval: 0)
            textPostFix = " age"
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
        //["first_name","last_name","weight","age","lenght"]
        if changeField == "first_name" && changeTextfield.text != nil{
            profile.first_name = changeTextfield.text!
        }
        
        if changeField == "last_name" && changeTextfield.text != nil{
            profile.last_name = changeTextfield.text!
        }
        
        if changeField == "weight" && changeTextfield.text != nil{
            profile.weight = Int(changeTextfield.text!)!
        }
        
        if changeField == "lenght" && changeTextfield.text != nil{
            profile.lenght = Int(changeTextfield.text!)!
        }
        
        if changeField == "age" && changeTextfield.text != nil{
            profile.age = Int(changeTextfield.text!)!
        }
        profile.update()
        self.navigationController?.popViewControllerAnimated(true)
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
}
