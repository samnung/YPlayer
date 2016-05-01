//
//  ViewController.swift
//  YPlayer iOS
//
//  Created by Roman Kříž on 01/05/16.
//  Copyright © 2016 Roman Kříž. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UIViewController {
    private weak var webView: WKWebView!

    private var controller: YouTubeWebViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView = {
            let config = WKWebViewConfiguration()
            config.allowsInlineMediaPlayback = true
            config.requiresUserActionForMediaPlayback = false
            config.allowsPictureInPictureMediaPlayback = true
            config.applicationNameForUserAgent = "ABC"

            let webView = WKWebView(frame: view.bounds, configuration: config)
            webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            view.addSubview(webView)

            return webView
        }()

        let req = NSMutableURLRequest(URL: NSURL(string: "https://www.youtube.com")!)
        webView.loadRequest(req)

        self.controller = YouTubeWebViewController(webView: self.webView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var frame = webView.frame
        frame.origin.y = self.topLayoutGuide.length
        frame.origin.x = 0
        frame.size.width = view.bounds.width
        frame.size.height = view.bounds.height - self.topLayoutGuide.length - self.bottomLayoutGuide.length
        webView.frame = frame
    }
}
