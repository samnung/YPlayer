//
//  WebViewController.swift
//  YPlayer
//
//  Created by Roman Kříž on 31/01/16.
//  Copyright © 2016 Roman Kříž. All rights reserved.
//

import AppKit
import WebKit


class WebViewController: NSViewController {
    weak var webView: WKWebView!
    private var controller: YouTubeWebViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView = {
            let config = WKWebViewConfiguration()
            config.preferences.setValue(true, forKey: "developerExtrasEnabled")

            let webView = WKWebView(frame: view.bounds, configuration: config)
            webView.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
            view.addSubview(webView)

            return webView
        }()

        let req = NSMutableURLRequest(URL: NSURL(string: "https://www.youtube.com")!)
        webView.loadRequest(req)

        self.controller = YouTubeWebViewController(webView: self.webView)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playPauseButtonAction), name: "KeyPlayPauseDidClick", object: nil)
    }

    @objc private func playPauseButtonAction() {
        controller.playPause()
    }
}
