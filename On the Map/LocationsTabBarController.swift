//
//  LocationsTabBarController.swift
//  On the Map
//
//  Created by Ben Juhn on 7/13/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

class LocationsTabBarController: UITabBarController, PostingDelegate {
    
    let mapView = LocationsMapViewController()
    let tableView = LocationsTableViewController()
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTabBar()
        refresh()
    }
    
    func logout() {
        OTMClient.sharedInstance.logout()
        dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        OTMClient.sharedInstance.updateRecentStudentLocations() { (success, error) in
            self.activityIndicator.stopAnimating()
            if success {
                DispatchQueue.main.async {
                    self.mapView.refresh()
                    self.tableView.refresh()
                }
            } else {
                let errorAlert = UIAlertController(title: "Refresh Student Locations Failed", message: error, preferredStyle: .alert)
                let closeAlert = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlert.addAction(closeAlert)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    func postInformation() {
        //TODO: Check if student has previous info posted (update OTMConvenience)
        //      if yes, show alert to confirm before pushing posting view controller
        let postingView = PostingViewController()
        postingView.delegate = self
        navigationController?.pushViewController(postingView, animated: true)
    }
    
    func configureNavBar() {
        title = "On The Map"
        let logoutButton = UIBarButtonItem(title: "LOGOUT", style: .plain, target: self, action: #selector(logout))
        let refreshButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_refresh"), style: .plain, target: self, action: #selector(refresh))
        let postButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_addpin"), style: .plain, target: self, action: #selector(postInformation))
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItems = [postButton, refreshButton]
    }
    
    func configureTabBar() {
        mapView.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "icon_mapview-deselected"), tag: 0)
        tableView.tabBarItem = UITabBarItem(title: "List", image: #imageLiteral(resourceName: "icon_listview-deselected"), tag: 1)
        viewControllers = [mapView, tableView]
    }
    
    func configureActivityIndicator() {
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
    
}
