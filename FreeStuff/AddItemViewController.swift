//
//  addItem.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Parse

class AddItemVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, CategoryVCDelegate {
    
    @IBOutlet weak var imageGallery: UICollectionView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var categoryPicker: UIButton!
    
    var imageArray = [UIImage]()
    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    
    //initializing listing at the very beginning
    let listing = Listing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prepare navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
        navigationItem.title = "Add Listing"
        
        //configuring imageGallery
        imageGallery.delegate = self
        imageGallery.dataSource = self
        imagePicker.delegate = self
        imageGallery.layer.cornerRadius = 5
        imageGallery.layer.borderColor = UIColor.blackColor().CGColor
        imageGallery.layer.borderWidth = 1
        
        //configuring textview
        descriptionField.layer.cornerRadius = 5
        descriptionField.layer.borderColor = UIColor.blackColor().CGColor
        descriptionField.layer.borderWidth = 1
        
        titleField.layer.cornerRadius = 5
        titleField.layer.borderColor = UIColor.blackColor().CGColor
        titleField.layer.borderWidth = 1
        
        //previewButton
        previewButton.addTarget(self, action: "previewListing", forControlEvents: .TouchUpInside)
        
        addLocationButton.addTarget(self, action: "findLocation", forControlEvents: .TouchUpInside)
        
        categoryPicker.addTarget(self, action: "pickCategory", forControlEvents: .TouchUpInside)
        categoryPicker.layer.cornerRadius = 5
        categoryPicker.layer.borderColor = UIColor.blackColor().CGColor
        categoryPicker.layer.borderWidth = 1
    }
    
    //MARK: Work this over
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text != "" {
            textField.layer.borderColor = UIColor.greenColor().CGColor
        } else {
            textField.layer.borderColor = UIColor.blackColor().CGColor
        }
    }
    
    func previewListing () {
        let searchText = titleField.text.lowercaseString + " " + descriptionField.text.lowercaseString
        listing.title = titleField.text
        listing.user = PFUser.currentUser()!
        listing.searchText = searchText
        listing.listingDescription = descriptionField.text
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
            self.listing.location = geopoint!
        }
        listing.categories = [categoryPicker.titleLabel!.text!]
        listing.images = []
        if imageArray.count != 0 {
            for image in imageArray {
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                let imageFile = PFFile(data: imageData)
                listing.images.append(imageFile)
            }
        }
        listing.published = false
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as! DetailVC
        detailVC.currentListing = listing
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func pickCategory() {
        let categoryVC = storyboard?.instantiateViewControllerWithIdentifier("categoryVC") as! CategoryVC
        //embed in nav controller
        //set self as delegate
        categoryVC.delegate = self
        let navController = UINavigationController(rootViewController: categoryVC)
        //present modally
        presentViewController(navController, animated: true, completion: nil)
    }
    
    
    //dismiss the viewcontroller and go back to root
    func dismiss () {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //implementing delegate protocol to pass information around
    func sendCat(cat: String) {
        categoryPicker.setTitle(cat, forState: .Normal)
        categoryPicker.layer.borderColor = UIColor.greenColor().CGColor
    }
}