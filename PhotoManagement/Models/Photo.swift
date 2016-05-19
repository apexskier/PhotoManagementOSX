//
//  Photo.swift
//  PhotoManagement
//
//  Created by Cameron Little on 12/9/14.
//  Copyright (c) 2014 Cameron Little. All rights reserved.
//

import Foundation
import CoreData
import Foundation
import Quartz

enum PhotoState: Int16 {
    case New = 0
    case Known = 1
    case Modified = 2
    case Deleted = 3
    case Broken = 4
}

class Photo: NSManagedObject/*, IKImageBrowserItem*/ {

    @NSManaged var ahash: UInt64
    @NSManaged var created: NSDate
    @NSManaged var fhash: UInt64
    @NSManaged var filename: String
    @NSManaged var filepath: String
    @NSManaged var height: NSNumber
    @NSManaged var phash: UInt64
    @NSManaged var width: NSNumber
    @NSManaged var state: Int16

    var stateEnum: PhotoState {
        get {
            return PhotoState(rawValue: self.state) ?? PhotoState.New
        }
        set {
            self.state = Int16(newValue.rawValue)
        }
    }
    
    var fileURL: NSURL {
        get {
            let filemanager = NSFileManager.defaultManager()
            if !filemanager.fileExistsAtPath(self.filepath) {
                // Handle this
                println("File doesn't exist: \(self.filepath)")
                self.stateEnum = .Broken
            }
            return NSURL(fileURLWithPath: self.filepath)!
        }
    }
    
    func genPhash() {
        phash = calcPhash(self.getImage())
    }
    
    func move(newpath: String) {
        // TODO: implement
    }
    
    func updateExif() {
        // TODO: get exif info from self
    }
    
    func getImage() -> NSImage {
        return NSImage(byReferencingURL: fileURL)
    }
    
    func CGImageSource() -> CGImageSourceRef {
        return CGImageSourceCreateWithURL(fileURL, nil)
    }
    
    func readData() {
        let imageSource = CGImageSourceCreateWithURL(fileURL, nil)
        
        var index: UInt = 0
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NSDictionary())
        
        if imageProperties != nil {
            var dictionary = imageProperties as NSDictionary
            
            height = dictionary.objectForKey("PixelHeight") as NSNumber!
            width = dictionary.objectForKey("PixelWidth") as NSNumber!
            
            var exifTree = dictionary.objectForKey("{Exif}") as [String: NSObject]?
            if let eT = exifTree {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                
                if let exifDateTimeOriginal = eT["DateTimeOriginal"] {
                    created = dateFormatter.dateFromString(exifDateTimeOriginal as String) as NSDate!
                }
                
                for (key, value) in eT {
                    println(key)
                }
            }
        } else {
            stateEnum = .Broken
        }
    }
    
    func setPath(path: String) {
        if filepath != path {
            filepath = path
        }
    }
    
    override func imageRepresentationType() -> String {
        return IKImageBrowserPathRepresentationType
    }
    
    override func imageRepresentation() -> AnyObject {
        return filepath
    }
    
    override func imageUID() -> String {
        return filepath
    }
    
}
