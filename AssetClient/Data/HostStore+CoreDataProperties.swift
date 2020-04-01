//
//  HostStore+CoreDataProperties.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 01/04/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//
//

import Foundation
import CoreData


extension HostStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HostStore> {
        return NSFetchRequest<HostStore>(entityName: "HostStore")
    }

    @NSManaged public var hostname: String?

}
