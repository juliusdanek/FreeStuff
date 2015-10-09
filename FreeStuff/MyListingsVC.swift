//
//  SecondViewController.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MyListingsVC: PFQueryTableViewController {
    
    @IBOutlet weak var segControl: UISegmentedControl!
    
    var tableViewHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewHeight = tableView.frame.height
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func queryForTable() -> PFQuery {
        if let user = PFUser.currentUser() {
            //depending on which index is selected on segmented control, return the related query
            if segControl.selectedSegmentIndex == 0 {
                return returnQuery("favoritedListings", userForRelation: user)
            } else if segControl.selectedSegmentIndex == 1 {
                return returnQuery("claimedListings", userForRelation: user)
            } else {
                return returnQuery("postedListings", userForRelation: user)
            }
        } else {
            return PFQuery()
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        if objects?.count == 0 {
            return PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("listingCell") as? ListingViewCell
            if let currentListing = object as? Listing {
                cell?.title.text = currentListing.title
                cell?.title.adjustsFontSizeToFitWidth = true
                if currentListing.images.count != 0 {
                    cell?.listingImage.file = currentListing.images[0]
                    cell?.listingImage.loadInBackground()
                }
            }
            return cell
        }
    }
    
    //show details of the listing
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = objectAtIndexPath(indexPath) as! Listing
        details(object)
    }
    
    func details (currentObject: Listing) {
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as! DetailVC
        detailVC.currentListing = currentObject
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func changeQuery(sender: UISegmentedControl) {
        //only used to clear objects and reload the table
        clear()
        loadObjects()
    }
    
    //encapsulating the relationship and return process
    func returnQuery (relation: String, userForRelation: PFUser) -> PFQuery {
        let relation = userForRelation.relationForKey(relation)
        return relation.query()!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //implementing a relative function to get cell height, to adjust for different phones
        return tableViewHeight/9
    }
    
    
}

