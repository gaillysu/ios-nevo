//
//  SelectFileController.swift
//  Nevo
//
//  Created by ideas on 15/3/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SelectFileController: UITableViewController {

    private var mFiles:[NSURL] = []
    private var mDirectoryPath:String = ""
    var mFileDelegate:PtlSelectFile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            mFiles.append(tmpfile as NSURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mFiles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FolderFilesCell" , forIndexPath: indexPath) as UITableViewCell
        var fileName = mFiles[indexPath.row].lastPathComponent
        //configure the cell
        cell.textLabel?.text = fileName

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var fileURL:NSURL = mFiles[indexPath.row]
        //set the select file to screen
        self.navigationController?.popViewControllerAnimated(true)
        mFileDelegate?.onFileSelected(fileURL)
        
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
