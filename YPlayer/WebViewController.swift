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

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
        view.addSubview(webView)
        self.webView = webView

        let req = NSMutableURLRequest(URL: NSURL(string: "https://www.youtube.com")!)
        webView.loadRequest(req)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playPauseButtonAction), name: "KeyPlayPauseDidClick", object: nil)
    }

    @objc private func playPauseButtonAction() {
        let source = [
            "var element = document.getElementById('movie_player');",
            "if (!element.classList.contains('paused-mode')) {",
            "  element.pauseVideo();",
            "} else {",
            "  element.playVideo();",
            "}",
        ].joinWithSeparator("\n")

        webView.evaluateJavaScript(source, completionHandler: nil)
    }
}
