//
//  LocationsMapViewController.swift
//  On the Map
//
//  Created by Ben Juhn on 7/14/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit
import MapKit

class LocationsMapViewController: UIViewController, MKMapViewDelegate {

    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        let attributes: [NSLayoutAttribute] = [.width, .height, .centerX, .centerY]
        for attribute in attributes {
            let constraint = NSLayoutConstraint(item: mapView, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    func refresh() {
        loadPins()
    }
    
    func loadPins() {
        mapView.removeAnnotations(mapView.annotations)
        
        let students = StoredStudentInformation.sharedInstance.students!
        for student in students {
            if let lat = student.latitude, let long = student.longitude {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                annotation.title = "\(student.firstName) \(student.lastName)"
                annotation.subtitle = student.mediaURL
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "StudentPin")
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "StudentPin")
        }
        
        pin?.canShowCallout = true
        pin?.rightCalloutAccessoryView = UIButton()
        pin?.annotation = annotation
        return pin
    }
    
    // MARK: - Map view delegate
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if var urlString = view.annotation?.subtitle! {
                if !(urlString.lowercased().hasPrefix("http://") || urlString.lowercased().hasPrefix("https://")) {
                    urlString = "http://" + urlString
                }
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
}
