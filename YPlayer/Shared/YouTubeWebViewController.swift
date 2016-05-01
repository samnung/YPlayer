//
//  YouTubeWebViewController.swift
//  YPlayer
//
//  Created by Roman Kříž on 01/05/16.
//  Copyright © 2016 Roman Kříž. All rights reserved.
//

import Foundation
import WebKit


class YouTubeWebViewController {

    private(set) var webView: WKWebView

    init(webView: WKWebView) {
        self.webView = webView
    }

    func playPause(completion: (() -> ())? = nil) {
        let source = [
            "var element = document.getElementById('movie_player');",
            "if (!element.classList.contains('paused-mode')) {",
            "  element.pauseVideo();",
            "} else {",
            "  element.playVideo();",
            "}",
        ].joinWithSeparator("\n")

        webView.evaluateJavaScript(source, completionHandler: { result, error in
            completion?()
        })
    }
}
