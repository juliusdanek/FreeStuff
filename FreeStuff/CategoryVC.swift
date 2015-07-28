//
//  CategoryVC.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/21/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import Foundation
import UIKit

//Setting up protocol to send data back to addItemVC
protocol CategoryVCDelegate {
    func sendCat(cat : String)
}

class CategoryVC: UITableViewController {
    
    //tracking what cell is selected
    var previousIndexPath: NSIndexPath?
    var delegate: CategoryVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting up NavBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.title = "Choose Category"
    }
    
    //set up tableview
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Categories.categoryArray.count
    }
    
    //Populating table and making sure that only one cell is selected with a checkmark
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = Categories.categoryArray[indexPath.row]
        
        if indexPath == previousIndexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //making a nice deselection animation
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //delete checkmark if previously given
        if previousIndexPath != nil {
            let oldCell = tableView.cellForRowAtIndexPath(previousIndexPath!)
            oldCell?.accessoryType = .None
        }
        //assign checkmark to the selected cell
        let newCell = tableView.cellForRowAtIndexPath(indexPath)
        newCell?.accessoryType = .Checkmark
        //change the indexPath variable
        previousIndexPath = indexPath
        //enable the "done" button
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    //dismiss the viewcontroller and go back to root
    func dismiss () {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func done() {
        let cell = tableView.cellForRowAtIndexPath(previousIndexPath!)
        let text = cell?.textLabel?.text
        //implementing the delegate method
        delegate?.sendCat(text!)
        dismissViewControllerAnimated(true, completion: nil)
    }
}