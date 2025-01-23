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
    var selectedSymbol: String! // Pass the symbol here from the table view

      override func viewDidLoad() {
          super.viewDidLoad()

          // Initialize and configure the WebView
          webView = WKWebView(frame: self.view.bounds)
          self.view.addSubview(webView)

          // Load the HTML file and pass the selected symbol
          if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
              let url = URL(fileURLWithPath: htmlPath)

              // Replace the placeholder symbol with the actual symbol
              let symbolHTML = try? String(contentsOf: url).replacingOccurrences(of: "SYMBOL_PLACEHOLDER", with: "Gold")

              // Load the modified HTML into the WebView
              webView.loadHTMLString(symbolHTML ?? "", baseURL: url.deletingLastPathComponent())
          }
      }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let origin = CGPoint(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top)
        let size = CGSize(
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
        )
        
        webView.frame = CGRect(origin: origin, size: size)
    }
}

    extension AlarmsVC: WKNavigationDelegate {
       
      func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
          if let url = navigationAction.request.url,
             let host = url.host, host.hasPrefix("www.tradingview.com"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
          } else {
            decisionHandler(.allow)
            return
          }
        } else {
          decisionHandler(.cancel)
          return
        }
      }
       
    }

    extension AlarmsVC: WKUIDelegate {
        
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard let url = navigationAction.request.url else { return nil }
            let request = URLRequest.init(url: url)
            webView.load(request)
            return nil
        }
        
    }
