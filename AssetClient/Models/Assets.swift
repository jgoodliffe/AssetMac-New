//
//  Assets.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 04/04/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Foundation
class Assets{
    var id: Int
    var name: String
    var quantity: Int
    var value: Int
    var dateAdded: String
    var inspectionDue: String
    var category: String
    var subCategory: String
    
    init(id:Int, name: String, quantity: Int, value: Int, dateAdded: String, inspectionDue: String, category: String, subCategory: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.value = value
        self.dateAdded = dateAdded
        self.inspectionDue = inspectionDue
        self.category = category
        self.subCategory = subCategory
    }
}
