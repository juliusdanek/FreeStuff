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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text != "" {
            textField.layer.borderColor = UIColor.greenColor().CGColor
        } else {
            textField.layer.borderColor = UIColor.blackColor().CGColor
        }
    }
    
    func previewListing () {
        let listing = PFObject(className: "Listing")
        var listingImages = [PFFile]()
        let searchText = titleField.text.lowercaseString + " " + descriptionField.text.lowercaseString
        listing.setObject(searchText, forKey: "searchText")
        listing.setObject(titleField.text, forKey: "title")
        listing.setObject(descriptionField.text, forKey: "description")
        listing["user"] = PFUser.currentUser()!
        if imageArray.count != 0 {
            for image in imageArray {
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                let imageFile = PFFile(data: imageData)
                listingImages.append(imageFile)
            }
        }
        listing.addObjectsFromArray(listingImages, forKey: "images")
        listing.setObject([categoryPicker.titleLabel!.text!], forKey: "categories")
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
            listing.setObject(geopoint!, forKey: "location")
            listing.saveInBackgroundWithBlock { (success, error) -> Void in
                println("object has been saved")
            }
        }

//        let listing = Listing(title: titleField.text, category: nil, images: imageArray, description: descriptionField.text, location: nil)
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.listings?.append(listing)
        dismiss()
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