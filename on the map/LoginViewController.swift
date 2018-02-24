//
//  ViewController.swift
//  on the map
//
//  Created by pu yang on 2/12/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the app delegate
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
            self.errorAlert("Email or Password is Empty")
        } else {
            setUIEnabled(false)

            
            UdacityClientAPI.sharedInstance().authenticateWithViewController(emailTextField.text!, password: passwordTextField.text!, hostViewController: self) { (success, errorString) in
                
                if success == true {
                print("\tSuccessful Authentication")
                   self.completeLogin()

                } else {
                    performUIUpdatesOnMain {
                        self.errorAlert(errorString!)
                        self.setUIEnabled(true)

                    }
                }
            }
        }
    
        }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentLocationTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        
        performRegister()
        
    }
    func performRegister(){
        let urlString = "https://www.udacity.com/account/auth#!/signup"
        let url = URL(string: urlString)

        if let VC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
             let navVC = UINavigationController(rootViewController: VC)
        
            VC.url = url
    
            // TODO: handle auto login if possible
            present(navVC, animated: true, completion: nil)
        }
    }
    
    func errorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setUIEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled}

}

