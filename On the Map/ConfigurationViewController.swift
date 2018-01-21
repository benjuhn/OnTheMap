//
//  ConfigurationViewController.swift
//  On the Map
//
//  Created by Ben Juhn on 7/15/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController {

    let margin = UIScreen.main.bounds.width / 7
    let padding: CGFloat = 10
    let udacityBlue = UIColor(red: 2/255.0, green: 179/255.0, blue: 228/255.0, alpha: 1)
    
    let graphic = UIImageView()
    let topTextfield = UITextField()
    let bottomTextfield = UITextField()
    let button = UIButton()
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func setUIEnabled(_ enabled: Bool) {
        topTextfield.isEnabled = enabled
        bottomTextfield.isEnabled = enabled
        button.isEnabled = enabled
        if enabled {
            button.alpha = 1.0
            activityIndicator.stopAnimating()
        } else {
            button.alpha = 0.5
            view.bringSubview(toFront: activityIndicator)
            activityIndicator.startAnimating()
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        // Configure graphic imageview
        graphic.contentMode = .scaleAspectFit
        graphic.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(graphic)
        let graphicCenterX = NSLayoutConstraint(item: graphic, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let graphicTop = NSLayoutConstraint(item: graphic, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: margin)
        view.addConstraints([graphicCenterX, graphicTop])
        
        // Configure button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.backgroundColor = udacityBlue
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        addSubviewConstraints(button, view, .centerY, 0)
        
        // Configure bottom textfield
        configureTextField(bottomTextfield)
        view.addSubview(bottomTextfield)
        addSubviewConstraints(bottomTextfield, button, .top, padding)
        
        // Configure top textfield
        configureTextField(topTextfield)
        view.addSubview(topTextfield)
        addSubviewConstraints(topTextfield, bottomTextfield, .top, padding)
        
        // Configure activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.layer.cornerRadius = 5
        activityIndicator.backgroundColor = .darkGray
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        for attribute in [NSLayoutAttribute.centerX, NSLayoutAttribute.centerY] {
            let constraint = NSLayoutConstraint(item: activityIndicator, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    func configureTextField(_ textfield: UITextField) {
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.layer.cornerRadius = 5
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 0))
        textfield.leftViewMode = .always
        textfield.delegate = self
    }
    
    func addSubviewConstraints(_ subview: UIView, _ toItem: UIView, _ attribute: NSLayoutAttribute, _ constant: CGFloat) {
        let subviewWidth = NSLayoutConstraint(item: subview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: margin * 5)
        let subviewHeight = NSLayoutConstraint(item: subview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: margin * 0.8)
        let subviewCenterX = NSLayoutConstraint(item: subview, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let subviewBottom = NSLayoutConstraint(item: subview, attribute: .bottom, relatedBy: .equal, toItem: toItem, attribute: attribute, multiplier: 1, constant: -constant)
        view.addConstraints([subviewWidth, subviewHeight, subviewCenterX, subviewBottom])
    }
    
    func buttonAction() {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showErrorAlert(_ title: String?, _ message: String) {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAlert = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        errorAlert.addAction(closeAlert)
        present(errorAlert, animated: true, completion: nil)
    }
    
}

extension ConfigurationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == topTextfield {
            bottomTextfield.becomeFirstResponder()
        } else if textField == bottomTextfield {
            buttonAction()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.isEmpty {
            textField.layer.borderColor = UIColor.red.cgColor
        } else {
            textField.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
}

