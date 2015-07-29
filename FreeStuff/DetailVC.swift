//
//  DetailVC.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/22/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class DetailVC: UIViewController, UIScrollViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var listingTitle: UILabel!
    @IBOutlet weak var listingDescription: UITextView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var distanceButton: UIBarButtonItem!
    
    var currentListing: Listing?
    
    var imageArray: [PFFile] = []
    var imageViewArray: [PFImageView?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        scrollView.delegate = self
        
        //checking whether a listing has been passed, then configuring the view
        if let listing = currentListing {
            
            //if it isn't published, show the publishing button
            if listing.published == false {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: .Plain, target: self, action: "publish")
            }
            
            if listing.images.count != 0 {
                imageArray = listing.images
            }
            listingTitle.text = listing.title

            listingDescription.text = listing.listingDescription
            
            //configuring the distance button with the map
            if let geopoint = listing["location"] as? PFGeoPoint {
                PFGeoPoint.geoPointForCurrentLocationInBackground({ (currentGeoPoint, error) -> Void in
                    let distance = Int(currentGeoPoint!.distanceInMilesTo(geopoint))
                    if distance == 0 {
                        self.distanceButton.title = NSString(string: " 🚗 <1") as String
                    } else if distance > 100 {
                        self.distanceButton.title = " 🚗 >100"
                    } else {
                        self.distanceButton.title = "\(distance)"
                    }
                })
            }
        }
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = imageArray.count
                
        for _ in 0..<imageArray.count {
            imageViewArray.append(nil)
        }


    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //this is called after the autolayout has been enacted and the pages views adjusted
                
        //the content size needs to be adjusted for the number of pages
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(imageArray.count),
            height: pagesScrollViewSize.height)

        
        //load pages needs to happen here, after layout already adjusted the subviews
        loadVisiblePages()
    }
    
    func publish () {
        currentListing?.published = true
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        view.addSubview(activityView)
        currentListing?.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                activityView.removeFromSuperview()
                activityView.stopAnimating()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    //From: http://www.raywenderlich.com/76436/use-uiscrollview-scroll-zoom-content-swift
    func loadPage(page: Int) {
        if page < 0 || page >= imageArray.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = imageViewArray[page] {
            return
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0
            
            //set up a new PFImageView that allows the display of a placeholder or the display of the image, if loaded
            let newPageView = PFImageView()
            let imageFile = imageArray[page]
            
            //if listing is published, i.e. comes from database, download files in background
            if currentListing!.published {
                newPageView.image = UIImage(named: "placeholder")
                newPageView.file = imageFile
                newPageView.loadInBackground()
            // if it is not, we need to extract the previously packaged image files again
            } else {
                //extracting image from file
                imageFile.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                    if error == nil {
                        let image = UIImage(data: imageData!)
                        //updating UI on main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            newPageView.image = image
                        })
                    }
                })
            }
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            //updated the imageViewArray
            imageViewArray[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= imageArray.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = imageViewArray[page] {
            pageView.removeFromSuperview()
            imageViewArray[page] = nil
        }
    }
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(scrollView.contentOffset.x / pageWidth)
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < imageArray.count; ++index {
            purgePage(index)
        }
    }



}