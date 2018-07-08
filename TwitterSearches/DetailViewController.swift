//
//  DetailViewController.swift
//  TwitterSearches
//
//  Created by David Hincapie on 11/10/15.
//  Copyright © 2015 David Hincapie. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView! // displays search results
    var detailItem: NSURL? // URL that will be displayed
    
    // configure DetailViewController as the webView's delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
    }
    
    // after view appears, load search results into webview
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = self.detailItem {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    // stop page load and hide network activity indicator when
    // returning to MasterViewController
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication()
            . networkActivityIndicatorVisible = false
        webView.stopLoading()
    }
    
    // when loading starts, show network activity indicator
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication()
            . networkActivityIndicatorVisible = true
    }
    
    // hide network activity indicator when page finishes loading
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication()
            . networkActivityIndicatorVisible = false
    }
    
    // display static web page if error occurs
    func webView(webView: UIWebView,
        didFailLoadWithError error: NSError?) {
            webView.loadHTMLString(
                "<html><body><p>An error occurred when performing " +
                    "the Twitter search: " + error!.description +
                "</body></html>", baseURL: nil)
    }
}

