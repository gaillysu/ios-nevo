//
//  SunriseSetBgView.swift
//  Nevo
//
//  Created by Quentin on 25/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit


/// see the document commn
class SunriseSetView:UIView {
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dialView: UIView!
    @IBOutlet weak var dialImageView: UIImageView!
    @IBOutlet weak var worldClocksTableView: UITableView!
    
    var worldClocks:[WorldClockItem] = [] {
        willSet {
        }
        didSet {
            worldClocksTableView.reloadData()
        }
    }
    
    let WorldClockCellReuseID = "WorldClockCellReuseID"
    let dialViewHeight:CGFloat = 250
    
    weak var clockView:ClockView? = nil
    
    override func layoutSubviews() {
        self.backgroundColor =  UIColor.getGreyColor()
        clockView?.frame = dialImageView.frame
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addClockView()
        
        worldClocksTableView.delegate = self
        worldClocksTableView.dataSource = self
        
        worldClocksTableView.backgroundColor = UIColor.getGreyColor()
        worldClocksTableView.isScrollEnabled = false
        worldClocksTableView.separatorStyle = .none
        
        worldClocksTableView.register(UINib(nibName: "WorldClockCell",bundle:nil), forCellReuseIdentifier: WorldClockCellReuseID)
    }
    
    public func setDialTime(dateComponents:DateComponents) {
        clockView?.setWorldTime(dateConponents: dateComponents)
    }
    
    public func setTime(weekday:String, date:String) {
        weekdayLabel.text = weekday
        dateLabel.text = date
    }
}

extension SunriseSetView:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:WorldClockCell = tableView.dequeueReusableCell(withIdentifier: WorldClockCellReuseID, for: indexPath) as! WorldClockCell
        cell.setTime(worldTime: "Shanghai 05:00", sunriseTime: "05:00 AM", sunsetTime: "05:00 PM")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension SunriseSetView {
    fileprivate func addClockView() {
        let hourImage = AppTheme.GET_RESOURCES_IMAGE("wacth_hour")
        let minuteImage = AppTheme.GET_RESOURCES_IMAGE("wacth_mint")
        let dialImage = AppTheme.GET_RESOURCES_IMAGE("lunar_dial_f")
        
        let clockViewHeight:CGFloat = dialViewHeight
        let clockViewX:CGFloat = (UIScreen.main.bounds.width - clockViewHeight) / 2
        let clockViewFrame:CGRect = CGRect(x: clockViewX, y: 0, width: clockViewHeight, height: clockViewHeight)
        
        let clockV:ClockView = ClockView(frame: clockViewFrame, hourImage: hourImage, minuteImage: minuteImage, dialImage: dialImage)
        
        dialView.addSubview(clockV)
        
        clockView = clockV
    }
}


