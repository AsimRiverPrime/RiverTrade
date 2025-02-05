//
//  AlarmsVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/01/2025.
//

import UIKit
import WebKit

class AlarmsVC: UIViewController{
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.preferences.isElementFullscreenEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isInspectable = true
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
       
        guard let url = Bundle.main.url(forResource: "mobile_black", withExtension: "html") else {
            print("No file at url")
            return
        }
        
        webView.loadFileURL(url, allowingReadAccessTo: url)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateTradingViewSymbol(symbol: "AAPL")
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

    func sendStringToWebView() {
           let script = "receiveDataFromSwift('AAPL');"
           webView.evaluateJavaScript(script, completionHandler: nil)
       }
    func updateTradingViewSymbol(symbol: String) {
        let js = "window.setSymbol('\(symbol)');"
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("Error injecting JavaScript: \(error.localizedDescription)")
            }
        }
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

