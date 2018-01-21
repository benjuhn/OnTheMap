//
//  OTMConvenience.swift
//  On the Map
//
//  Created by Ben Juhn on 7/14/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

extension OTMClient {
    
    // MARK: - Udacity methods
    
    // Log in to Udacity
    func login(_ email: String, _ password: String, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let httpHeader = [("application/json", "Accept"),
                          ("application/json", "Content-Type")]
        let httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        
        let _ = taskForHTTPMethod("POST", OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacitySession, nil, httpHeader, httpBody) { (results, error) in
            
            if let error = error {
                self.convertError(error, completionHandler)
                return
            }
            
            guard let response = results as? [String:AnyObject],
                let session = response[OTMClient.JSONResponseKeys.UdacitySession] as? [String:AnyObject],
                let sessionID = session[OTMClient.JSONResponseKeys.UdacitySessionID] as? String else {
                completionHandler(false, "Error creating session")
                return
            }
            
            self.userSessionId = sessionID
            
            self.getUserData(email, completionHandler)
        }
    }
    
    // Get the Udacity user data
    func getUserData(_ userId: String, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let getUserDataMethod = substituteKey(OTMClient.Methods.UdacityUserData, key: OTMClient.URLKeys.UdacityUserId, value: userId)!
        
        let _ = taskForHTTPMethod("GET", OTMClient.Constants.UdacityApiHost, getUserDataMethod, nil, nil, nil) { (results, error) in
            
            if let error = error {
                self.convertError(error, completionHandler)
                return
            }
            
            guard let response = results as? [String:AnyObject],
                let user = response[OTMClient.JSONResponseKeys.UdacityUser] as? [String:AnyObject],
                let firstName = user[OTMClient.JSONResponseKeys.UdacityFirstName] as? String,
                let lastName = user[OTMClient.JSONResponseKeys.UdacityLastName] as? String,
                let uniqueKey = user[OTMClient.JSONResponseKeys.UdacityUniqueKey] as? String else {
                completionHandler(false, "Error retrieving user data")
                return
            }
            
            self.userFirstName = firstName
            self.userLastName = lastName
            self.userUniqueKey = uniqueKey
            
            completionHandler(true, nil)
        }
    }
    
    // Log out of Udacity, run in the background and "fail gracefully" if unsuccessful (no completion handler is called)
    func logout() {
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        var httpHeader: [(String,String)]? = nil
        if let xsrfCookie = xsrfCookie {
            httpHeader = [(xsrfCookie.value, "X-XSRF-TOKEN")]
        }
        
        let _ = taskForHTTPMethod("DELETE", OTMClient.Constants.UdacityApiHost, OTMClient.Methods.UdacitySession, nil, httpHeader, nil) { (results, error) in
        }
        
        userSessionId = nil
        userFirstName = nil
        userLastName = nil
        userUniqueKey = nil
        
        StoredStudentInformation.sharedInstance.students?.removeAll()
    }
    
    // MARK: - Parse methods
    
    // Get recent locations posted by students
    func updateRecentStudentLocations(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let parameters: [String:String] = ["limit": "100",
                                           "order": "-updatedAt"]
        
        let _ = taskForHTTPMethod("GET", OTMClient.Constants.ParseApiHost, OTMClient.Methods.ParseStudentLocation, parameters, nil, nil) { (results, error) in
            
            if let error = error {
                self.convertError(error, completionHandler)
                return
            }
            
            guard let results = results?[OTMClient.JSONResponseKeys.ParseResults] as? [[String:AnyObject]] else {
                let error = NSError(domain: "updateRecentStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse student location information. Missing key: \(OTMClient.JSONResponseKeys.ParseResults)"])
                self.convertError(error, completionHandler)
                return
            }
            
            var students = [StudentInformation]()
            for result in results {
                students.append(StudentInformation(dictionary: result))
            }
            StoredStudentInformation.sharedInstance.students = students
            
            completionHandler(true, nil)
        }
    }
    
    // Post student location to Parse
    func postStudentLocation(_ mapString: String, _ mediaURL: String, _ latitude: Double, _ longitude: Double, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let httpHeader = [("application/json", "Content-Type")]
        let httpBody = "{\"\(OTMClient.JSONResponseKeys.ParseUniqueKey)\": \"\(userUniqueKey!)\", \"\(OTMClient.JSONResponseKeys.ParseFirstName)\": \"\(userFirstName!)\", \"\(OTMClient.JSONResponseKeys.ParseLastName)\": \"\(userLastName!)\",\"\(OTMClient.JSONResponseKeys.ParseMapString)\": \"\(mapString)\", \"\(OTMClient.JSONResponseKeys.ParseMediaURL)\": \"\(mediaURL)\",\"\(OTMClient.JSONResponseKeys.ParseLatitude)\": \(latitude), \"\(OTMClient.JSONResponseKeys.ParseLongitude)\": \(longitude)}"
        
        let _ = taskForHTTPMethod("POST", OTMClient.Constants.ParseApiHost, OTMClient.Methods.ParseStudentLocation, nil, httpHeader, httpBody) { (results, error) in
            
            if let error = error {
                self.convertError(error, completionHandler)
                return
            }
            
            guard let _ = results?[OTMClient.JSONResponseKeys.ParseLocationCreated] else {
                let error = NSError(domain: "saveStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not save student location. Missing key: \(OTMClient.JSONResponseKeys.ParseLocationCreated)."])
                self.convertError(error, completionHandler)
                return
            }
            
            completionHandler(true, nil)
        }
    }
    
    // MARK: - Helper methods
    
    // Convert errors into user-friendly messages before returning through completion handler
    private func convertError(_ error: NSError,_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let errorString = error.userInfo[NSLocalizedDescriptionKey].debugDescription
        
        if errorString.contains("timed out") {
            completionHandler(false, "Couldn't reach server (timed out)")
        } else if errorString.contains("Status code returned: 403"){
            completionHandler(false, "Wrong email or password")
        } else if errorString.contains("Could not parse student location information") {
            completionHandler(false, "Error processing student data")
        } else if errorString.contains("Could not update student location") {
            completionHandler(false, "Error updating your location")
        } else if errorString.contains("network connection was lost"){
            completionHandler(false, "The network connection was lost")
        } else if errorString.contains("Internet connection appears to be offline") {
            completionHandler(false, "The Internet connection appears to be offline")
        } else {
            completionHandler(false, "Please try again.")
        }
    }
    
    // Substitute the key for the value that is contained within the string
    private func substituteKey(_ string: String, key: String, value: String) -> String? {
        if string.range(of: key) != nil {
            return string.replacingOccurrences(of: key, with: value)
        } else {
            return nil
        }
    }
}
