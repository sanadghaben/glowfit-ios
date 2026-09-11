import AuthenticationServices
import UIKit

/// يدير تسجيل الدخول بحساب آبل (Sign In with Apple) ويربطه بجلسة Supabase
final class AppleAuthManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    static let shared = AppleAuthManager()
    private var completion: ((Result<Void, String>) -> Void)?

    func signIn(completion: @escaping (Result<Void, String>) -> Void) {
        self.completion = completion
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            completion?(.failure("تعذّر الحصول على بيانات الدخول من آبل"))
            return
        }
        GlowFitAPI.signInWithAppleIdToken(idToken: idToken) { [weak self] result in
            self?.completion?(result)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // المستخدمة لغت العملية بنفسها — ما لازم نوريها رسالة خطأ مزعجة
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            completion?(.failure(""))
            return
        }
        completion?(.failure("تعذّر تسجيل الدخول بآبل: \(error.localizedDescription)"))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}
