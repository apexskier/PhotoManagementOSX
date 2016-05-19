//
//  Settings.swift
//  PhotoManagement
//
//  Created by Cameron Little on 12/9/14.
//  Copyright (c) 2014 Cameron Little. All rights reserved.
//

import Foundation
import CoreData

class Settings: NSManagedObject {

    @NSManaged var output: Folder?
    @NSManaged var imports: NSMutableOrderedSet
    
}
