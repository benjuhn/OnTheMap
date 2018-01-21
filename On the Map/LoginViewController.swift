//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ben Juhn on 7/11/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

class LoginViewController: ConfigurationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeUI()
    }
    
    func login() {
        let email = topTextfield.text!
        let password = bottomTextfield.text!
        if email.isEmpty {
            topTextfield.layer.borderColor = UIColor.red.cgColor
            topTextfield.becomeFirstResponder()
            if password.isEmpty {
                bottomTextfield.layer.borderColor = UIColor.red.cgColor
                showErrorAlert(nil, "Pleasse enter an email address and a password")
            }
            showErrorAlert(nil, "Please enter an email address")
        } else if password.isEmpty {
            bottomTextfield.layer.borderColor = UIColor.red.cgColor
            bottomTextfield.becomeFirstResponder()
            showErrorAlert(nil, "Please enter a password")
        } else {
            setUIEnabled(false)
            OTMClient.sharedInstance.login(email, password) {
                (success, error) in
                DispatchQueue.main.async {
                    self.setUIEnabled(true)
                    if success {
                        self.loadLocationsTabBarView()
                    } else {
                        self.showErrorAlert("Login Failed", error!)
                    }
                }
            }
        }
    }
    
    func loadLocationsTabBarView() {
        let tabView = LocationsTabBarController()
        let tabNav = UINavigationController(rootViewController: tabView)
        present(tabNav, animated: true, completion: nil)
    }
    
    // MARK: - Configuration helper functions
    
    func customizeUI() {
        configureUI()
        graphic.image = #imageLiteral(resourceName: "logo-u")
        topTextfield.placeholder = "Email"
        bottomTextfield.placeholder = "Password"
        bottomTextfield.isSecureTextEntry = true
        button.setTitle("LOG IN", for: .normal)
        
        // Configure sign up textview
        let signUpView = UITextView()
        signUpView.translatesAutoresizingMaskIntoConstraints = false
        signUpView.isEditable = false
        view.addSubview(signUpView)
        addSubviewConstraints(signUpView, button, .bottom, -(padding + margin))
        
        // Configure sign up message and link
        let message = NSMutableAttributedString(string: "Don't have an account? Sign Up")
        let target = message.mutableString.range(of: "Sign Up")
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        message.addAttributes([NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont(name: "Helvetica", size: 17)!], range: NSRange(location: 0, length: message.length))
        message.addAttribute(NSLinkAttributeName, value: "https://www.udacity.com/account/auth#!/signup", range: target)
        signUpView.linkTextAttributes = [NSForegroundColorAttributeName: udacityBlue]
        signUpView.attributedText = message
    }
    
    override func buttonAction() {
        login()
    }
    
}

extension LoginViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
    
}
