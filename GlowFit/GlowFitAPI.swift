//
//  GlowFitAPI.swift
//  GlowFit
//
//  خدمة موحّدة لكل عمليات التوثيق (تسجيل دخول، تحقق من الرمز، استعادة كلمة مرور).
//  بنفس أسلوب الاتصال المستخدم أصلاً بـ SignupView.swift (URLSession مباشرة، بدون مكتبات إضافية).
//

import Foundation

enum GlowFitAPI {

    // نفس القيم المستخدمة بكل مكان تاني بالمشروع (لوحة التحكم، صفحة الهبوط، SignupView)
    static let supabaseURL = "https://ojaxkhkbyfkcwgavxihq.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9qYXhraGtieWZrY3dnYXZ4aWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2NTIxNjQsImV4cCI6MjA5MzIyODE2NH0.g5fsf1h9nQ1E3XpBCKMIVkVb7lMCp0uUc5SLUEdNZpM"

    // =====================================================
    // MARK: - تخزين الجلسة (Session)
    // =====================================================
    // ملاحظة: UserDefaults مناسب للتجربة الحالية، بس الأفضل مستقبلاً نقلها
    // لـ Keychain (أكثر أماناً لتخزين التوكنات) قبل الإطلاق الرسمي.

    static func saveSession(accessToken: String, refreshToken: String, userId: String, email: String) {
        UserDefaults.standard.set(accessToken, forKey: "gf_access_token")
        UserDefaults.standard.set(refreshToken, forKey: "gf_refresh_token")
        UserDefaults.standard.set(userId, forKey: "gf_user_id")
        UserDefaults.standard.set(email, forKey: "gf_user_email")
    }

    static func clearSession() {
        UserDefaults.standard.removeObject(forKey: "gf_access_token")
        UserDefaults.standard.removeObject(forKey: "gf_refresh_token")
        UserDefaults.standard.removeObject(forKey: "gf_user_id")
        UserDefaults.standard.removeObject(forKey: "gf_user_email")
    }

    static var currentAccessToken: String? {
        UserDefaults.standard.string(forKey: "gf_access_token")
    }

    static var currentUserId: String? {
        UserDefaults.standard.string(forKey: "gf_user_id")
    }

    // =====================================================
    // MARK: - تسجيل الدخول
    // =====================================================

    static func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<Void, String>) -> Void
    ) {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else {
            completion(.failure("رابط غير صحيح"))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
            "password": password
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure("خطأ في الاتصال بالشبكة: \(error.localizedDescription)"))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    completion(.failure("استجابة غير صالحة من الخادم"))
                    return
                }

                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(.failure("تعذّر قراءة استجابة الخادم"))
                    return
                }

                if (200...299).contains(httpResponse.statusCode),
                   let accessToken = json["access_token"] as? String,
                   let refreshToken = json["refresh_token"] as? String,
                   let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String,
                   let userEmail = user["email"] as? String {

                    saveSession(accessToken: accessToken, refreshToken: refreshToken, userId: userId, email: userEmail)
                    completion(.success(()))

                } else {
                    let rawMsg = (json["msg"] as? String) ?? (json["error_description"] as? String) ?? "بيانات الدخول غير صحيحة"
                    completion(.failure(translateAuthError(rawMsg)))
                }
            }
        }.resume()
    }

    // =====================================================
    // MARK: - التحقق من رمز OTP (بعد التسجيل الجديد)
    // =====================================================

    static func verifyOTP(
        email: String,
        token: String,
        completion: @escaping (Result<Void, String>) -> Void
    ) {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/verify") else {
            completion(.failure("رابط غير صحيح"))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
            "token": token,
            "type": "signup"
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure("خطأ في الاتصال بالشبكة: \(error.localizedDescription)"))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    completion(.failure("استجابة غير صالحة من الخادم"))
                    return
                }

                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(.failure("تعذّر قراءة استجابة الخادم"))
                    return
                }

                if (200...299).contains(httpResponse.statusCode),
                   let accessToken = json["access_token"] as? String,
                   let refreshToken = json["refresh_token"] as? String,
                   let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String,
                   let userEmail = user["email"] as? String {

                    saveSession(accessToken: accessToken, refreshToken: refreshToken, userId: userId, email: userEmail)
                    completion(.success(()))

                } else {
                    let rawMsg = (json["msg"] as? String) ?? (json["error_description"] as? String) ?? "رمز التحقق غير صحيح"
                    completion(.failure(translateAuthError(rawMsg)))
                }
            }
        }.resume()
    }

    // =====================================================
    // MARK: - استعادة كلمة المرور
    // =====================================================

    static func sendPasswordReset(
        email: String,
        completion: @escaping (Result<Void, String>) -> Void
    ) {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/recover") else {
            completion(.failure("رابط غير صحيح"))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines)
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure("خطأ في الاتصال بالشبكة: \(error.localizedDescription)"))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure("استجابة غير صالحة من الخادم"))
                    return
                }
                // Supabase بيرجع 200 دايماً بعملية الاستعادة (حتى لو الإيميل مش مسجل، لأسباب أمنية)
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure("تعذّر إرسال رابط الاستعادة، حاول مرة ثانية"))
                }
            }
        }.resume()
    }

    // =====================================================
    // MARK: - تسجيل الخروج
    // =====================================================

    static func signOut() {
        clearSession()
        // (اختياري) استدعاء /auth/v1/logout لإبطال الـ refresh token من طرف السيرفر أيضاً
        guard let token = currentAccessToken,
              let url = URL(string: "\(supabaseURL)/auth/v1/logout") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request).resume()
    }

    // =====================================================
    // MARK: - ترجمة رسائل الخطأ (نفس أسلوب SignupView)
    // =====================================================

    static func translateAuthError(_ msg: String) -> String {
        if msg.contains("Invalid login credentials") {
            return "البريد الإلكتروني أو كلمة المرور غير صحيحة"
        } else if msg.contains("Email not confirmed") {
            return "لازم تأكدي بريدك الإلكتروني أول (تحققي من رمز OTP)"
        } else if msg.contains("Token has expired") || msg.contains("expired") {
            return "انتهت صلاحية رمز التحقق، اطلبي رمز جديد"
        } else if msg.contains("Invalid token") || msg.contains("invalid") {
            return "رمز التحقق غير صحيح"
        } else if msg.contains("rate limit") {
            return "تم تجاوز حد الطلبات المسموح، حاولي بعد شوي"
        }
        return msg
    }
}
