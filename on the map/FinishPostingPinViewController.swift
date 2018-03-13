//
//  FinishPostingPinViewController.swift
//  on the map
//
//  Created by pu yang on 3/8/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class FinishPostingPinViewController: UIViewController, MKMapViewDelegate {
    
    var coordinate: CLLocationCoordinate2D!

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadMap()
        
        self.mapView.delegate = self
//        finishButton.layer.cornerRadius = 5
//        finishButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setAnnotations()
    }
    
    @IBAction func finishButton(_ sender: Any) {
        
        self.postStudentLocation() { (success) in
            
            if (success) {
                performUIUpdatesOnMain {
                    print("Successfully posted your location")
                }
            } else {
                
                performUIUpdatesOnMain {
                    print("Check your internet connection")
                }
            }
        }
        
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    func postStudentLocation(_ completionHandler: @escaping (_ success: Bool) -> Void) {
        
        self.setAnnotations()
        
        print("\tuserData: \(userData)")
        
        ParseClientAPI.sharedInstance().getMyParseObjectID(uniqueKey: userData.userId) { (success, errorString) in
            
            if userData.objectId == "" {
                
                ParseClientAPI.sharedInstance().postNewStudentLocation(userID: userData.userId, firstName: userData.firstName, lastName: userData.lastName, mediaURL: LocationData.enteredWebsite, mapString: LocationData.enteredLocation) { (success, errorString) in
                    
                    performUIUpdatesOnMain {
                        
                        if success {
                            completionHandler(true)
                            
                            // If successful, go on to the next view
                            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                            self.present(controller, animated: true, completion: nil)
                            
                            print("\tSuccessful POSTing new student location")
                            
                        } else {
                            completionHandler(false)
                            print("Failed to POST: \(errorString)")
                            self.errorAlert("Could not Post New Student Location")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                
                ParseClientAPI.sharedInstance().changeMyLocation(userID: userData.userId, firstName: userData.firstName, lastName: userData.lastName, mediaURL: LocationData.enteredWebsite, mapString: LocationData.enteredLocation) { (success, errorString) in
                    
                    if success {
                        completionHandler(true)
                        
                        // If successful, go on to the next view
                        let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                        self.present(controller, animated: true, completion: nil)
                        
                        print("\tSuccessful PUTing new student location")
                        
                    } else {
                        completionHandler(false)
                        print("Failed to PUT: \(String(describing: errorString))")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func loadMap() {
        
        let lat = CLLocationDegrees(LocationData.latitude as Double)
        let long = CLLocationDegrees(LocationData.longitude as Double)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        self.coordinate = coordinate
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(1, 1))
        mapView.setRegion(region, animated: true)
        
    }
    
    func setAnnotations() {
        
        var annotations = [MKPointAnnotation]()
        
        let annotation = MKPointAnnotation()
        
        annotation.title = userData.firstName + " " + userData.lastName
        print(annotation.title!)
        annotation.coordinate = self.coordinate
        print(annotation.coordinate)
        annotation.subtitle = LocationData.enteredWebsite
        print(annotation.subtitle!)
        annotations.append(annotation)
        
        self.mapView.addAnnotations(annotations)
    }
    
    func errorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
