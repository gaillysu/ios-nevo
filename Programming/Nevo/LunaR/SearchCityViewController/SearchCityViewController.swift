//
//  ChooseCityController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/27.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class SearchCityViewController: UITableViewController {
    var mDelegate:WorldClockDidSelectedDelegate?
    fileprivate var searchList:[String:[(name:String, id:Int)]] = [:]
    fileprivate var index:[String] = []
    init() {
        super.init(nibName: "SearchCityViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchList = [:]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setSearchList(_ searchList:[String:[(name:String, id:Int)]]){
        self.searchList = searchList
        self.index = Array(searchList.keys)
        self.index = index.sorted(by: { (s1:String, s2:String) -> Bool in
            return s1 < s2
        })
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        if searchList.count == 0{
            return
        }
        if let cities:[(name:String, id:Int)] = searchList[index[(indexPath as NSIndexPath).section]]{
            mDelegate?.didSelectedLocalTimeZone(cities[(indexPath as NSIndexPath).row].id)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return index.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList[index[section]]!.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AddClockIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "AddClockIdentifier")
        }
        if let cities:[(name:String, id:Int)] = searchList[index[(indexPath as NSIndexPath).section]]{
            cell?.textLabel?.text = cities[(indexPath as NSIndexPath).row].name
        }
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cell?.textLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor.getGreyColor()
        
        return cell!
    }
}
