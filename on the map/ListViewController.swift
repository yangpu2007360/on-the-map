//
//  ListViewController.swift
//  on the map
//
//  Created by pu yang on 3/8/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudentLocations()
        self.tableView.reloadData()
    }
    
    func getStudentLocations() {
        
        ParseClientAPI.sharedInstance().getStudentLocations() { (results, errorString) in
            
            performUIUpdatesOnMain {
                if (results != nil) {
                    self.tableView.reloadData()
                    
                } else {
                    self.errorAlert(errorString!)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentArray.sharedInstance.myArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")! as UITableViewCell
        
        let studentLocation = StudentArray.sharedInstance.myArray[indexPath.row]
        
        cell.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel?.text = "\(studentLocation.mediaURL)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let websiteToLoad = StudentArray.sharedInstance.myArray[indexPath.row].mediaURL
    
        if websiteToLoad.range(of: "http") != nil {
            
            UIApplication.shared.open(URL(string: "\(websiteToLoad)")!, options: [:]) { (success) in
                
                if (success) {
                    print("URL successfully opened!")
                } else {
                    performUIUpdatesOnMain {
                        print("URL could not be loaded.")
                        self.errorAlert("could not open URL")
                    }
                }
            }
            
        } else {
            performUIUpdatesOnMain {
                print("Invalid link")
                self.errorAlert("could not open URL")
            }
        }
    }

    @IBAction func logOutPressed(_ sender: Any) {
        
        UdacityClientAPI.sharedInstance().Logout() { (success, errorString) in
            performUIUpdatesOnMain {
                
                if (success) {
                    self.dismiss(animated: false, completion: nil)
                    
                } else {
                    print("Log Out Failed")
                    self.errorAlert("Log Out Failed")
                }
            }
        }
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
    
    @IBAction func reloadButton(_ sender: Any) {
        
        getStudentLocations()
        print("Success! Downloaded Student Locations")
        
    }
    
    func errorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

    
    
    
    
}
