//
//  ParseClientAPI.swift
//  on the map
//
//  Created by pu yang on 2/19/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import UIKit

class ParseClientAPI: NSObject {
    
    // Shared Session
    var session = URLSession.shared
    
    func taskForParsePUTMethod(_ method: String, objectId: String, jsonBody: [String: AnyObject], completionHandlerForPUT: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = Constants.OTM.ParseBaseURL + method + objectId
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(Constants.OTM.ParseApplicationID, forHTTPHeaderField: Constants.OTMParameterKeys.ApplicationID)
        request.addValue(Constants.OTM.ParseApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your Parse PUT request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPUT)
        }
        task.resume()
        return task
    }
    
    func taskForParsePOSTMethod(_ method: String, jsonBody: [String: AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = Constants.OTM.ParseBaseURL + method
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(Constants.OTM.ParseApplicationID, forHTTPHeaderField: Constants.OTMParameterKeys.ApplicationID)
        request.addValue(Constants.OTM.ParseApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your Parse POST request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        task.resume()
        return task
    }
    
    func taskForParseGETMethod(_ method: String, parameters: [String: AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        print("\t url: \(parseURLFromParametersForGET(parameters, withPathExtension: method))")
        let request = NSMutableURLRequest(url: parseURLFromParametersForGET(parameters, withPathExtension: method))
        request.addValue(Constants.OTM.ParseApplicationID, forHTTPHeaderField: Constants.OTMParameterKeys.ApplicationID)
        request.addValue(Constants.OTM.ParseApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.ApiKey)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your Udacity POST request: \(String(describing: error))")
                completionHandlerForGET(nil, error! as NSError)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 599 else {
                print("Your request returned a status code with an error!: \(String(describing: response))")
                completionHandlerForGET(nil, error! as NSError)
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandlerForGET(nil, error! as NSError)
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch let error as NSError {
                completionHandlerForGET(nil, error)
                return
            }
            
            if let errorString = parsedResult["error"] as? String {
                print(errorString)
                
                let errorStr = "Not able to get Student Locations"
                let error = NSError(domain: errorStr, code: 0, userInfo: [NSLocalizedDescriptionKey: errorString])
                
                completionHandlerForGET(nil, error as NSError)
                return
            }
            
            completionHandlerForGET(parsedResult, nil)
        }
        task.resume()
        return task
    }
    
    func getStudentLocationFromParse(_ method: String, parameters: [String: AnyObject], _ completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        print("\nIn ParseClientAPI.getStudentLocationFromParse() ...")
        print("\t url: \(parseURLFromParameters(parameters, withPathExtension: method))")
        let request = NSMutableURLRequest(url: parseURLFromParameters(parameters, withPathExtension: method))
        request.httpMethod = "GET"
        request.addValue(Constants.OTM.ParseApplicationID, forHTTPHeaderField: Constants.OTMParameterKeys.ApplicationID)
        request.addValue(Constants.OTM.ParseApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.ApiKey)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                print("\tThere was an error with your Parse POST request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("\tYour request returned a status code other than 2xx!: \(response!)")
                return
            }
            
            guard let data = data else {
                print("\tNo data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        return task
    }
    
    // Parse method for getStudentLocationFromParse()
    private func parseURLFromParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {

        var components = URLComponents()
        components.scheme = Constants.OTM.ParseScheme
        components.host = Constants.OTM.ParseHost
        components.path = Constants.OTM.ParsePath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()

        for (key, value) in parameters {

            let queryItem = URLQueryItem(name: key, value: "{\"uniqueKey\":\"\(value)\"}") // {"uniqueKey":"1234"}
            components.queryItems!.append(queryItem)
        }
        return components.url!
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
    
    // Parse method for taskForParseGETMethod()
    private func parseURLFromParametersForGET(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.OTM.ParseScheme
        components.host = Constants.OTM.ParseHost
        components.path = Constants.OTM.ParsePath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func sharedInstance() -> ParseClientAPI {
        struct Singleton {
            static var sharedInstance = ParseClientAPI()
        }
        return Singleton.sharedInstance
    }
}
