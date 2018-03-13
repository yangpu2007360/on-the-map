//
//  UdacityConvenience.swift
//  on the map
//
//  Created by pu yang on 2/18/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClientAPI {

    
    func authenticateWithViewController(_ username: String?, password: String?, hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        self.postSessionID(username, password) { (success, errorString) in
            
            completionHandlerForAuth(success, errorString)
            
        }
    }
    
    func postSessionID(_ username: String?, _ password: String?, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let parameters: [String: [String: AnyObject]] = [Constants.JSONBodyKeys.udacity : [
            Constants.JSONBodyKeys.username: username as AnyObject,
            Constants.JSONBodyKeys.password: password as AnyObject
            ]]
        
        let url = "https://www.udacity.com/api/" + "session"
        
        let _ = taskForUdacityPOSTMethod(url, parameters: parameters as [String: [String : AnyObject]]) { (JSONResult, error) in
            
            if let error = error {
                
                completionHandler(false, error.localizedDescription)
                return
            }
            
            guard let session = JSONResult?[Constants.JSONResponseKeys.Session] as? [String: AnyObject] else {
                print("\tCould not find key: '\(Constants.JSONResponseKeys.Session)' in \(String(describing: JSONResult)). Error: \(String(describing: error) ).")
                completionHandler(false, error?.localizedDescription)
                return
            }
            print("\tPassed session: \(session)")
            
            guard let sessionID = session[Constants.JSONResponseKeys.sessionID] as? String else {
                print("\tCould not find key: '\(Constants.JSONResponseKeys.sessionID)' in \(session). Error: \(String(describing: error)).")
                completionHandler(false, error?.localizedDescription)
                return
            }
            print("\tPassed sessionID: \(sessionID)")
            
            guard let account = JSONResult?[Constants.JSONResponseKeys.account] as? [String: AnyObject] else {
                
                print("\tCould not find key: '\(Constants.JSONResponseKeys.account)' in \(String(describing: JSONResult) ). Error: \(String(describing: error)).")
                print("Invalid Login Credentials")
                completionHandler(false, error?.localizedDescription)
                
                return
            }
            print("\tPassed account: \(account)")
            
            guard let key = account[Constants.JSONResponseKeys.key] as? String else {
                print("\tCould not find key: '\(Constants.JSONResponseKeys.key)' in \(account). Error: \(String(describing: error)).")
                completionHandler(false, error?.localizedDescription)
                return
            }
            print("\tPassed account key: \(key)")
            
            userData.userId = key
            
            self.getPublicUserData() { (success, error) in

                if (success) {
                    print("\tSuccessfully got user data")
                } else {
                    print("\tCould not get user data: \(error!)")
                }

                completionHandler(true, "Invalid Login Credentials")
            }
            
            completionHandler(true, "Successful Login")
        }
        
    }
    
    func getPublicUserData(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let _ = taskForUdacityGETMethod("users/", userID: userData.userId, firstName: userData.firstName, lastName: userData.lastName) { (JSONResult, error) in
            
            if let error = error {
                print("\terror: \(error)")
                completionHandler(false, error.localizedDescription)
            } else {
                
                guard let user = JSONResult?[Constants.JSONResponseKeys.user] as? [String: AnyObject] else {
                    print("\tCould not find key: '\(Constants.JSONResponseKeys.user)' in \(String(describing: JSONResult))")
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                
                guard let userID = user[Constants.JSONResponseKeys.userIdKey] as? String else {
                    print("\tCould not find key: '\(Constants.JSONResponseKeys.userIdKey)' in \(String(describing: JSONResult))")
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                print("\tPassed GET userID: \(userID)")
                userData.userId = userID
                
                guard let firstName = user[Constants.JSONResponseKeys.first_Name] as? String else {
                    print("\tCould not find key: '\(Constants.JSONResponseKeys.first_Name)' in \(String(describing: JSONResult))")
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                print("\tPassed GET firstName: \(firstName)")
                
                userData.firstName = firstName
                
                guard let lastName = user[Constants.JSONResponseKeys.last_Name] as? String else {
                    print("Could not find key: '\(Constants.JSONResponseKeys.last_Name)' in \(String(describing: JSONResult))")
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                print("\tPassed GET lastName: \(lastName)")
                
                userData.lastName = lastName
                
                completionHandler(true, nil)
            }
        }
    }
    
    func Logout(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let url = "https://www.udacity.com/api/" + "session"
        let _ = taskForDELETEMethod(url) { (JSONResult, error) in
            
            if let error = error {
                print(error)
                completionHandler(false, "Logout Failed")
            } else {
                print("Log Out Successful")
                completionHandler(true, nil)
            }
        }
    }
    
}
