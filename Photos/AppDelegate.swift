//
//  AppDelegate.swift
//  Photos
//
//  Created by Cameron Little on 11/22/14.
//  Copyright (c) 2014 Cameron Little. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        var testPhoto = Photo(path: "~/Downloads/testoutput.png")
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

