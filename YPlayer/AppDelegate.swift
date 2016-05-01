//
//  AppDelegate.swift
//  YPlayer
//
//  Created by Roman Kříž on 01/05/16.
//  Copyright © 2016 Roman Kříž. All rights reserved.
//

import Foundation
import AppKit
import MediaKeyTap


@NSApplicationMain
class AppDelegate: NSObject {
    var keyTap: MediaKeyTap!
}


extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(notification: NSNotification) {

        // enable developer extras in webview
        NSUserDefaults.standardUserDefaults().registerDefaults([
            "WebKitDeveloperExtras": true,
        ])

        keyTap = MediaKeyTap(delegate: self)
        keyTap.start()

    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return false
    }
}


extension AppDelegate: MediaKeyTapDelegate {
    func handleMediaKey(mediaKey: MediaKey, event: KeyEvent) {
        switch mediaKey {
        case .PlayPause:
            NSNotificationCenter.defaultCenter().postNotificationName("KeyPlayPauseDidClick", object: self)

        default:
            break
        }
    }
}
