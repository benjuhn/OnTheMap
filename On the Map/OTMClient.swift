//
//  OTMClient.swift
//  On the Map
//
//  Created by Ben Juhn on 7/13/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

class OTMClient {
    
    // Shared session
    var session = URLSession.shared
    
    // Shared instance
    static let sharedInstance = OTMClient()
    private init() {}
    
    var userSessionId: String? = nil
    var userFirstName: String? = nil
    var userLastName: String? = nil
    var userUniqueKey: String? = nil
    
    // MARK: - Methods
    
    func taskForHTTPMethod(_ httpMethod: String, _ host: String, _ method: String, _ parameters: [String:String]?, _ httpHeader: [(String, String)]?, _ httpBody: String?, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL and configure the request */
        let request = NSMutableURLRequest(url: urlFromParameters(host, method, parameters))
        request.httpMethod = httpMethod
        
        // If Parse, add the Parse App ID and API Key
        if host == OTMClient.Constants.ParseApiHost {
            request.addValue(OTMClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        // Add other HTTP header fields
        if let httpHeader = httpHeader {
            for (value, headerField) in httpHeader {
                request.addValue(value, forHTTPHeaderField: headerField)
            }
        }
        
        // Add HTTP body
        if let httpBody = httpBody {
            request.httpBody = httpBody.data(using: String.Encoding.utf8)
        }
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299  else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard var data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // If Udacity, skip the first 5 characters of the response, which are used for security purposes in the Udacity API
            if host == OTMClient.Constants.UdacityApiHost {
                data = data.subdata(in: 5..<data.count)
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // Given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // Create a URL from parameters
    private func urlFromParameters(_ host: String, _ method: String, _ parameters: [String:String]?) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = host
        components.path = method
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value)
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
}
