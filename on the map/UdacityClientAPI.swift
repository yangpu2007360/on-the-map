//
//  UdacityClientAPI.swift
//  on the map
//
//  Created by pu yang on 2/15/18.
//  Copyright © 2018 pu yang. All rights reserved.
//
import Foundation
import UIKit

class UdacityClientAPI: NSObject {
    // Shared Session
    var session = URLSession.shared
    
    // Initializer
    override init() {
        super.init()
    }
    
    func taskForUdacityPOSTMethod(_ urlString: String, parameters: [String: [String: AnyObject]], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {

        
        // Build the URL, Configure the request
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your Udacity POST request: \(String(describing: error))")
                completionHandlerForPOST(nil, error! as NSError)
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request: \(String(describing: error))")
                completionHandlerForPOST(nil, error! as NSError)
                return
            }
            
            // Parse the data and use the data(First skip the first 5 characters of the response (Security characters by Udacity))
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch let error as NSError {
                completionHandlerForPOST(nil, error)
                return
            }
            
            if let errorString = parsedResult["error"] as? String {
                print(errorString)
                
                let errorStr = "Invalid login credentials"
                let error = NSError(domain: errorStr, code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])
                
                completionHandlerForPOST(nil, error as NSError)
                return
            }
            
            completionHandlerForPOST(parsedResult, nil)
        }
        
        task.resume()
        return task
    }
    
    func taskForUdacityGETMethod(_ method: String, userID: String, firstName: String, lastName: String, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = Constants.OTM.UdacityBaseURL + method + userID
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your Udacity POST request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!: \(String(describing: response) )")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data(First skip the first 5 characters of the response (Security characters by Udacity))
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
            
            
        }
        task.resume()
        return task
    }

    // DELETE method used to logout
    func taskForDELETEMethod(_ urlString: String, completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = urlString
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your DELETE request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDELETE)
            
        }
        task.resume()
        return task
        
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    class func sharedInstance() -> UdacityClientAPI {
        struct Singleton {
            static var sharedInstance = UdacityClientAPI()
        }
        return Singleton.sharedInstance
    }


}
