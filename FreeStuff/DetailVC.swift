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
//    @IBOutlet weak var listingTitle: UILabel!
//    @IBOutlet weak var listingDescription: UITextView!
//    @IBOutlet weak var claimButton: UIButton!
//    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentListing: PFObject?
    
    var imageArray: [UIImage] = []
    var imageViewArray: [UIImageView?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        println(scrollView.contentSize)
        println(scrollView.frame)
        println(scrollView.bounds)
        
        let makeFrame 
        
        println(view.bounds)
        println(view.frame)
        println(super.view.frame)
        
        println(self.navigationController?.navigationBar.frame)

        
        imageArray = [UIImage(named: "placeholder")!,
            UIImage(named: "placeholder")!,
            UIImage(named: "placeholder")!]
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = imageArray.count
                
        for _ in 0..<imageArray.count {
            imageViewArray.append(nil)
        }
        
        // 4
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(imageArray.count),
            height: pagesScrollViewSize.height)
        
        // 5
        loadVisiblePages()
        
//        if let listing = currentListing {
//            listingTitle.text = listing["title"] as? String
//            
//            listingDescription.text = listing["description"] as? String
//        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
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
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            let newPageView = UIImageView(image: imageArray[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            // 4
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
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
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