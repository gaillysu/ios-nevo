//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockController: UIViewController, ConnectionControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        ConnectionControllerImpl.sharedInstance.setDelegate(self)
        
        checkConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /**
    
    See ConnectionControllerDelegate
    
    */
    
    func packetReceived(RawPacket) {
        
        //Do nothing
        
    }
    
    
    
    /**
    
    See ConnectionControllerDelegate
    
    */
    
    func connectionStateChanged(isConnected : Bool) {
        
        //Maybe we just got disconnected, let's check
        
        checkConnection()
        
    }
    
    
    
    /**
    
    Checks if any device is currently connected
    
    */
    
    func checkConnection() {
        
        
        
        if !ConnectionControllerImpl.sharedInstance.isConnected() {
            
            //We are currently not connected
            
            
            
            //TODO by Cloud Display the not connected screen instead of this popup
            
            var alert:UIAlertView = UIAlertView(title:"Alert", message:"This is an example alert!", delegate:self, cancelButtonTitle:"Hide")
            
            
            
            alert.show();
            
        } else {
            //TODO by Cloud dismiss the popup
        }
        
        
    }

}
