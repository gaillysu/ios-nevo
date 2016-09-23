//
//  RepeatViewController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/3.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

protocol SelectedRepeatDelegate {

    func onSelectedRepeatAction(_ value:Int,name:String)
    
}

class RepeatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let RepeatDayArray:[String] = [
        NSLocalizedString("Disable", comment: ""),
        NSLocalizedString("Sunday", comment: ""),
        NSLocalizedString("Monday", comment: ""),
        NSLocalizedString("Tuesday", comment: ""),
        NSLocalizedString("Wednesday", comment: ""),
        NSLocalizedString("Thursday", comment: ""),
        NSLocalizedString("Friday", comment: ""),
        NSLocalizedString("Saturday", comment: "")]
    var selectedIndex:Int = 0
    var selectedDelegate:SelectedRepeatDelegate?

    init() {
        super.init(nibName: "RepeatViewController", bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Repeat", comment: "")
        self.view.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.getLightBaseColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "RepeatViewCell",bundle: nil), forCellReuseIdentifier: "RepeatView_Identifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        selectedDelegate?.onSelectedRepeatAction((indexPath as NSIndexPath).row, name: RepeatDayArray[(indexPath as NSIndexPath).row])

        selectedIndex = (indexPath as NSIndexPath).row
        for cell in tableView.visibleCells {
            cell.accessoryView = nil
        }

        let cell = tableView.cellForRow(at: indexPath)
        if(view == nil){
            let selectedImage:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            selectedImage.image = UIImage(named: "notifications_check")
            cell?.accessoryView = selectedImage
        }
        self.navigationController!.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepeatDayArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell:RepeatViewCell = tableView.dequeueReusableCell(withIdentifier: "RepeatView_Identifier",for: indexPath) as! RepeatViewCell
        let selectedView:UIView = UIView()
        selectedView.backgroundColor = AppTheme.NEVO_SOLAR_GRAY()
        cell.selectedBackgroundView = selectedView
        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = NSLocalizedString("\(RepeatDayArray[(indexPath as NSIndexPath).row])", comment: "")
        cell.preservesSuperviewLayoutMargins = false;
        cell.separatorInset = UIEdgeInsets.zero;
        cell.layoutMargins = UIEdgeInsets.zero;
        
        if((indexPath as NSIndexPath).row == selectedIndex) {
            let selectedImage:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 23))
            selectedImage.contentMode = UIViewContentMode.scaleAspectFit
            selectedImage.image = UIImage(named: "notifications_check")
            selectedImage.tag = 1500
            cell.accessoryView = selectedImage
        }
        return cell
    }

}
