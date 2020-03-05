//
//  Events.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 05/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Foundation
struct Events{
    var id: Int
    var name: String
    var startDate: String
    var endDate: String
    var notes: String
    
    init(id:Int, name: String, startDate: String, endDate: String, notes: String) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
}
