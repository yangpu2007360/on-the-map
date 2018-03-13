//
//  ViewController.swift
//  on the map
//
//  Created by pu yang on 3/8/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            self.errorAlert("Please enter your email and password")
        } else {
            emailTextField.isEnabled = false
            passwordTextField.isEnabled = false
            loginButton.isEnabled = false
            
            UdacityClientAPI.sharedInstance().authenticateWithViewController(emailTextField.text!, password: passwordTextField.text!, hostViewController: self) { (success, errorString) in
                
                if success == true {
                print("\tSuccessful Authentication")
                   self.goToTabBar()

                } else {
                    performUIUpdatesOnMain {
                        self.errorAlert(errorString!)
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                        self.loginButton.isEnabled = true
                    }
                }
            }
        }
    
        }
    
    private func goToTabBar() {
        performUIUpdatesOnMain {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController

            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        
        Register()
        
    }
    func Register(){
        
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")

        if let VC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {

            VC.url = url

            present(VC, animated: true, completion: nil)
        }
    }
    
    func errorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}

