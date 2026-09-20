import UIKit
import GoogleSignIn

/// يدير تسجيل الدخول بحساب جوجل ويربطه بجلسة Supabase
enum GoogleAuthManager {

    static func signIn(completion: @escaping (Result<Void, String>) -> Void) {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            completion(.failure(L("google_auth_start_failed")))
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                completion(.failure(String(format: L("google_auth_failed"), error.localizedDescription)))
                return
            }
            guard let idToken = result?.user.idToken?.tokenString else {
                completion(.failure(L("google_auth_no_data")))
                return
            }
            GlowFitAPI.signInWithGoogleIdToken(idToken: idToken, completion: completion)
        }
    }
}
