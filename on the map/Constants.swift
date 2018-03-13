import Foundation
import UIKit

struct Constants {
    
    struct JSONBodyKeys {
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
        static let account = "account"
        
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ACL = "ACL"
        
    }
    
    struct JSONResponseKeys {
        
        // General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let sessionID = "id"
        
        // Account
        static let UserID = "id"
        static let account = "account"
        static let key = "key"
        
        static let user = "user"
        static let userIdKey = "key"
        static let last_Name = "last_name"
        static let first_Name = "first_name"
        static let results = "results"
        
        // Student Locations
        static let LocationResults = "results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
        
}
}
