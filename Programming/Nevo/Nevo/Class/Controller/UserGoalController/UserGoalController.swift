//
//  PresetTableViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class UserGoalController: UITableViewController {
    
    var presetArray:[MEDUserGoal] = []
    
    init() {
        super.init(nibName: "UserGoalController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "GoalTableViewCell", bundle: nil), forCellReuseIdentifier: "UserGoal_Identifier")
        navigationItem.title = NSLocalizedString("title_goal", comment: "")
        let leftButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(rightButtonItemAction(_:)))
        navigationItem.rightBarButtonItem = leftButton
        
        
        let array = MEDUserGoal.getAll()
        for pArray in array {
            presetArray.append(pArray as! MEDUserGoal)
        }
        
        tableView.separatorColor = UIColor.lightGray
        tableView.viewDefaultColorful()
        tableView.separatorInset = .zero
    }
}

extension UserGoalController {
    func rightButtonItemAction(_ sender:AnyObject){
        let alertController = createAlertControllerForPreset(title: NSLocalizedString("add_goal", comment: ""), goal: nil)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { alertAction in
            var name = "\(NSLocalizedString("title_goal", comment: "")) \(self.presetArray.count + 1)"
            var number = 7000
            if let newName = alertController.textFields?[0].text {
                if newName.length() > 0{
                    name = newName
                }
            }
            if let newGoal = alertController.textFields?[1].text {
                if newGoal.length() > 0{
                    number = Int(newGoal)!
                }
            }
            
            let presetModel:MEDUserGoal = MEDUserGoal()
            presetModel.stepsGoal = number
            presetModel.label = "\(name)"
            presetModel.status = true
            _ = presetModel.add()
            self.presetArray.append(presetModel)
            self.tableView.insertRows(at: [IndexPath(row: self.presetArray.count - 1 , section: 0)], with: UITableViewRowAnimation.automatic)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.actions.forEach { action in
            action.setValue(UIColor.baseColor, forKey: "titleTextColor")
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func createAlertControllerForPreset(title:String, goal:MEDUserGoal?) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textfield in
            textfield.placeholder = NSLocalizedString("goal_name", comment: "")
            if let goal = goal{
                textfield.text = goal.label
            }
        })
        alertController.addTextField(configurationHandler: { textfield in
            textfield.keyboardType = UIKeyboardType.numberPad
            textfield.placeholder = NSLocalizedString("goal", comment: "")
            if let goal = goal{
                textfield.text = "\(goal.stepsGoal)"
            }
        })
        return alertController
    }
}

// MARK: - TableView Datasource
extension UserGoalController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GoalTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserGoal_Identifier", for: indexPath) as! GoalTableViewCell
        cell.presetModel = presetArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        cell.viewDefaultColorful()
        return cell
    }
}

// MARK: - TableView Delegate
extension UserGoalController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        deleteButton.backgroundColor = UIColor.baseColor
        return [deleteButton]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let preModel:MEDUserGoal = presetArray[indexPath.row]
            _ = preModel.remove()
            presetArray.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal:MEDUserGoal = presetArray[indexPath.row]
        let alertController = createAlertControllerForPreset(title: NSLocalizedString("Edit goal", comment: ""), goal: goal)
        alertController.addAction(UIAlertAction(title: "Edit", style: .default, handler: { alertAction in
            let realm = try! Realm()
            try! realm.write {
                if let newName = alertController.textFields?[0].text {
                    if newName.length() > 0{
                        goal.label = newName
                    }
                }
                if let newGoal = alertController.textFields?[1].text {
                    if newGoal.length() > 0{
                        
                        goal.stepsGoal = Int(newGoal)!
                    }
                }
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alertController.actions.forEach { action in
            action.setValue(UIColor.baseColor, forKey: "titleTextColor")
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
