import Foundation
import SwiftUI
import WebKit

struct GameHolder: UIViewRepresentable {
    @ObservedObject var viewModel: GameLoaderModel
    
    func makeUIView(context: Context) -> WKWebView {
        debugPrint("Creating WKWebView with URL: \(viewModel.url)")
        
        let configuration = WKWebViewConfiguration()
        
        // КРИТИЧЕСКИ ВАЖНО: Настройки для сохранения куки
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = WKProcessPool()
        
        // Настройки для медиа
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Настройки JavaScript
        if #available(iOS 14.0, *) {
            let pagePrefs = WKWebpagePreferences()
            pagePrefs.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = pagePrefs
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // Дополнительные настройки для сохранения состояния
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        
        debugPrint("viewModel.url = \(viewModel.url)")
        webView.load(URLRequest(url: viewModel.url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        debugPrint("Updating WKWebView, current URL: \(uiView.url?.absoluteString ?? "none")")
    }
    
    func makeCoordinator() -> Coordinator {
        debugPrint("Coordinator created")
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: GameHolder
        private var isRedirecting = false
        
        init(_ parent: GameHolder) {
            self.parent = parent
            debugPrint("Coordinator initialized")
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            debugPrint("Navigation started for URL: \(webView.url?.absoluteString ?? "unknown")")
            if !isRedirecting {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.viewModel.loadingState = .loading(progress: 0.0)
                }
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            debugPrint("Content started loading, progress: \(Int(webView.estimatedProgress * 100))%")
            isRedirecting = false
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            debugPrint("Navigation finished for URL: \(webView.url?.absoluteString ?? "unknown")")
            DispatchQueue.main.async { [weak self] in
                self?.parent.viewModel.loadingState = .loaded
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            debugPrint("Navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.parent.viewModel.loadingState = .failed(error)
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            debugPrint("Provisional navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.parent.viewModel.loadingState = .failed(error)
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .other, webView.url != nil {
                debugPrint("Redirect detected to: \(navigationAction.request.url?.absoluteString ?? "unknown")")
                isRedirecting = true
            }
            decisionHandler(.allow)
        }
    }
}
