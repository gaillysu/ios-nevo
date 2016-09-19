//
//  PresetTableViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol AddPresetDelegate {
    func onAddPresetNumber(_ number:Int,name:String)

}

class PresetTableViewController: UITableViewController,ButtonManagerCallBack,AddPresetDelegate {
        
    @IBOutlet weak var presetView: PresetView!
    var prestArray:[Presets] = []

    init() {
        super.init(nibName: "PresetTableViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presetView.backgroundColor = UIColor.white
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
    func onAddPresetNumber(_ number:Int,name:String){
        NSLog("onAddPresetNumber:\(number),name:\(name)")
        let prestModel:Presets = Presets(keyDict: ["id":0,"steps":number,"label":"\(name)","status":true])
        prestModel.add { (id, completion) -> Void in
            prestModel.id = id!
            self.prestArray.append(prestModel)
            self.tableView.reloadData()
        }
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(_ sender:AnyObject){
        if(sender.isEqual(presetView.leftButton)){
            //let removeAll:Bool = Presets.removeAll()
            let addPreset:AddPresetViewController = AddPresetViewController()
            addPreset.addDelegate = self
            self.navigationController?.pushViewController(addPreset, animated: true)
        }

        if(sender.isKind(of: UISwitch.classForCoder())){
            let switchSender:UISwitch = sender as! UISwitch
            let preModel:Presets = prestArray[switchSender.tag]
            preModel.status = switchSender.isOn
            _ = preModel.update()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prestArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return presetView.getPresetTableViewCell(indexPath, tableView: tableView,presetArray: prestArray, delegate: self)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        button1.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
        return [button1]
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let preModel:Presets = prestArray[(indexPath as NSIndexPath).row]
            _ = preModel.remove()
            prestArray.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {

        }    
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
