//
//  AuthStore+CoreDataProperties.swift
//  AssetClient
//
//  Created by Jamie Goodliffe on 09/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//
//

import Foundation
import CoreData


extension AuthStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthStore> {
        return NSFetchRequest<AuthStore>(entityName: "AuthStore")
    }

    @NSManaged public var userLevel: String?
    @NSManaged public var token: String?
    @NSManaged public var username: String?
    @NSManaged public var host: String?
    @NSManaged public var date: NSDate?

}
