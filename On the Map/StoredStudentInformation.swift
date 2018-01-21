//
//  StoredStudentInformation.swift
//  On the Map
//
//  Created by Ben Juhn on 7/19/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

class StoredStudentInformation {
    
    var students: [StudentInformation]?
    static let sharedInstance = StoredStudentInformation()
    private init() {}
    
}
