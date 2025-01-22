//
//  AlarmsVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/01/2025.
//

import UIKit
import WebKit

class AlarmsVC: UIViewController {
   
        var webView: WKWebView!
        var selectedSymbol: String = "NASDAQ:AAPL" // Default symbol
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set the background color
            view.backgroundColor = .black
            
            // Set up WebView
            setupWebView()
            
            // Load the TradingView chart
            loadTradingViewChart(symbol: selectedSymbol)
            // Add a close button
               let closeButton = UIButton(type: .system)
            closeButton.setTitle("X", for: .normal)
            closeButton.tintColor = .white
               closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
               closeButton.frame = CGRect(x: 5, y: 10, width: 80, height: 40) // Adjust as needed
               self.view.addSubview(closeButton)
    }

           @objc private func closeTapped() {
               self.dismiss(animated: true, completion: nil)
           }
    
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            // Ensure WebView adjusts to orientation changes
            webView.frame = self.view.bounds
        }
        
        private func setupWebView() {
            // Initialize WKWebView
            webView = WKWebView()
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.backgroundColor = .black
            self.view.addSubview(webView)
            
            // Constrain WebView to the edges of the view
            NSLayoutConstraint.activate([
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -20),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        private func loadTradingViewChart(symbol: String) {
            // TradingView widget HTML/JavaScript
            let tradingViewHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
                <style>
                    html, body {
                        margin: 0;
                        padding: 0;
                        height: 100%;
                        width: 100%;
                        background-color: black; /* Ensure full-screen dark background */
                        overflow: hidden;
                    }
                    #tradingview_chart {
                        height: 100%;
                        width: 100%;
                    }
                </style>
            </head>
            <body>
                <div id="tradingview_chart"></div>
                <script type="text/javascript">
                    new TradingView.widget({
                        "container_id": "tradingview_chart",
                        "symbol": "\(symbol)", // Dynamic symbol
                        "interval": "D", // Timeframe
                        "theme": "dark", // Use dark theme for better visuals
                        "style": "1", // Line chart
                        "locale": "en",
                        "autosize": true, // Enable auto size
                        "hide_side_toolbar": false,
                        "details": false,
                        "allow_symbol_change": true
                    });
                </script>
            </body>
            </html>
            """
            
            // Load HTML in WebView
            webView.loadHTMLString(tradingViewHTML, baseURL: nil)
        }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return .landscape
       }
       
       override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
           return .landscapeRight
       }
       
       override var shouldAutorotate: Bool {
           return true
       }
    
    }

    
