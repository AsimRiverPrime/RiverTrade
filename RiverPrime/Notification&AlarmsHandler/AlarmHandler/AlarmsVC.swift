//
//  AlarmsVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/01/2025.
//

import UIKit
import WebKit

class AlarmsVC: UIViewController{
    
    @IBOutlet weak var chartView: UIView!
   
    var symbolName = String()
    var digits = Int()
    
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
        print("symbol selected : \(symbolName) , digits is: \(digits)")
        view.addSubview(webView)
       
        guard let url = Bundle.main.url(forResource: "mobile_black", withExtension: "html") else {
            print("No file at url")
            return
        }
        
        webView.loadFileURL(url, allowingReadAccessTo: url)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.updateTradingViewSymbol(symbol: "EURUSD", decimals: 5)
//        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed after cross btn click")
        })
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let origin = CGPoint(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top + 45)
        let size = CGSize(
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: view.frame.height - (view.safeAreaInsets.bottom + 25) - view.safeAreaInsets.top
        )
        
        webView.frame = CGRect(origin: origin, size: size)
    }

  
    func updateTradingViewSymbol(symbol: String, decimals: Int) {
//        let js = "window.setSymbol('\(symbol)', \(decimals));"
        let js = """
        if (typeof window.setSymbol === 'function') {
            window.setSymbol('\(symbol)', \(decimals));
        } else {
            console.log('setSymbol function is not defined yet');
        }
        """
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("Error injecting JavaScript: \(error.localizedDescription)")
            }
        }
    }
    
    
    }

extension AlarmsVC: WKNavigationDelegate, WKUIDelegate {

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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView finished loading")

        let symbol = symbolName  // Change to your dynamic symbol
        let decimals = digits     // Set correct decimal places

        let js = """
        if (typeof window.setSymbol === 'function') {
            window.setSymbol('\(symbol)', \(decimals));
            console.log('Symbol updated to: \(symbol)');
        } else {
            console.log('setSymbol function is not defined yet');
        }
        """
        
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("Error injecting JavaScript: \(error.localizedDescription)")
            }
        }
    }

    
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard let url = navigationAction.request.url else { return nil }
            let request = URLRequest.init(url: url)
            webView.load(request)
            return nil
        }
    }
