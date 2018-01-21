//
//  LocationsTableViewController.swift
//  On the Map
//
//  Created by Ben Juhn on 7/14/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {
    
    var students = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        tableView.rowHeight = tableView.frame.height / 9
    }
    
    func refresh() {
        students = StoredStudentInformation.sharedInstance.students!
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "StudentCell")
        }
        
        let student = students[indexPath.row]
        cell?.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        cell?.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell?.detailTextLabel?.text = student.mediaURL
        
        return cell!
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        if var urlString = student.mediaURL {
            if !(urlString.lowercased().hasPrefix("http://") || urlString.lowercased().hasPrefix("https://")) {
                urlString = "http://" + urlString
            }
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
