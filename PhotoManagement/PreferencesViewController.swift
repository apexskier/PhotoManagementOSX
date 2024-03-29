//
//  PreferencesViewController.swift
//  SwiftPhotos
//
//  Created by Cameron Little on 12/5/14.
//  Copyright (c) 2014 Cameron Little. All rights reserved.
//

import Foundation

import Cocoa

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}

class PreferencesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //@IBOutlet weak var appDelegate: AppDelegate!
    
    var settings: Settings {
        get {
            var settings: Settings
            var anyError: NSError?
            
            let request = NSFetchRequest(entityName: "Settings")
            let fetchedSources = self.managedObjectContext.executeFetchRequest(request, error: &anyError)
            if let sources = fetchedSources {
                if sources.count == 0 {
                    settings = NSEntityDescription.insertNewObjectForEntityForName("Settings", inManagedObjectContext: self.managedObjectContext) as Settings
                    let newFolder = NSEntityDescription.insertNewObjectForEntityForName("Folder", inManagedObjectContext: self.managedObjectContext) as Folder
                    newFolder.path = ""
                    settings.output = newFolder
                    
                    if !self.managedObjectContext.save(&anyError) {
                        println("Error saving batch: \(anyError)")
                        fatalError("Saving batch failed.")
                    }
                } else {
                    settings = sources[sources.count - 1] as Settings
                }
            } else {
                println("Error fetching: \(anyError)")
                fatalError("Fetch failed.")
            }
            return settings
        }
    }
    
    @IBOutlet weak var outputTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var removeImportButton: NSButton!
    
    /// Managed object context for the view controller (which is bound to the persistent store coordinator for the application).
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = CoreDataStackManager.sharedManager.persistentStoreCoordinator
        return moc
    }()
    
    @IBAction func chooseOutputFolder(sender: AnyObject) {
        var filePicker = NSOpenPanel()
        filePicker.canChooseDirectories = true
        filePicker.canChooseFiles = false
        filePicker.allowsMultipleSelection = false
        
        var result = filePicker.runModal()
        
        if result == NSOKButton {
            var outputPath = filePicker.URL!
            
            var folder: Folder = NSEntityDescription.insertNewObjectForEntityForName("Folder", inManagedObjectContext: managedObjectContext) as Folder
            folder.path = outputPath.relativePath!
            settings.output = folder
            
            var anyError: NSError?
            if !managedObjectContext.save(&anyError) {
                println("Error saving batch: \(anyError)")
                fatalError("Saving batch failed.")
                return
            }
            
            reloadTableView(self)
            
            filePicker.close()
        }
    }
    
    @IBAction func addImportSourceClick(sender: AnyObject) {
        var filePicker = NSOpenPanel()
        filePicker.canChooseDirectories = true
        filePicker.canChooseFiles = false
        filePicker.allowsMultipleSelection = true
        
        var result = filePicker.runModal()
        
        if result == NSOKButton {
            var anyError: NSError?
            
            for url in filePicker.URLs as [NSURL] {
                var folder: Folder = NSEntityDescription.insertNewObjectForEntityForName("Folder", inManagedObjectContext: managedObjectContext) as Folder
                folder.path = url.absoluteString!
                println(settings.imports.count)
                settings.imports.addObject(folder)
                println(settings.imports.count)
                
                if !managedObjectContext.save(&anyError) {
                    println("Error saving batch: \(anyError)")
                    fatalError("Saving batch failed.")
                    return
                }
                managedObjectContext.reset()
            }
            
            reloadTableView(nil)
            
            filePicker.close()
        }
    }
    
    @IBAction func removeImportSourceClick(sender: AnyObject) {
        var idxs = tableView.selectedRowIndexes
        
        idxs.enumerateRangesWithOptions(NSEnumerationOptions.Reverse, { (range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
            let location = range.location
            let length = range.length
            for var i = (location + length - 1); i >= location; i-- {
                if i != -1 {
                    self.managedObjectContext.deleteObject(self.settings.imports.objectAtIndex(i) as NSManagedObject)
                }
            }
        })
        
        var anyError: NSError?
        if !managedObjectContext.save(&anyError) {
            println("Error saving batch: \(anyError)")
            fatalError("Saving batch failed.")
            return
        }
        managedObjectContext.reset()
        
        reloadTableView(self)
    }
    // Delete row on backspace.
    override func keyDown(theEvent: NSEvent) {
        if let keys = theEvent.charactersIgnoringModifiers {
            var delete = Character(UnicodeScalar(NSDeleteCharacter))
            var key: Character = Array(keys)[0]
            if key == Character(UnicodeScalar(NSDeleteCharacter)) {
                self.removeImportSourceClick(self)
            }
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Uncomment to remove settings.
        var anyError: NSError?
        let request = NSFetchRequest(entityName: "Settings")
        let fetchedSources = self.managedObjectContext.executeFetchRequest(request, error: &anyError)
        if let sources = fetchedSources {
            for settings in sources {
                self.managedObjectContext.deleteObject(settings as NSManagedObject)
            }
        } else {
            println("Error fetching: \(anyError)")
            fatalError("Fetch failed.")
        }
        if !managedObjectContext.save(&anyError) {
            println("Error saving batch: \(anyError)")
            fatalError("Saving batch failed.")
            return
        }*/
        
        tableView.setDataSource(self)
        reloadTableView(self)
    }
    
    /// Fetch Folders in settings object and display.
    private func reloadTableView(sender: AnyObject?) {
        // TODO: reload settings object ?
        
        if let output = settings.output {
            self.outputTextField.stringValue = output.path
        }
        
        tableView.reloadData()
    }
    
    // MARK: NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if settings.imports.count <= 0 {
            removeImportButton.enabled = false
        } else {
            removeImportButton.enabled = true
        }
        return settings.imports.count
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let relativePath = NSURL(string: settings.imports.objectAtIndex(row).path)?.relativeString
        return NSString(string: relativePath!).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    }
}

// Creates a new Core Data stack and returns a managed object context associated with a private queue.
private func privateQueueContext(outError: NSErrorPointer) -> NSManagedObjectContext! {
    // It uses the same store and model, but a new persistent store coordinator and context.
    let localCoordinator = NSPersistentStoreCoordinator(managedObjectModel: CoreDataStackManager.sharedManager.managedObjectModel)
    var error: NSError?
    
    let persistentStore = localCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: CoreDataStackManager.sharedManager.storeURL, options: nil, error: &error)
    if persistentStore == nil {
        if outError != nil {
            outError.memory = error
        }
        return nil
    }
    
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.persistentStoreCoordinator = localCoordinator
    context.undoManager = nil
    
    return context
}