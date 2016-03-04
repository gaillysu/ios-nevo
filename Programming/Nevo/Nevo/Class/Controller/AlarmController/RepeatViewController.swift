//
//  RepeatViewController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/3.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

protocol SelectedRepeatDelegate {

    func onSelectedRepeatAction(value:Int,name:String)
    
}

class RepeatViewController: UIViewController {

    let RepeatDayArray:[String] = ["Disable","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    private var selectedIndex:Int = 0
    var selectedDelegate:SelectedRepeatDelegate?

    init() {
        super.init(nibName: "RepeatViewController", bundle: NSBundle.mainBundle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Repeat"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedDelegate?.onSelectedRepeatAction(indexPath.row, name: RepeatDayArray[indexPath.row])

        selectedIndex = indexPath.row
        for cell in tableView.visibleCells {
            let view = cell.contentView.viewWithTag(1500)
            if(view != nil){
                view?.removeFromSuperview()
            }
        }

        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let view = cell?.contentView.viewWithTag(1500)
        if(view == nil){
            let selectedImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, 25, 25))
            selectedImage.image = UIImage(named: "notifications_selected_background")
            selectedImage.tag = 1500
            cell?.contentView.addSubview(selectedImage)
            selectedImage.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-(selectedImage.frame.size.width/2.0 + 10),cell!.contentView.frame.size.height/2.0)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RepeatDayArray.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("LabelCell")
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "LabelCell")
        }
        cell!.textLabel?.text = NSLocalizedString("\(RepeatDayArray[indexPath.row])", comment: "")

        if(indexPath.row == selectedIndex) {
            let view = cell?.contentView.viewWithTag(1500)
            if(view == nil){
                let selectedImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, 25, 25))
                selectedImage.image = UIImage(named: "notifications_selected_background")
                selectedImage.tag = 1500
                cell?.contentView.addSubview(selectedImage)
                selectedImage.center = CGPointMake(UIScreen.mainScreen().bounds.size.width-(selectedImage.frame.size.width/2.0 + 10), cell!.contentView.frame.size.height/2.0)
            }else{
                (view as! UIImageView).image = UIImage(named: "notifications_selected_background")
            }
        }
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
