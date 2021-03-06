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

class AddItemVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, CategoryVCDelegate, MapViewVCDelegate, UITextViewDelegate {
    
    @IBOutlet weak var imageGallery: UICollectionView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var categoryPicker: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    var validationDict: [UIView: Bool]!
    
    var activeField: UIView!
    
    //imagePicking variables
    var imageArray = [UIImage]()
    let imagePicker = UIImagePickerController()
    
    //initializing listing at the very beginning
    let listing = Listing()
    
    override func viewDidLoad() {
        validationDict = [imageGallery: false, titleField: false, descriptionField: false, addLocationButton: false, categoryPicker: false]
        super.viewDidLoad()
        
        //delegates
        descriptionField.delegate = self
        titleField.delegate = self
        
        //prepare navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
        navigationItem.title = "Edit Listing"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Preview", style: .Plain, target: self, action: "previewListing")
        
        //configuring imageGallery
        imageGallery.delegate = self
        imageGallery.dataSource = self
        imagePicker.delegate = self
        
        
        //set borders
        setBorder(descriptionField, finished: false)
        setBorder(imageGallery, finished: false)
        setBorder(titleField, finished: false)
        setBorder(categoryPicker, finished: false)
        setBorder(addLocationButton, finished: false)
        
        //Button Config
        addLocationButton.addTarget(self, action: "findLocation", forControlEvents: .TouchUpInside)
        categoryPicker.addTarget(self, action: "pickCategory", forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    func previewListing () {
        if validate() {
            //setting up our listing object
            let searchText = titleField.text!.lowercaseString + " " + descriptionField.text.lowercaseString
            listing.title = titleField.text
            listing.searchText = searchText
            listing.listingDescription = descriptionField.text
            listing.categories = [categoryPicker.titleLabel!.text!]
            listing.images = []
            if imageArray.count != 0 {
                for image in imageArray {
                    let imageData = UIImageJPEGRepresentation(image, 1.0)
                    let imageFile = PFFile(data: imageData!)
                    listing.images.append(imageFile!)
                }
            }
            //making sure that the listing is not published before pushing on the preview view. In the previewView, the user can look at how his listing would look and then publish it.
            listing.published = false
            let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as! DetailVC
            detailVC.currentListing = listing
            navigationController?.pushViewController(detailVC, animated: true)

        } else {
            let alert = UIAlertView(title: "Listing not finished", message: "Please fill in the remaining fields. Bear in mind that title and description need to have a certain length", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
        }
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
    
    //delegate function to get information from mapViewVC
    func coordinateTransmission(coordinate: CLLocationCoordinate2D, cityName: String) {
        listing.location = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        addLocationButton.setTitle(cityName, forState: .Normal)
        setBorder(addLocationButton, finished: true)
    }
    
    //dismiss the viewcontroller and go back to root
    func dismiss () {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //implementing delegate protocol to pass information around
    func sendCat(cat: String) {
        categoryPicker.setTitle(cat, forState: .Normal)
        setBorder(categoryPicker, finished: true)
    }
    
    //setting borders to reflect whether a user has filled in a field appropriately or whether it still needs work
    func setBorder (borderObject: UIView, finished: Bool) {
        borderObject.layer.cornerRadius = 5
        borderObject.layer.borderWidth = 1
        if finished {
            borderObject.layer.borderColor = UIColor.greenColor().CGColor
            //change state of the validationDict to reflect being finished
            validationDict[borderObject] = true
        } else {
            borderObject.layer.borderColor = UIColor.blackColor().CGColor
            validationDict[borderObject] = false
        }
    }

    func findLocation () {
        let mapViewVC = storyboard?.instantiateViewControllerWithIdentifier("MapViewVC") as! MapViewVC
        mapViewVC.delegate = self
        let navController = UINavigationController(rootViewController: mapViewVC)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    //checks to see whether all the fields have been filled appropriately. If not, it changes the border colors to red of the fields that have not been
    func validate () -> Bool {
        var counter = 0
        for (view, bool) in validationDict {
            if bool {
                counter += 1
                continue
            } else {
                view.layer.borderColor = UIColor.redColor().CGColor
            }
        }
        if counter == 5 {
            return true
        } else {
            return false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
        resignFirstResponder()
    }
}