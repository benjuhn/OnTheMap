//
//  OTMConstants.swift
//  On the Map
//
//  Created by Ben Juhn on 7/14/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

extension OTMClient {
    
    // MARK: Constants
    struct Constants {
        
        static let ApiScheme = "https"
        
        // MARK: Udacity
        static let UdacityApiHost = "www.udacity.com"
        
        // MARK: Parse
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApiHost = "parse.udacity.com"
    }
    
    struct Methods {
        // MARK: Udacity
        static let UdacitySession = "/api/session"
        static let UdacityUserData = "/api/users/[userId]"
        
        // MARK: Parse
        static let ParseStudentLocation = "/parse/classes/StudentLocation"
    }
    
    struct URLKeys {
        // MARK: Udacity
        static let UdacityUserId = "[userId]"
        
        // MARK: Parse
        static let ParseObjectId = "[objectId]"
    }
    
    struct JSONResponseKeys {
        // MARK: Udacity
        static let UdacitySession = "session"
        static let UdacitySessionID = "id"
        static let UdacityUser = "user"
        static let UdacityFirstName = "first_name"
        static let UdacityLastName = "last_name"
        static let UdacityUniqueKey = "key"
        
        // MARK: Parse
        static let ParseUniqueKey = "uniqueKey"
        static let ParseFirstName = "firstName"
        static let ParseLastName = "lastName"
        static let ParseMapString = "mapString"
        static let ParseLatitude = "latitude"
        static let ParseLongitude = "longitude"
        static let ParseMediaURL = "mediaURL"
        
        static let ParseResults = "results"
        static let ParseLocationCreated = "createdAt"
    }
}
