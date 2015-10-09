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
            cell.deleteButton.addTarget(self, action: "deletePicture:", forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if there are picture in array, then set the collection view border to finished.
        if imageArray.count > 0 {
            setBorder(collectionView, finished: true)
        } else {
            setBorder(collectionView, finished: false)
        }
        return (imageArray.count + 1)
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
    
    //delete picture function. the button gets passed into the function
    func deletePicture (button: UIButton) {
        //to find the indexPath we need to take the origin of the button's superview, as the button is in its own view (the cell)
        let indexPath = imageGallery.indexPathForItemAtPoint(button.superview!.frame.origin)
        //now perform batch updates to delete the picture. first from the table view, then from the imageArray.
        imageGallery.performBatchUpdates({ () -> Void in
            self.imageGallery.deleteItemsAtIndexPaths([indexPath!])
            self.imageArray.removeAtIndex(self.imageArray.count - indexPath!.row)
        }, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
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