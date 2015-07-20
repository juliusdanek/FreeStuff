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

class AddItemVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageGallery: UICollectionView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    var imageArray = [UIImage]()
    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prepare navigation bar
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
        navigationController?.title = "Add Listing"
        
        //configuring imageGallery
        imageGallery.delegate = self
        imageGallery.dataSource = self
        imagePicker.delegate = self
        
        //configuring textview
        descriptionField.layer.cornerRadius = 5
        descriptionField.layer.borderColor = UIColor.blackColor().CGColor
        descriptionField.layer.borderWidth = 1
        
        //previewButton
        previewButton.addTarget(self, action: "previewListing", forControlEvents: .TouchUpInside)
        
        addLocationButton.addTarget(self, action: "findLocation", forControlEvents: .TouchUpInside)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageGalleryCell
        //check whether there is an image available in the imageArray, if not then we can assume that images will be uploaded from button
        if imageArray.endIndex > indexPath.row && imageArray.count != 0 {
            cell.imageView.image = imageArray[indexPath.row]
            cell.addButton.hidden = true
        } else {
            cell.addButton.addTarget(self, action: "addPicture", forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func previewListing () {
        let listing = PFObject(className: "Listing")
        listing.setObject(titleField.text, forKey: "title")
        listing.setObject(descriptionField.text, forKey: "description")
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
    
    
    
    //dismiss the viewcontroller and go back to root
    func dismiss () {
        dismissViewControllerAnimated(true, completion: nil)
    }
}