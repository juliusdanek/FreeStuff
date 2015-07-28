//
//  Listing.swift
//  FreeStuff
//
//  Created by Julius Danek on 7/19/15.
//  Copyright (c) 2015 Julius Danek. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Listing: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Listing"
    }
    
    @NSManaged var title: String?
    @NSManaged var categories: [String]
    @NSManaged var images: [PFFile]
    @NSManaged var listingDescription: String?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var published: Bool
    @NSManaged var searchText: String?
    @NSManaged var user: PFUser
}