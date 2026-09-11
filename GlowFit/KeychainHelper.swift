import Foundation
import Security

/// تخزين آمن ومشفّر (Keychain) — مش UserDefaults عادي — لأنه بيانات حساسة (إيميل وكلمة مرور)
enum KeychainHelper {
    private static let service = "com.sanadtech.GlowFit.biometric"
    private static let emailKey = "gf_biometric_email"
    private static let passwordKey = "gf_biometric_password"

    private static func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary) // نحذف أي قيمة قديمة أول عشان ما يصير تعارض
        var newItem = query
        newItem[kSecValueData as String] = data
        SecItemAdd(newItem as CFDictionary, nil)
    }

    private static func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func saveCredentials(email: String, password: String) {
        save(email, forKey: emailKey)
        save(password, forKey: passwordKey)
    }

    static func getCredentials() -> (email: String, password: String)? {
        guard let email = read(forKey: emailKey), let password = read(forKey: passwordKey) else { return nil }
        return (email, password)
    }

    static func clearCredentials() {
        let queryEmail: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: emailKey]
        let queryPassword: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: passwordKey]
        SecItemDelete(queryEmail as CFDictionary)
        SecItemDelete(queryPassword as CFDictionary)
    }
}
