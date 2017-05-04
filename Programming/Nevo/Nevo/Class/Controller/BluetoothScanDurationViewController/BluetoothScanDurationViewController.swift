//
//  BluetoothDurationViewController.swift
//  Nevo
//
//  Created by Karl-John Chow on 4/5/2017.
//  Copyright © 2017 Nevo. All rights reserved.
//

import UIKit

class BluetoothScanDurationViewController: UIViewController {

    let identfier = "UITableViewCellStyle"
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identfier)
    }
}
extension BluetoothScanDurationViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identfier)
    }
}
