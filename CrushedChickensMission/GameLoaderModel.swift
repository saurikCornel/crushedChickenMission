import Foundation
import WebKit
import SwiftUI

class GameLoaderModel: ObservableObject {
    @Published var loadingState: HandlerLoading = .idle
    let url: URL
    let webView: WKWebView
    private var progressObservation: NSKeyValueObservation?
    private var currentProgress: Double = 0.0
    
    init(url: URL) {
        self.url = url
        
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
        
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Дополнительные настройки для сохранения состояния
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        
        observeProgress(webView)
        debugPrint("WebViewModel initialized with URL: \(url)")
    }
    
    func loadRequest() {
        guard url.scheme == "https" || url.scheme == "http" else {
            debugPrint("Invalid URL scheme: \(url)")
            DispatchQueue.main.async { [weak self] in
                self?.loadingState = .idle
            }
            return
        }
        let request = URLRequest(url: url, timeoutInterval: 15.0)
        debugPrint("Loading request for URL: \(url)")
        DispatchQueue.main.async { [weak self] in
            self?.loadingState = .loading(progress: 0.0)
            self?.currentProgress = 0.0
            debugPrint("[GameLoaderModel] Attempting to load. webView is nil?", false)
            debugPrint("[GameLoaderModel] webView pointer:", String(describing: self?.webView))
            debugPrint("[GameLoaderModel] Request URL:", request.url?.absoluteString ?? "nil")
            self?.webView.load(request)
        }
    }
    
    private func observeProgress(_ webView: WKWebView) {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            let progress = webView.estimatedProgress
            debugPrint("Progress updated: \(Int(progress * 100))%")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if progress > self.currentProgress {
                    self.currentProgress = progress
                    self.loadingState = .loading(progress: self.currentProgress)
                }
                if progress >= 1.0 {
                    self.loadingState = .loaded
                }
            }
        }
    }
    
    func updateNetworkStatus(_ isConnected: Bool) {
        if isConnected && loadingState == .noInternet {
            loadRequest()
        } else if !isConnected {
            DispatchQueue.main.async { [weak self] in
                self?.loadingState = .noInternet
            }
        }
    }
}
