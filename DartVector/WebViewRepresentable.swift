import SwiftUI
import WebKit

struct WebViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let schemeHandler = AppSchemeHandler()
        let bridgeHandler = BridgeHandler()

        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: "app")
        configuration.userContentController.add(bridgeHandler, name: BridgeHandler.messageName)

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        if let url = URL(string: "app://dartvector/index.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
