//
//  MapViewController.swift
//  on the map
//
//  Created by pu yang on 3/8/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getMapLocations()
    }
    
    func getMapLocations() {
        
        ParseClientAPI.sharedInstance().getStudentLocations() { (results, errorString) in
            
            performUIUpdatesOnMain {
                if let results = results {
                    
                    print("Results from getMapLocations(): \(results)")
                    
                    self.setMapLocations()
                    
                    print("Success! Downloaded Student Locations")
                    
                } else {
                    print("Could not get student locations")
                }
            }
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        
        UdacityClientAPI.sharedInstance().Logout() { (success, errorString) in
            performUIUpdatesOnMain {
                if (success) {
                    self.dismiss(animated: true, completion: nil)}
                else {
                    self.errorAlert("Log Out Failed")
                }
            }
        }
    }
    
    
    @IBAction func reloadPressed(_ sender: Any) {
       
        for annotation: MKAnnotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
        getMapLocations()
        
    }
    
    
    @IBAction func addPinPressed(_ sender: Any) {
        
        if userData.objectId == "" {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "PostingNavController")
            self.present(controller, animated: true, completion: nil)
            
        } else {
            
            performUIUpdatesOnMain {
        
                let alertController = UIAlertController()
                alertController.title = "Pin alreay exsits"
                alertController.message = "There is alread a student location posted here. Would you like to overwrite their location?"
                
                let overwriteSelected = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default) { (action) in
                    
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "PostingNavController")
                    self.present(controller, animated: true, completion: nil)
                }
                
                let cancelSelected = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action) in
                    
                    alertController.dismiss(animated: true, completion: nil)
                }
                
                alertController.addAction(overwriteSelected)
                alertController.addAction(cancelSelected)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        
    }
    
    func setMapLocations() {
        
        let locations = StudentArray.sharedInstance.myArray
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            
            let lat = CLLocationDegrees(location.latitude as Double)
            let long = CLLocationDegrees(location.longitude as Double)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let firstName = location.firstName as String
            let lastName = location.lastName as String
            let mediaURL = location.mediaURL as String
            
            // Create the annotation and set its coordinate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            // Place the annotation in an array of annotations
            annotations.append(annotation)
        }
        
        self.mapView.delegate = self
        // Annotations array is complete, add them to the map
        self.mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView!.canShowCallout = true
        pinView!.pinTintColor = UIColor.red
        pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = URL(string: ((view.annotation?.subtitle)!)!) {
                app.open(toOpen, options: [:]) { (success) in
                    
                    if (success) {
                        print("Successfully loaded URL in subtitle description")
                    } else {
                        self.errorAlert("Could not load the URL")
                    }
                }
            }
        }
    }
    
    func errorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
