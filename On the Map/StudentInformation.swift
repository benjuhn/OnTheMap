//
//  StudentInformation.swift
//  On the Map
//
//  Created by Ben Juhn on 7/14/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

struct StudentInformation {
    
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let latitude: Double?
    let longitude: Double?
    let mediaURL: String?
    
    init(dictionary: [String:AnyObject]) {
        uniqueKey = dictionary[OTMClient.JSONResponseKeys.ParseUniqueKey] as! String?
        firstName = dictionary[OTMClient.JSONResponseKeys.ParseFirstName] as! String?
        lastName = dictionary[OTMClient.JSONResponseKeys.ParseLastName] as! String?
        mapString = dictionary[OTMClient.JSONResponseKeys.ParseMapString] as! String?
        latitude = dictionary[OTMClient.JSONResponseKeys.ParseLatitude] as! Double?
        longitude = dictionary[OTMClient.JSONResponseKeys.ParseLongitude] as! Double?
        mediaURL = dictionary[OTMClient.JSONResponseKeys.ParseMediaURL] as! String?
    }
    
}
