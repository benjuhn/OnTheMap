//
//  PostingViewController.swift
//  On the Map
//
//  Created by Ben Juhn on 7/15/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit
import MapKit

protocol PostingDelegate: class {
    func refresh()
}

class PostingViewController: ConfigurationViewController {

    weak var delegate: PostingDelegate?
    
    var addressString = String()
    var url = String()
    var coordinate = CLLocationCoordinate2D()
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeUI()
    }
    
    func findLocation() {
        addressString = topTextfield.text!
        url = bottomTextfield.text!
        if addressString.isEmpty {
            showErrorAlert("LOCATION", "Please enter a location")
            topTextfield.layer.borderColor = UIColor.red.cgColor
            topTextfield.becomeFirstResponder()
            if url.isEmpty {
                bottomTextfield.layer.borderColor = UIColor.red.cgColor
            }
        } else if url.isEmpty {
            showErrorAlert("WEBSITE", "Please enter a website")
            bottomTextfield.layer.borderColor = UIColor.red.cgColor
            bottomTextfield.becomeFirstResponder()
        } else {
            if !(url.lowercased().hasPrefix("http://") || url.lowercased().hasPrefix("https://")) {
                url = "http://" + url
            }
            setUIEnabled(false)
            mapLocation()
        }
    }
    
    func mapLocation() {
        CLGeocoder().geocodeAddressString(addressString) { (placemark, error) in
            self.setUIEnabled(true)
            if error != nil {
                if error.debugDescription.contains("Code=2") {
                    self.showErrorAlert("Find Location Failed", "Could not connect to the network")
                } else if error.debugDescription.contains("Code=8") {
                    self.showErrorAlert("Find Location Failed", "Location could not be found")
                } else {
                    self.showErrorAlert("Find Location Failed", "Error occurred while trying to find the location")
                }
                return
            } else {
                guard let location = placemark?.first?.location else {
                    self.showErrorAlert("Find Location Failed", "No locations returned")
                    return
                }
                self.coordinate = location.coordinate
                self.showMap()
            }
        }
    }
    
    // MARK: - Bar button functions
    
    func submit() {
        OTMClient.sharedInstance.postStudentLocation(addressString, url, coordinate.latitude, coordinate.longitude) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.delegate?.refresh()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showErrorAlert("Submit Location Failed", error!)
                }
            }
        }
    }
    
    func revise() {
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = nil
        
        mapView.removeFromSuperview()
    }
    
    func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Configuration helper functions
    
    func customizeUI() {
        title = "Add Location"
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        configureUI()
        graphic.image = #imageLiteral(resourceName: "icon_world")
        topTextfield.placeholder = "Enter a location"
        bottomTextfield.placeholder = "Enter a website"
        button.setTitle("FIND LOCATION", for: .normal)
    }
    
    override func buttonAction() {
        findLocation()
    }
    
    func showMap() {
        let submitButton = UIBarButtonItem(title: "SUBMIT", style: .plain, target: self, action: #selector(submit))
        navigationItem.rightBarButtonItem = submitButton
        
        let reviseButton = UIBarButtonItem(title: "REVISE", style: .plain, target: self, action: #selector(revise))
        navigationItem.leftBarButtonItem = reviseButton
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        let attributes: [NSLayoutAttribute] = [.width, .height, .centerX, .centerY]
        for attribute in attributes {
            let constraint = NSLayoutConstraint(item: mapView, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0)
            view.addConstraint(constraint)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = url
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: false)
        
        let zoomRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 5000, 5000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
}
