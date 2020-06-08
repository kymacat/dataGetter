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

    private var content: String?

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        
        guard
            let urlString = event?.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let components = URLComponents(string: urlString),
            let title = components.queryItems?.first(where: { $0.name == "title" })?.value
            else {
                return
        }

        content = title

        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("dataGetter.applicationWillTerminate"),
            object: content,
            userInfo: nil,
            deliverImmediately: true
        )
    }
    
    private var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSApplication.shared.orderedWindows.first
        window?.title = "Data getter"
        
        if let content = content {
            let controller = ValuesViewController(content: content)
            window?.contentViewController = controller
        } else {
            NSApplication.shared.terminate(nil)
        }
    
        
    }

}
