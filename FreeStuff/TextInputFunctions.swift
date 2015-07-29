
//
//  LocationFinder.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import Foundation
import UIKit

extension AddItemVC {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        activeField = textView
        if textView.text == "Item description" {
            textView.text = ""
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text.isEmpty {
            setBorder(titleField, finished: false)
        } else {
            setBorder(titleField, finished: true)
        }
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        activeField = nil
        return true
    }
    
    //if text changes and we have text, change border color to green
    func textViewDidChange(textView: UITextView) {
        if textView.text.isEmpty == false {
            setBorder(descriptionField, finished: true)
        } else {
            setBorder(descriptionField, finished: false)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        activeField = nil
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            //checking whether the visible frame contains the bottom point of the field in question
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            if activeField != nil {
                let bottomPoint = CGPoint(x: activeField.frame.origin.x, y: activeField.frame.maxY)
                if CGRectContainsPoint(aRect, bottomPoint) == false {
                    let contentInsets = UIEdgeInsetsMake((scrollView.contentInset.top - activeField.frame.height) , 0, 0, 0)
                    scrollView.contentInset = contentInsets
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let navBar = navigationController?.navigationBar
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        let contentInsets = UIEdgeInsetsMake((navBar!.frame.size.height + statusBarFrame.height) , 0, 0, 0)
        scrollView.contentInset = contentInsets
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
}