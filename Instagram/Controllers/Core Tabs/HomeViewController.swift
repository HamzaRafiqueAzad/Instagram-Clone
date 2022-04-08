//
//  ViewController.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Check Auth Status
        handelNotAuthenticated()
    }
    
    private func handelNotAuthenticated() {
        
        if Auth.auth().currentUser == nil {
            //Show Login View
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        }
    }

}

