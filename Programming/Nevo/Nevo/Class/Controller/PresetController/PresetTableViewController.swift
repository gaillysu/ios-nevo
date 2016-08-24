//
//  PresetTableViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol AddPresetDelegate {
    func onAddPresetNumber(number:Int,name:String)

}

class PresetTableViewController: UITableViewController,ButtonManagerCallBack,AddPresetDelegate {
        
    @IBOutlet weak var presetView: PresetView!
    var prestArray:[Presets] = []

    init() {
        super.init(nibName: "PresetTableViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presetView.backgroundColor = UIColor.whiteColor()
        presetView.bulidPresetView(self.navigationItem,delegateB: self)

        let array:NSArray = Presets.getAll()
        for pArray in array {
            prestArray.append(pArray as! Presets)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - AddPresetDelegate
    func onAddPresetNumber(number:Int,name:String){
        NSLog("onAddPresetNumber:\(number),name:\(name)")
        let prestModel:Presets = Presets(keyDict: ["id":0,"steps":number,"label":"\(name)","status":true])
        prestModel.add { (id, completion) -> Void in
            prestModel.id = id!
            self.prestArray.append(prestModel)
            self.tableView.reloadData()
        }
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if(sender.isEqual(presetView.leftButton)){
            //let removeAll:Bool = Presets.removeAll()
            let addPreset:AddPresetViewController = AddPresetViewController()
            addPreset.addDelegate = self
            self.navigationController?.pushViewController(addPreset, animated: true)
        }

        if(sender.isKindOfClass(UISwitch.classForCoder())){
            let switchSender:UISwitch = sender as! UISwitch
            let preModel:Presets = prestArray[switchSender.tag]
            preModel.status = switchSender.on
            _ = preModel.update()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prestArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        return presetView.getPresetTableViewCell(indexPath, tableView: tableView,presetArray: prestArray, delegate: self)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        })
        button1.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
        return [button1]
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let preModel:Presets = prestArray[indexPath.row]
            _ = preModel.remove()
            prestArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {

        }    
    }
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}
