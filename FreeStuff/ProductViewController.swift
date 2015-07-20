//
//  FirstViewController.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProductViewController: PFQueryTableViewController {
    
    //Setting this table up to be a Parse query table
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "Listing"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addButton for navigating to add screen
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "sellItem")
        //add the Button to the navBar
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func queryForTable() -> PFQuery {
        var query:PFQuery = PFQuery(className:self.parseClassName!)
        //MARK: Think about caching later
//        if(objects?.count == 0)
//        {
//            query.cachePolicy = PFCachePolicy.CacheThenNetwork
//        }
        
        query.orderByAscending("title")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        let cellIdentifier:String = "listingCell"
        var cell:PFTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? PFTableViewCell
        if(cell == nil) {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        if let pfObject = object {
            cell?.textLabel?.text = pfObject["title"] as? String
        }
        return cell;
    }

    
    //function used to present addVC
    func sellItem() {
        //instantiate add viewcontroller
        let addVC = storyboard?.instantiateViewControllerWithIdentifier("AddItemVC") as! AddItemVC
        //embed in nav controller
        let navController = UINavigationController(rootViewController: addVC)
        //present modally
        presentViewController(navController, animated: true, completion: nil)
    }
}

