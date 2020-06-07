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

    private var selected: String?

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        defer {
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
        guard
            let urlString = event?.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let components = URLComponents(string: urlString),
            let title = components.queryItems?.first(where: { $0.name == "title" })?.value
            else {
                return
        }

        sleep(3)
        selected = title

        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("dataGetter.applicationWillTerminate"),
            object: selected,
            userInfo: nil,
            deliverImmediately: true
        )
    }

}

