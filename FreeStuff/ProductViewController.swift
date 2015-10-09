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

class ProductViewController: PFQueryTableViewController, UISearchBarDelegate {
    
    var userLocation: PFGeoPoint?
    var searchDistance: Double!
    @IBOutlet weak var searchBar: UISearchBar!
    var tableViewHeight: CGFloat!
    
    //Setting this table up to be a Parse query table
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "Listing"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewHeight = tableView.contentSize.height
        
        //addButton for navigating to add screen
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "sellItem")
        let settingsButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "settings")
        
        //setting up the settings button with gear icon from unicode
        settingsButton.title = NSString(string: "\u{2699}") as String
        if let font = UIFont(name: "Helvetica", size: 24.0) {
            settingsButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        navigationItem.leftBarButtonItem = settingsButton
        
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //reset searchDistance from user defaults any time view appears, might have changed in other pages
        var settingsDict = NSUserDefaults.standardUserDefaults().objectForKey("standardSettings") as! [String: AnyObject]
        searchDistance = settingsDict["searchDistance"] as! Double
    }
    
    //MARK: TableView methods
    override func queryForTable() -> PFQuery {
        let query:PFQuery = PFQuery(className:self.parseClassName!)
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            self.userLocation = geoPoint
        }
        
        if userLocation != nil {
            query.whereKey("location", nearGeoPoint: self.userLocation!, withinMiles: searchDistance)
        }
        
        if searchBar.text != "" {
            query.whereKey("searchText", containsString: searchBar.text!.lowercaseString)
        }
        
        //MARK: Think about caching later
//        if(objects?.count == 0)
//        {
//            query.cachePolicy = PFCachePolicy.CacheThenNetwork
//        }
        
//        query.orderByAscending("title")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("listingCell") as? ListingViewCell
        if(cell == nil) {
            cell = ListingViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "listingCell")
        }
        
        //setting the placeholder image
        cell?.listingImage.image = UIImage(named: "placeholder")
        
        //getting the title and images
        if let currentListing = object as? Listing {
            cell?.title.text = currentListing.title
            cell?.title.adjustsFontSizeToFitWidth = true
            if currentListing.images.count != 0 {
                cell?.listingImage.file = currentListing.images[0]
                cell?.listingImage.loadInBackground()
            }
        }
        

        
        return cell;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //implementing a relative function to get cell height, to adjust for different phones 
        return tableViewHeight/10
    }
    
    //show details of the listing
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = objectAtIndexPath(indexPath) as! Listing
        details(object)
    }
    
    
    //MARK: Seguing methods
    //function used to present addVC
    func sellItem() {
        //instantiate add viewcontroller
        let addVC = storyboard?.instantiateViewControllerWithIdentifier("AddItemVC") as! AddItemVC
        //embed in nav controller
        let navController = UINavigationController(rootViewController: addVC)
        //present modally
        presentViewController(navController, animated: true, completion: nil)
    }
    
    //present settings VC
    func settings () {
        let settingsVC = storyboard?.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsVC
        settingsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    //present the details VC and pass the current object from the cell row
    func details (currentObject: Listing) {
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as! DetailVC
        detailVC.currentListing = currentObject
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    //MARK: SearchBar methods
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        loadObjects()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        loadObjects()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        // Clear any search criteria
        searchBar.text = ""
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        loadObjects()
    }
}

