# DartVector-iOS: Complete Guide to Building iOS Apps on a Linux PC

This guide provides a comprehensive, step-by-step blueprint for building, testing, and deploying the **DartVector iOS native client** directly from a **Linux development environment**.

---

## 🎯 Architecture Overview

DartVector-iOS mirrors the architecture of [Dartvector-android](https://github.com/jerimie81/Dartvector-android):

- **UI Shell**: Native SwiftUI view wrapping `WKWebView`.
- **Asset Bundle**: Next.js static export (`out/`) bundled into the iOS app resources.
- **Custom Scheme Handler**: `WKURLSchemeHandler` (`app://dartvector`) serving local web assets to eliminate `file://` CORS/IndexedDB restrictions.
- **Native Bridges**: `WKScriptMessageHandler` providing native iOS capabilities (e.g., `SFSpeechRecognizer` for voice dart commands).
- **Linux Workflow**: Local development in VS Code + automated cloud compilation via **GitHub Actions** (`macos-latest`).

---

## 📋 Comprehensive Implementation Checklist

### Phase 1: Linux Environment Setup & Tools

- [ ] **1.1 Install VS Code Swift Extension**
  - Install the official **Swift** extension (`sswg.swift`) in VS Code for LSP completion, syntax highlighting, and formatting.
  - Manual editor step: this requires the VS Code UI on a local desktop session because the headless CLI is not available in this Linux environment.
- [x] **1.2 Verify GitHub CLI (`gh`)**
  - Confirmed `gh` is installed and authenticated to push code and trigger GitHub Actions builds.
- [x] **1.3 Configure Next.js Web Asset Sync Script**
  - Created `scripts/sync-web.sh` to copy the Next.js `out/` build into the iOS bundle folder.

---

### Phase 2: iOS Project Structure & Swift WKWebView Shell

- [x] **2.1 Swift Application Entry Point**
  - Created `DartVector/DartVectorApp.swift` as the main SwiftUI app entry point.
- [x] **2.2 WKWebView Wrapper (`WebViewRepresentable.swift`)**
  - Added `DartVector/WebViewRepresentable.swift` with the `UIViewRepresentable` wrapper and custom config.
- [x] **2.3 Local Asset Scheme Handler (`AppSchemeHandler.swift`)**
  - Implemented `WKURLSchemeHandler` to serve bundled static files over `app://dartvector/`.
- [x] **2.4 Native JS Bridge (`BridgeHandler.swift`)**
  - Added `WKScriptMessageHandler` scaffolding for haptics, speech hooks, and secure storage primitives.

---

### Phase 3: GitHub Actions CI/CD Cloud Build Pipeline

- [x] **3.1 Set up `.github/workflows/ios.yml`**
  - The repository already includes the GitHub Actions workflow and it validates the web asset bundle before build.
- [ ] **3.2 Xcode Project Compilation & Signing**
  - This remains a macOS-only project setup step because no Xcode project file is present in this Linux workspace.
- [ ] **3.3 Automated Artifact Upload & TestFlight Deployment**
  - This remains a deployment step that requires Apple signing credentials and a macOS runner with an Xcode project configuration.

---

### Phase 4: Local Testing Strategy on Linux

- [x] **4.1 Web Bundle Verification**
  - Verified the static export builds under Linux and syncs cleanly into `DartVector/WebAssets/`.
- [ ] **4.2 iOS Simulator via Docker-OSX / QEMU-KVM (Optional)**
  - (Optional) Set up Docker-OSX or QEMU-KVM to run a local macOS instance with Xcode iOS Simulator on Linux.
- [ ] **4.3 Physical Device Testing via TestFlight**
  - This requires a signed Apple build and a physical iPhone/iPad with TestFlight installed.

---

## 🛠️ Step-by-Step Execution Guide

### Step 1: Syncing Next.js Web Assets to iOS

In your `DartVector` web application root directory, export the static bundle and copy it to `DartVector-ios`:

```bash
# 1. Build Next.js static export
cd $HOME/.gemini/projects/DartVector
BUILD_TARGET=ios npm run build

# 2. Sync exported static site into DartVector-ios bundle directory
mkdir -p $HOME/.gemini/projects/DartVector-ios/DartVector/WebAssets
rm -rf $HOME/.gemini/projects/DartVector-ios/DartVector/WebAssets/*
cp -R out/. $HOME/.gemini/projects/DartVector-ios/DartVector/WebAssets/
```

---

### Step 2: Swift WKWebView Shell Reference Code

#### 1. SwiftUI App Entry (`DartVectorApp.swift`)
```swift
import SwiftUI

@main
struct DartVectorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
        }
    }
}
```

#### 2. Local Asset Scheme Handler (`AppSchemeHandler.swift`)
```swift
import WebKit
import UniformTypeIdentifiers

class AppSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else { return }
        var path = url.path
        if path.isEmpty || path == "/" {
            path = "/index.html"
        }
        
        guard let assetPath = Bundle.main.path(forResource: path, ofType: nil, inDirectory: "WebAssets") ??
                Bundle.main.path(forResource: "index.html", ofType: nil, inDirectory: "WebAssets"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: assetPath)) else {
            urlSchemeTask.didFailWithError(NSError(domain: "AppSchemeHandler", code: 404, userInfo: nil))
            return
        }
        
        let mimeType = getMimeType(for: assetPath)
        let response = URLResponse(url: url, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: "utf-8")
        
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
    
    private func getMimeType(for filePath: String) -> String {
        if filePath.hasSuffix(".html") { return "text/html" }
        if filePath.hasSuffix(".js") { return "text/javascript" }
        if filePath.hasSuffix(".css") { return "text/css" }
        if filePath.hasSuffix(".json") { return "application/json" }
        if filePath.hasSuffix(".png") { return "image/png" }
        if filePath.hasSuffix(".svg") { return "image/svg+xml" }
        return "application/octet-stream"
    }
}
```

#### 3. ContentView (`ContentView.swift`)
```swift
import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let schemeHandler = AppSchemeHandler()
        config.setURLSchemeHandler(schemeHandler, forURLScheme: "app")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        
        if let url = URL(string: "app://dartvector/index.html") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
```

---

### Step 3: GitHub Actions CI/CD Pipeline (`.github/workflows/ios.yml`)

Save this file to `.github/workflows/ios.yml` in your `DartVector-ios` repository:

```yaml
name: iOS Build Pipeline

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - name: Checkout iOS Repository
        uses: actions/checkout@v4

      - name: Select Xcode Version
        run: sudo xcode-select -switch /Applications/Xcode_16.0.app

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22

      - name: Checkout Web Application
        uses: actions/checkout@v4
        with:
          repository: jerimie81/DartVector
          path: web-src

      - name: Build Static Web Export
        run: |
          cd web-src
          npm ci
          BUILD_TARGET=ios npm run build
          mkdir -p ../DartVector/WebAssets
          cp -R out/. ../DartVector/WebAssets/

      - name: Build iOS App (Simulator / Debug)
        run: |
          xcodebuild build \
            -project DartVector.xcodeproj \
            -scheme DartVector \
            -sdk iphonesimulator \
            -configuration Debug \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO

      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ios-app-debug
          path: build/Build/Products/Debug-iphonesimulator/DartVector.app
```

---

## 🎯 Verification & Testing Matrix

- [ ] Verify local Next.js `out/` export copies cleanly into `DartVector/WebAssets/`.
- [ ] Push changes to GitHub and confirm `.github/workflows/ios.yml` runs successfully on `macos-latest`.
- [ ] Verify `.app` artifact is produced and ready for testing or TestFlight submission.
