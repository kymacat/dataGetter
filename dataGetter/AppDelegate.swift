//
//  AppDelegate.swift
//  dataGetter
//
//  Created by Const. on 07.05.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ aNotification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleGetURLEvent(event:replyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    private var json: String?

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        
        guard
            let urlString = event?.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let components = URLComponents(string: urlString),
            let json = components.queryItems?.first(where: { $0.name == "json" })?.value
            else {
                return
        }

        self.json = json

        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("dataGetter.applicationWillTerminate"),
            object: "cancel",
            userInfo: nil,
            deliverImmediately: true
        )
    }
    
    private var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSApplication.shared.orderedWindows.first
        window?.title = "Data getter"
        
        if let json = json {
            let controller = ValuesViewController(json: json)
            window?.contentViewController = controller
            window?.minSize = NSSize(width: 700, height: 270)
        } else {
            let controller = EnableViewController()
            window?.contentViewController = controller
            window?.styleMask.remove(.resizable)
        }
    
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
