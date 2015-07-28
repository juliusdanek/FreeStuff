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
//    @IBOutlet weak var claimButton: UIButton!
//    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentListing: Listing?
    
    var imageArray: [PFFile] = []
    var imageViewArray: [PFImageView?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        scrollView.delegate = self
        
        if let listing = currentListing {
            if listing.images.count != 0 {
                imageArray = listing.images
            }
            listingTitle.text = listing.title

            listingDescription.text = listing.listingDescription
            
            if let geopoint = listing["location"] as? PFGeoPoint {
                PFGeoPoint.geoPointForCurrentLocationInBackground({ (currentGeoPoint, error) -> Void in
                    println(currentGeoPoint!)
                    println(currentGeoPoint!.distanceInMilesTo(geopoint))
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
            let newPageView = PFImageView(image: UIImage(named: "placeholder"))
            newPageView.file = imageArray[page]
            newPageView.loadInBackground()
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