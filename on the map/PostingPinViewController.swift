//
//  PostingPinViewController.swift
//  on the map
//
//  Created by pu yang on 2/19/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostingPinViewController: UIViewController, UITextFieldDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.isHidden = true
    }
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var enterLocationTextField: UITextField!
    
    @IBOutlet weak var enterWebsiteTextField: UITextField!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    @IBAction func findLocation(_ sender: Any) {
        self.activityIndicator.isHidden = false
        LocationData.enteredLocation = self.enterLocationTextField.text!
        LocationData.enteredWebsite = self.enterWebsiteTextField.text!
        
        if enterLocationTextField.text!.isEmpty || enterWebsiteTextField.text!.isEmpty {
            errorAlert("Location or Website fields Empty")
        } else {
            activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            getMyLocation() { (success, errorString) in
                
                if (success) {
                    print("Successfully set your location data")
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "FinishPostingPinViewController")
                    self.present(controller, animated: true, completion: nil)
                    
                } else {
                    
                    performUIUpdatesOnMain {
                        self.setUIEnabled(false)
                        self.errorAlert(errorString!)
                        self.setUIEnabled(true)

                    }
                }
            }
        }
    }
    
    func getMyLocation(completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(LocationData.enteredLocation!) { (placemark, error) in
            
            performUIUpdatesOnMain {
                
                print(Thread.isMainThread)
                
                if let error = error {
                    print("Could not geocode the entered location: \(error)")
                    completionHandler(false, error.localizedDescription)
                    return
                }
                
                guard let placemark = placemark else {
                    print("No placemarks found")
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                
                guard let latitude = placemark[0].location?.coordinate.latitude else {
                    print("This latitude placemark is: \(placemark)")
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                
                guard let longitude = placemark[0].location?.coordinate.longitude else {
                    print("This longitude placemark is: \(placemark)")
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                
                LocationData.latitude = latitude
                LocationData.longitude = longitude
                print(latitude)
                print(longitude)
                
                completionHandler(true, nil)
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.enterLocationTextField.resignFirstResponder()
        self.enterWebsiteTextField.resignFirstResponder()
        return true
    }
    
    func errorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setUIEnabled(_ enabled: Bool) {
        enterLocationTextField.isEnabled = enabled
        enterWebsiteTextField.isEnabled = enabled
        findLocationButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            findLocationButton.alpha = 1.0
        } else {
            findLocationButton.alpha = 0.5
        }
    }
}
