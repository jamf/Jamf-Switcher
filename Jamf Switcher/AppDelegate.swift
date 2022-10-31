//
//  AppDelegate.swift
//  Jamf Switcher
//
//  Copyright © 2020 dataJAR. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SPUStandardUserDriverDelegate, SPUUpdaterDelegate {

    @IBOutlet weak var showJSSMenuItem: NSMenuItem!
    @IBOutlet weak var exportJSSItem: NSMenuItem!
    @IBOutlet weak var findPolicyJSSItem: NSMenuItem!
    @IBOutlet weak var flushPolicyJSSItem: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("HERE1")
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        print("HERE2")
        let screenSize = NSScreen.main?.frame
        if let window = NSApplication.shared.mainWindow {
            let windowSize = CGSize(width: (window.frame.width), height: (screenSize?.height)!  )
            window.setFrame(NSRect(origin: (window.frame.origin), size: windowSize), display: true)
        }
        print("HERE3")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        return Set(["beta"])
    }
}
