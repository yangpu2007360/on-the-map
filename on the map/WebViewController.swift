//
//  WebViewController.swift
//  on the map
//
//  Created by pu yang on 2/13/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var url:URL?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = url {
            let req = URLRequest(url: url)
            webView.loadRequest(req)
        } else {
            dismiss(animated: true, completion: {
                self.alert(title: "Failed", message: "Please try agian later")
            })
        }
    }

    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func alert(title: String = "", message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


}
