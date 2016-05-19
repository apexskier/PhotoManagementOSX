//
//  Library.swift
//  PhotoManagement
//
//  Created by Cameron Little on 12/9/14.
//  Copyright (c) 2014 Cameron Little. All rights reserved.
//

import Foundation
import CoreData

class Library: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var photos: NSSet
    @NSManaged var settings: Settings

}
