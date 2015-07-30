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
        //check if it is the first cell. If it is, show the button, make the image nil and add the target to the button.
        if indexPath.row == 0 {
            cell.imageView.image = nil
            cell.addButton.addTarget(self, action: "addPicture", forControlEvents: .TouchUpInside)
            cell.addButton.hidden = false
            cell.deleteButton.hidden = true
        } else {
            //with this method of calculating array access, always the last element from the array gets displayed first. This way, the image collection view keep on shifting to the right
            cell.imageView.image = imageArray[imageArray.count - indexPath.row]
            cell.addButton.hidden = true
            cell.deleteButton.hidden = false
            cell.deleteButton.addTarget(self, action: "deletePicture", forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCounter
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
    
    func deletePicture () {
        
        println("delete picture")
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
        collectionCounter += 1
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