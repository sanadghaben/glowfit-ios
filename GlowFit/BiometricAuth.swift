import Foundation
import LocalAuthentication

/// يدير تسجيل الدخول ببصمة الوجه/الإصبع — بيستخدم بيانات محفوظة بأمان بالـ Keychain
/// لإعادة تسجيل الدخول تلقائياً بعد أول مرة تسجيل دخول ناجح
enum BiometricAuth {

    /// هل الجهاز أصلاً بيدعم بصمة الوجه أو الإصبع؟
    static var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// نوع البصمة المدعومة بهاد الجهاز تحديداً
    static var biometryType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    /// هل في بيانات دخول محفوظة مسبقاً نقدر نستخدمها؟
    static var hasSavedCredentials: Bool {
        KeychainHelper.getCredentials() != nil
    }

    static func saveCredentials(email: String, password: String) {
        KeychainHelper.saveCredentials(email: email, password: password)
    }

    /// تطلب بصمة الوجه، ولو نجحت، تسجّل دخول تلقائياً بالبيانات المحفوظة
    static func authenticate(completion: @escaping (Result<Void, String>) -> Void) {
        guard let credentials = KeychainHelper.getCredentials() else {
            completion(.failure(L("biometric_no_saved_creds")))
            return
        }

        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                localizedReason: L("biometric_reason")) { success, error in
            DispatchQueue.main.async {
                guard success else {
                    completion(.failure("")) // فاضية = المستخدمة لغت العملية بنفسها، ما لازم نوريها خطأ مزعج
                    return
                }
                GlowFitAPI.signIn(email: credentials.email, password: credentials.password, completion: completion)
            }
        }
    }
}
