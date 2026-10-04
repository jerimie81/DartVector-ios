import Foundation
import Security
import Speech
import UIKit
import WebKit

final class BridgeHandler: NSObject, WKScriptMessageHandler {
    static let messageName = "nativeBridge"

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }

        switch body["type"] as? String {
        case "haptic":
            triggerHaptic(style: body["style"] as? String ?? "impact")
        case "speech":
            handleSpeechRequest()
        case "secureSet":
            saveSecureValue(key: body["key"] as? String ?? "", value: body["value"] as? String ?? "")
        case "secureGet":
            readSecureValue(key: body["key"] as? String ?? "")
        default:
            break
        }
    }

    private func triggerHaptic(style: String) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    private func handleSpeechRequest() {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        recognizer?.delegate = self as? SFSpeechRecognizerDelegate
        // This placeholder intentionally keeps the bridge ready for a real voice-command implementation.
        // The actual iOS voice pipeline would be wired to AVAudioEngine + SFSpeechAudioBufferRecognitionRequest.
    }

    private func saveSecureValue(key: String, value: String) {
        guard !key.isEmpty else { return }
        let data = value.data(using: .utf8) ?? Data()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func readSecureValue(key: String) {
        guard !key.isEmpty else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data, let value = String(data: data, encoding: .utf8) {
            print("Secure value for \(key): \(value)")
        }
    }
}
