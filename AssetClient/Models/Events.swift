//
//  Events.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 05/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Foundation
class Events{
    var id: Int
    var name: String
    var startDate: String
    var endDate: String
    var notes: String
    var type: String
    var projectManager: String
    var projectManagerID: Int
    
    init(id:Int, name: String, type: String, startDate: String, endDate: String, projectManager: String, notes: String, projectManagerID: Int) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.projectManager = projectManager
        self.type = type
        self.projectManagerID = projectManagerID
    }
}
