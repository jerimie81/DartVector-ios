# DartVector iOS Application

Native iOS companion client for [DartVector](https://github.com/jerimie81/DartVector).

## Overview

DartVector-iOS wraps the DartVector web application into a native iOS app using Swift 6, SwiftUI, and `WKWebView` with custom scheme handlers (`WKURLSchemeHandler`).

For full Linux-to-iOS development guides, architecture blueprints, and CI/CD setup, see [TODO.md](file:///home/redrum/.gemini/projects/DartVector-ios/TODO.md).

## Quick Start on Linux

```bash
# 1. Sync web assets from main DartVector project
cd $HOME/.gemini/projects/DartVector
BUILD_TARGET=ios npm run build
mkdir -p $HOME/.gemini/projects/DartVector-ios/DartVector/WebAssets
cp -R out/. $HOME/.gemini/projects/DartVector-ios/DartVector/WebAssets/

# 2. Push code to trigger automated GitHub Actions iOS build
git add .
git commit -m "feat: update web assets and Swift shell"
git push origin main
```
