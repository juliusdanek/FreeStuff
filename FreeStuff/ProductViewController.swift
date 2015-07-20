//
//  FirstViewController.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import UIKit
import Parse

class ProductViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //addButton for navigating to add screen
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "sellItem")
        //add the Button to the navBar
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //function used to present addVC
    func sellItem() {
        //instantiate add viewcontroller
        let addVC = storyboard?.instantiateViewControllerWithIdentifier("AddItemVC") as! AddItemVC
        //embed in nav controller
        let navController = UINavigationController(rootViewController: addVC)
        //present modally
        presentViewController(navController, animated: true, completion: nil)
    }
}

