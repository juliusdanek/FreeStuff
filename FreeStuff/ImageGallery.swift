//
//  ImageGallery.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import Foundation
import UIKit

extension AddItemVC {
    
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
    
    func addPicture () {
        //Setting up an alertView to ask user whether he wants to have a picture from an Album or camera
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertVC.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (alertAction) -> Void in
            self.chooseImage(.Camera, editing: true)
        }))
        alertVC.addAction(UIAlertAction(title: "Album", style: .Default, handler: { (alertAction) -> Void in
            self.chooseImage(.PhotoLibrary, editing: true)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alertAction) -> Void in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //if image has been edited, display edited image.
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageArray.append(pickedImage)
            //else: display original image (in case of camera roll)
        } else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageArray.append(pickedImage)
        }
        //reload our gallery to display updated picture
        imageGallery.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //function to pick image based on source type, shows viewcontroller for imagepicker
    func chooseImage(sourceType: UIImagePickerControllerSourceType, editing: Bool) {
        imagePicker.allowsEditing = editing
        imagePicker.sourceType = sourceType
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
}