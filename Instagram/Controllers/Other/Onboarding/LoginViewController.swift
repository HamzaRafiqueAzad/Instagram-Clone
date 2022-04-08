//
//  LoginViewController.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let usernameEmailField: UITextField = {
        return UITextField()
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        return UIButton()
    }()
    
    private let privacyButton: UIButton = {
        return UIButton()
    }()
    
    private let createAccountButton: UIButton = {
        return UIButton()
    }()
    
    private let termsButton: UIButton = {
        return UIButton()
    }()
    
    private let headerView: UIView = {
        return UIView()
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSubviews()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Assign Frames
        
    }
    
    private func addSubviews() {
        
        view.addSubview(usernameEmailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
        view.addSubview(headerView)


    }
    
    @objc private func didTapLoginButton() {}
    
    @objc private func didTapTermsButton() {}
    
    @objc private func didTapPrivacyButton() {}
    
    @objc private func didTapCreateAccountButton() {}
    

}
