/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, and for convenience the managed object model and URL for the persistent store and application documents directory.

*/

import Cocoa

class CoreDataStackManager {
    
    
    
    // MARK: - Core Data stack
    /*
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.camlittle.PhotoManagement" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        return appSupportURL.URLByAppendingPathComponent("com.camlittle.PhotoManagement")
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("PhotoManagement", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = NSFileManager.defaultManager()
        var shouldFail = false
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if !shouldFail && (error == nil) {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("PhotoManagement.storedata")
            if coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                coordinator = nil
            }
        }
        
        if shouldFail || (error != nil) {
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if error != nil {
                dict[NSUnderlyingErrorKey] = error
            }
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error!)
            return nil
        } else {
            return coordinator
        }
        }()*/

    
    
    
    
    
    
    // MARK: Types
    
    private struct Constants {
        static let applicationDocumentsDirectoryName = NSBundle.mainBundle().bundleIdentifier!
        static let mainStoreFileName = "PhotoManagement.storedata"
        static let errorDomain = "CoreDataStackManager"
    }
    
    // MARK: Properties
    
    class var sharedManager: CoreDataStackManager {
        struct Singleton {
            static let coreDataStackManager = CoreDataStackManager()
        }
        
        return Singleton.coreDataStackManager
    }
    
    /// The managed object model for the application.
    lazy var managedObjectModel: NSManagedObjectModel = {
        // This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("PhotoManagement", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    /// Primary persistent store coordinator for the application.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
        if let url = self.storeURL {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            
            var error: NSError?
            
            let persistentStore = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error)
            if persistentStore == nil {
                println("Error adding persistent store: \(error)")
                fatalError("Could not add the persistent store.")
                
                NSApplication.sharedApplication().presentError(error!)
                
                return nil
            }
            
            return persistentStoreCoordinator
        }
        
        return nil
        }()
    
    /// The directory the application uses to store the Core Data store file.
    lazy var applicationDocumentsDirectory: NSURL? = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        var applicationSupportDirectory = urls[urls.count - 1] as NSURL
        applicationSupportDirectory = applicationSupportDirectory.URLByAppendingPathComponent(Constants.applicationDocumentsDirectoryName)
        
        var error: NSError?
        
        if let properties = applicationSupportDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error) {
            if let isDirectory = properties[NSURLIsDirectoryKey] as? NSNumber {
                if !isDirectory.boolValue {
                    
                    let description = NSLocalizedString("Could not access the application data folder.", comment: "Failed to initialize applicationSupportDirectory")
                    
                    let reason = NSLocalizedString("Found a file in its place.", comment: "Failed to initialize applicationSupportDirectory")
                    
                    let userInfo = [
                        NSLocalizedDescriptionKey: description,
                        NSLocalizedFailureReasonErrorKey: reason
                    ]
                    
                    error = NSError(domain: Constants.errorDomain, code: 101, userInfo: userInfo)
                    
                    fatalError("Could not access the application data folder.")
                    
                    NSApplication.sharedApplication().presentError(error!)
                    
                    return nil
                }
            }
        }
        else {
            if error != nil && error!.code == NSFileReadNoSuchFileError {
                let ok = fileManager.createDirectoryAtPath(applicationSupportDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
                if !ok {
                    NSApplication.sharedApplication().presentError(error!)
                    
                    fatalError("Could not create the application data folder.")
                    
                    return nil
                }
            }
        }
        
        return applicationSupportDirectory
        }()
    
    /// URL for the main Core Data store file.
    lazy var storeURL: NSURL? = {
        if let add = self.applicationDocumentsDirectory {
            return add.URLByAppendingPathComponent(Constants.mainStoreFileName)
        }
        
        return nil
        }()
}
