import Foundation
import UIKit

class StudentArray {
    
    class var sharedInstance: StudentArray {
        
        struct Static {
            static var instance: StudentArray = StudentArray()
        }
        
        return Static.instance
    }
    
    var myArray: [StudentLocation] = [StudentLocation]()
    
    static func locationsFromResults(_ results: [[String: AnyObject]]) -> [StudentLocation] {
        
        var studentLocations = [StudentLocation]()
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
    
}


