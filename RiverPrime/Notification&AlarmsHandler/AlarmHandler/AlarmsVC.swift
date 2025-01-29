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
            
            // Initialize the WebView
            webView = WKWebView(frame: self.view.bounds)
            webView.navigationDelegate = self
            self.view.addSubview(webView)
            
            // Load the local JavaScript project
        if let url = Bundle.main.url(forResource: "mobile_black", withExtension: "html", subdirectory: "charting_library-master") {
            print("HTML file found at: \(url.absoluteString)")
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("Failed to load mobile_black the HTML file.")
        }
        
        if let path = Bundle.main.path(forResource: "mobile_black", ofType: "html", inDirectory: "charting_library-master") {
            print("HTML path exists: \(path)")
        } else {
            print("HTML file is missing.")
        }
        
        callJavaScriptFunction()
        }
        
        // Example JavaScript interactiongv
        func callJavaScriptFunction() {
            let jsCode = "alert('Hello from Swift!')"
            webView.evaluateJavaScript(jsCode) { (result, error) in
                if let error = error {
                    print("JavaScript execution failed: \(error)")
                } else {
                    print("JavaScript executed successfully: \(String(describing: result))")
                }
            }
        }
    
}

extension AlarmsVC: WKScriptMessageHandler {
    func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "messageHandler")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: self.view.bounds, configuration: config)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "messageHandler", let body = message.body as? String {
            print("Received message from JavaScript: \(body)")
        }
    }
}
