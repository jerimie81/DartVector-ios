import Foundation
import WebKit

final class AppSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let requestURL = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(NSError(domain: "AppSchemeHandler", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing request URL"]))
            return
        }

        let safePath = requestURL.path == "/" || requestURL.path.isEmpty ? "/index.html" : requestURL.path
        let fileName = safePath.hasPrefix("/") ? String(safePath.dropFirst()) : safePath
        let assetRoot = Bundle.main.bundleURL.appendingPathComponent("WebAssets", isDirectory: true)
        let candidatePaths = [
            assetRoot.appendingPathComponent(fileName),
            assetRoot.appendingPathComponent("index.html")
        ]

        guard let assetURL = candidatePaths.first(where: { FileManager.default.fileExists(atPath: $0.path) }),
              let data = try? Data(contentsOf: assetURL) else {
            urlSchemeTask.didFailWithError(NSError(domain: "AppSchemeHandler", code: 404, userInfo: [NSLocalizedDescriptionKey: "Asset not found"]))
            return
        }

        let mimeType = Self.mimeType(for: assetURL.path)
        let response = URLResponse(
            url: requestURL,
            mimeType: mimeType,
            expectedContentLength: data.count,
            textEncodingName: "utf-8"
        )

        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}

    private static func mimeType(for filePath: String) -> String {
        if filePath.hasSuffix(".html") { return "text/html" }
        if filePath.hasSuffix(".js") { return "text/javascript" }
        if filePath.hasSuffix(".css") { return "text/css" }
        if filePath.hasSuffix(".json") { return "application/json" }
        if filePath.hasSuffix(".png") { return "image/png" }
        if filePath.hasSuffix(".svg") { return "image/svg+xml" }
        if filePath.hasSuffix(".ico") { return "image/x-icon" }
        return "application/octet-stream"
    }
}
