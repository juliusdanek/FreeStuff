//
//  SettingsVC.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/21/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import Foundation
import UIKit


class SettingsVC: UIViewController {
        
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    var settingsDict: [String:AnyObject]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //setting the slidervalue with the settings from our standard user settings
        settingsDict = NSUserDefaults.standardUserDefaults().objectForKey("standardSettings") as! [String:AnyObject]
        distanceSlider.value = Float(settingsDict["searchDistance"] as! Double)
        distanceLabel.text = String(stringInterpolationSegment: distanceSlider.value)
    }
    
    
    @IBAction func valueChanged(sender: AnyObject) {
        self.distanceLabel.text = String(stringInterpolationSegment: distanceSlider.value)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        settingsDict["searchDistance"] = Double(distanceSlider.value)
        NSUserDefaults.standardUserDefaults().setObject(settingsDict, forKey: "standardSettings")
    }
    
    
}
