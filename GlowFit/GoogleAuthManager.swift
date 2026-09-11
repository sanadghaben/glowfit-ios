import UIKit
import GoogleSignIn

/// يدير تسجيل الدخول بحساب جوجل ويربطه بجلسة Supabase
enum GoogleAuthManager {

    static func signIn(completion: @escaping (Result<Void, String>) -> Void) {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            completion(.failure("تعذّر بدء تسجيل الدخول"))
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                completion(.failure("تعذّر تسجيل الدخول بجوجل: \(error.localizedDescription)"))
                return
            }
            guard let idToken = result?.user.idToken?.tokenString else {
                completion(.failure("تعذّر الحصول على بيانات الدخول من جوجل"))
                return
            }
            GlowFitAPI.signInWithGoogleIdToken(idToken: idToken, completion: completion)
        }
    }
}
