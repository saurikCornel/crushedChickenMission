import Foundation
import WebKit

class GameLoaderModel: ObservableObject {
    @Published var loadingState: HandlerLoading = .idle
    let url: URL
    private var webView: WKWebView?
    private var progressObservation: NSKeyValueObservation?
    private var currentProgress: Double = 0.0
    
    init(url: URL) {
        self.url = url
        debugPrint("WebViewModel initialized with URL: \(url)")
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
        observeProgress(webView)
        loadRequest()
        debugPrint("WebView set in WebViewModel")
    }
    
    func loadRequest() {
        guard let webView = webView else {
            debugPrint("WebView is nil, cannot load yet")
            return
        }
        
        let request = URLRequest(url: url, timeoutInterval: 15.0)
        debugPrint("Loading request for URL: \(url)")
        DispatchQueue.main.async { [weak self] in
            self?.loadingState = .loading(progress: 0.0)
            self?.currentProgress = 0.0
        }
        webView.load(request)
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
