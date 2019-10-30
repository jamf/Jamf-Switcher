//
//  AppDelegate.swift
//  JSS Switcher
//
//  Copyright © 2019 dataJAR. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var showJSSMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let screenSize = NSScreen.main?.frame
        let window = NSApplication.shared.mainWindow?.windowController?.window
        
        let windowSize = CGSize(width: (window?.frame.width)!, height: (screenSize?.height)!  )
        
        window?.setFrame(NSRect(origin: (window?.frame.origin)!, size: windowSize), display: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
