
import Foundation
import UIKit
import MapKit

extension ParseClientAPI {
    
    func changeMyLocation( userID: String, firstName: String, lastName: String, mediaURL: String, mapString: String, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let jsonBody: [String: AnyObject] = [
            Constants.JSONBodyKeys.uniqueKey: userID as AnyObject,
            Constants.JSONBodyKeys.FirstName: firstName as AnyObject,
            Constants.JSONBodyKeys.LastName: lastName as AnyObject,
            Constants.JSONBodyKeys.MediaURL: mediaURL as AnyObject,
            Constants.JSONBodyKeys.MapString: mapString as AnyObject
        ]
        
        let _ = taskForParsePUTMethod(Constants.Methods.LocationWithSlash, objectId: userData.objectId, jsonBody: jsonBody) { (JSONResult, error) in
            
            if let error = error {
                print(error)
                completionHandler(false, "Could not change your student location.")
            } else {
                print("Successfully changed your student location.")
                
                guard let jsonResult = JSONResult as? [String: AnyObject] else {
                    print("No data was found")
                    return
                }
                
                print(jsonResult)
                
                completionHandler(true, nil)
            }
        }
    }
    
    func getStudentLocations(_ completionHandler: @escaping (_ results: [StudentLocation]?, _ errorString: String?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            Constants.OTMParameterKeys.limit: 100 as AnyObject,
            Constants.OTMParameterKeys.order: "-updatedAt" as AnyObject
        ]
        
        let _ = taskForParseGETMethod(Constants.Methods.Location, parameters: parameters) { (JSONResult, error) in
            
            if let error = error {
                print(error)
                completionHandler(nil, error.localizedDescription)
            } else {
                // Return the locations result, otherwise let us know that there were no results in the output
                if let locations = JSONResult?[Constants.JSONResponseKeys.LocationResults] as? [[String: AnyObject]] {
                    StudentArray.sharedInstance.myArray = StudentLocation.locationsFromResults(locations)
                    
                    completionHandler(StudentArray.sharedInstance.myArray, nil)
                } else {
                    completionHandler(nil, error?.localizedDescription)
                }
            }
        }
    }
    
    func getMyParseObjectID(uniqueKey: String, _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            
            Constants.OTMParameterKeys.queryWhere: uniqueKey as AnyObject
        ]
        
        let _ = getStudentLocationFromParse(Constants.Methods.Location, parameters: parameters) { (JSONResult, error) in
            
            if let error = error {
                print("\t\(error)")
                completionHandler(false, "Could not get objectID")
            } else {
                
                guard let results = JSONResult?["results"] as? [[String: AnyObject]] else {
                    print("\tCould not find results dictionary.")
                    return
                }
                print(results.count)
                
                if results.count == 0 {
                    
                    userData.objectId = ""
                    completionHandler(true, "")
                    
                } else {
                let myStudentLocation = results[results.count-1]
                print("\nIn ParseClientAPI.getMyParseObjectID() ...")
                print("\tmyStudentLocation: \(myStudentLocation)")
                
                guard let objectId = myStudentLocation[Constants.JSONResponseKeys.objectID] as? String else {
                    print("\tCould not find key: '\(Constants.JSONResponseKeys.objectID)' in \(String(describing: JSONResult))")
                    return
                }
                
                userData.objectId = objectId
                print("\tSuccess in getting my objectId: \(objectId)")
                    completionHandler(true, "")}
            }
        }
    }
    
    func postNewStudentLocation(userID: String, firstName: String, lastName: String, mediaURL: String, mapString: String, _ completionHandler: @escaping (_ success: Bool, _ errorString: String) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(mapString) { (placemarks, error) -> Void in
            
            if let placemark = placemarks?.first {
                
                let coordinates: CLLocationCoordinate2D = (placemark.location!.coordinate)
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                
                let jsonBody: [String: AnyObject] = [
                    
                    Constants.JSONBodyKeys.uniqueKey: userID as AnyObject,
                    Constants.JSONBodyKeys.FirstName: firstName as AnyObject,
                    Constants.JSONBodyKeys.LastName: lastName as AnyObject,
                    Constants.JSONBodyKeys.Latitude: latitude as AnyObject,
                    Constants.JSONBodyKeys.Longitude: longitude as AnyObject,
                    Constants.JSONBodyKeys.MediaURL: mediaURL as AnyObject,
                    Constants.JSONBodyKeys.MapString: mapString as AnyObject
                ]
                
                print("\nIn postNewStudentLocation, jsonBody: \(jsonBody)")
                let _ = self.taskForParsePOSTMethod(Constants.Methods.Location, jsonBody: jsonBody) { (JSONResult, error) in
                    
                    if let error = error {
                        print(error)
                        completionHandler(false, "Could not POST Student Location.")
                    } else {
                        
                        guard let createdAt = JSONResult?[Constants.JSONResponseKeys.CreatedAt] as? String else {
                            print("Could not find key: '\(Constants.JSONResponseKeys.CreatedAt)' in \(String(describing: JSONResult))")
                            return
                        }
                        print("\nIn postNewStudentLocation, Successful posting of my location: CreatedAt: \(createdAt)")
                        
                        guard let objectId = JSONResult?[Constants.JSONResponseKeys.objectID] as? String else {
                            print("Could not find key: '\(Constants.JSONResponseKeys.objectID)' in \(String(describing: JSONResult))")
                            return
                        }
                        
                        userData.objectId = objectId
                        print("\nIn postNewStudentLocation, Successful posting of my location: ObjectId: \(objectId)")
                        
                        completionHandler(true, "Success in parsing for the POST Method.")
                    }
                }
            }
        }
    }
    
    

}
