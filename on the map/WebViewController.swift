//
//  WebViewController.swift
//  on the map
//
//  Created by pu yang on 3/8/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var url:URL?
    @IBOutlet weak var webView: UIWebView!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = url {
            let req = URLRequest(url: url)
            webView.loadRequest(req)
        } else {
            dismiss(animated: true, completion: {
                self.errorAlert("Could not access the webside. Please try agian later")
            })
        }
    }

    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func errorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


}
