//
//  AlarmsVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/01/2025.
//

import UIKit
import WebKit

class AlarmsVC: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var selectedSymbol: String! // Pass the symbol here from the table view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure WebView with JavaScript enabled
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        
        if let htmlPath = Bundle.main.path(forResource: "mobile_black", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }

//        // Load the HTML file and pass the selected symbol
//        if let htmlPath = Bundle.main.path(forResource: "mobile_black", ofType: "html") {
//            let url = URL(fileURLWithPath: htmlPath)
//            do {
//                var symbolHTML = try String(contentsOf: url)
//                symbolHTML = symbolHTML.replacingOccurrences(of: "SYMBOL_PLACEHOLDER", with: selectedSymbol ?? "Gold")
//                print("HTML content after replacement: \(symbolHTML)")
//                webView.loadHTMLString(symbolHTML, baseURL: url.deletingLastPathComponent())
//            } catch {
//                print("Error loading HTML file: \(error.localizedDescription)")
//            }
//        } else {
//            print("mobile_black.html not found in bundle.")
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = self.view.bounds
    }
    
    // Debugging errors
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView navigation failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView failed to load: \(error.localizedDescription)")
    }
}
