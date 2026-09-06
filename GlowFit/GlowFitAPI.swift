//
//  GlowFitAPI.swift
//  GlowFit
//
//  خدمة موحّدة لكل عمليات التوثيق (تسجيل دخول، تحقق من الرمز، استعادة كلمة مرور).
//  بنفس أسلوب الاتصال المستخدم أصلاً بـ SignupView.swift (URLSession مباشرة، بدون مكتبات إضافية).
//

import Foundation
import UIKit

// نخلي String نوع خطأ صالح (Error) عشان نقدر نستخدم Result<Void, String> بسهولة
// بكل أنحاء هذا الملف بدون تعقيد إضافي
extension String: Error {}

enum GlowFitAPI {

    // =====================================================
    // MARK: - تحويل تواريخ Supabase لصيغة مفهومة بالعربي
    // =====================================================
    // Postgres/PostgREST بيرجّع تواريخ بأشكال مختلفة شوي (مع/بدون كسور ثانية،
    // Z أو +00:00)، فبنجرب أكتر من صيغة لحد ما وحدة تنجح، بدل ما نرجع نص خام.

    static func parseSupabaseDate(_ raw: String) -> Date? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
            "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd HH:mm:ssZZZZZ"
        ]
        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) {
                return date
            }
        }
        // محاولة أخيرة بالمنسّق الرسمي (بيغطي حالات ISO8601 القياسية)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.date(from: raw)
    }

    /// وقت نسبي مفهوم بالعربي (زي "قبل 3 أيام"، "قبل ساعتين") بدل النص التقني الخام
    static func humanRelativeDate(_ raw: String) -> String {
        guard let date = parseSupabaseDate(raw) else { return "منذ فترة" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // نفس القيم المستخدمة بكل مكان تاني بالمشروع (لوحة التحكم، صفحة الهبوط، SignupView)
    static let supabaseURL = "https://ojaxkhkbyfkcwgavxihq.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9qYXhraGtieWZrY3dnYXZ4aWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2NTIxNjQsImV4cCI6MjA5MzIyODE2NH0.g5fsf1h9nQ1E3XpBCKMIVkVb7lMCp0uUc5SLUEdNZpM"

    // =====================================================
    // MARK: - تخزين الجلسة (Session)
    // =====================================================
    // ملاحظة: UserDefaults مناسب للتجربة الحالية، بس الأفضل مستقبلاً نقلها
    // لـ Keychain (أكثر أماناً لتخزين التوكنات) قبل الإطلاق الرسمي.

    static func saveSession(accessToken: String, refreshToken: String, userId: String, email: String, expiresIn: Int = 3600) {
        UserDefaults.standard.set(accessToken, forKey: "gf_access_token")
        UserDefaults.standard.set(refreshToken, forKey: "gf_refresh_token")
        UserDefaults.standard.set(userId, forKey: "gf_user_id")
        UserDefaults.standard.set(email, forKey: "gf_user_email")
        UserDefaults.standard.set(Date().timeIntervalSince1970 + Double(expiresIn), forKey: "gf_token_expires_at")
    }

    static func clearSession() {
        UserDefaults.standard.removeObject(forKey: "gf_access_token")
        UserDefaults.standard.removeObject(forKey: "gf_refresh_token")
        UserDefaults.standard.removeObject(forKey: "gf_user_id")
        UserDefaults.standard.removeObject(forKey: "gf_user_email")
        UserDefaults.standard.removeObject(forKey: "gf_token_expires_at")
    }

    static var currentAccessToken: String? {
        UserDefaults.standard.string(forKey: "gf_access_token")
    }

    static var currentUserId: String? {
        UserDefaults.standard.string(forKey: "gf_user_id")
    }

    // =====================================================
    // MARK: - تجديد الجلسة تلقائياً قبل انتهائها
    // =====================================================
    // بيتأكد إنه الـ token صالح لدقيقتين إضافيتين عالأقل قبل أي طلب — لو قارب
    // ينتهي، بيجدده بصمت باستخدام الـ refresh_token قبل ما نكمل الطلب الأصلي.

    static func ensureFreshToken(completion: @escaping () -> Void) {
        let expiresAt = UserDefaults.standard.double(forKey: "gf_token_expires_at")
        let hasToken = currentAccessToken != nil
        let hasRefresh = UserDefaults.standard.string(forKey: "gf_refresh_token") != nil

        if hasToken && (expiresAt - Date().timeIntervalSince1970) > 120 {
            completion() // لسا في وقت كافي
            return
        }
        guard hasRefresh else {
            completion() // ما في شي نجدد منه، خلي الطلب يفشل ويوضح المشكلة الحقيقية
            return
        }

        guard let refreshToken = UserDefaults.standard.string(forKey: "gf_refresh_token"),
              let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=refresh_token") else {
            completion()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["refresh_token": refreshToken])

        URLSession.shared.dataTask(with: request) { data, response, _ in
            defer { completion() }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccessToken = json["access_token"] as? String,
                  let newRefreshToken = json["refresh_token"] as? String,
                  let expiresIn = json["expires_in"] as? Int else {
                return
            }
            UserDefaults.standard.set(newAccessToken, forKey: "gf_access_token")
            UserDefaults.standard.set(newRefreshToken, forKey: "gf_refresh_token")
            UserDefaults.standard.set(Date().timeIntervalSince1970 + Double(expiresIn), forKey: "gf_token_expires_at")
        }.resume()
    }

    static var currentUserEmail: String? {
        UserDefaults.standard.string(forKey: "gf_user_email")
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

                    let expiresIn = json["expires_in"] as? Int ?? 3600
                    saveSession(accessToken: accessToken, refreshToken: refreshToken, userId: userId, email: userEmail, expiresIn: expiresIn)
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

                    let expiresIn = json["expires_in"] as? Int ?? 3600
                    saveSession(accessToken: accessToken, refreshToken: refreshToken, userId: userId, email: userEmail, expiresIn: expiresIn)
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
    // MARK: - إعادة إرسال رمز التحقق
    // =====================================================

    static func resendOTP(
        email: String,
        completion: @escaping (Result<Void, String>) -> Void
    ) {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/resend") else {
            completion(.failure("رابط غير صحيح"))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "type": "signup",
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
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                } else {
                    var msg = "تعذّر إعادة إرسال الرمز"
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let rawMsg = (json["msg"] as? String) ?? (json["error_description"] as? String) {
                        msg = translateAuthError(rawMsg)
                    }
                    completion(.failure(msg))
                }
            }
        }.resume()
    }

    // =====================================================
    // MARK: - جلب بيانات البروفايل الحقيقية
    // =====================================================

    struct GFProfile: Decodable {
        let id: String
        let email: String?
        let full_name: String?
        let phone: String?
        let avatar_url: String?
        let skin_type: String?
        let skin_concerns: [String]?
        let subscription_tier: String?
        let notifications_enabled: Bool?
    }

    static func fetchMyProfile(completion: @escaping (Result<GFProfile, String>) -> Void) {
        ensureFreshToken {
        guard let userId = currentUserId, let token = currentAccessToken else {
            completion(.failure("لا يوجد مستخدم مسجل دخول"))
            return
        }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?select=*&id=eq.\(userId)") else {
            completion(.failure("رابط غير صحيح"))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil, let data = data else {
                    completion(.failure("تعذّر الاتصال بالخادم"))
                    return
                }
                guard let rows = try? JSONDecoder().decode([GFProfile].self, from: data), let first = rows.first else {
                    completion(.failure("تعذّر تحميل بيانات الحساب"))
                    return
                }
                completion(.success(first))
            }
        }.resume()
        }
    }

    // =====================================================
    // MARK: - تحديث بيانات البروفايل الشخصية
    // =====================================================

    // =====================================================
    // MARK: - رفع صورة البروفايل الحقيقية
    // =====================================================

    static func uploadAvatar(imageData: Data, completion: @escaping (Result<String, String>) -> Void) {
        ensureFreshToken {
        guard let userId = currentUserId, let token = currentAccessToken else {
            completion(.failure("لا يوجد مستخدم مسجل دخول"))
            return
        }
        let path = "\(userId)/avatar.jpg"
        guard let uploadURL = URL(string: "\(supabaseURL)/storage/v1/object/avatars/\(path)") else {
            completion(.failure("رابط غير صحيح"))
            return
        }

        var uploadRequest = URLRequest(url: uploadURL)
        uploadRequest.httpMethod = "POST"
        uploadRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        uploadRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        uploadRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        uploadRequest.setValue("true", forHTTPHeaderField: "x-upsert") // نسمح باستبدال الصورة القديمة
        uploadRequest.httpBody = imageData

        URLSession.shared.dataTask(with: uploadRequest) { _, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure("تعذّر رفع الصورة: \(error.localizedDescription)")) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure("تعذّر رفع الصورة")) }
                return
            }

            // الصورة انرفعت — هلق نحدّث رابطها بجدول profiles
            let publicURL = "\(supabaseURL)/storage/v1/object/public/avatars/\(path)"
            guard let updateURL = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)") else {
                DispatchQueue.main.async { completion(.success(publicURL)) }
                return
            }
            var updateRequest = URLRequest(url: updateURL)
            updateRequest.httpMethod = "PATCH"
            updateRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
            updateRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            updateRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            updateRequest.setValue("return=minimal", forHTTPHeaderField: "Prefer")
            // نضيف طابع زمني للرابط عشان الصورة الجديدة تتحدث فوراً بالواجهة (تفادي الكاش)
            updateRequest.httpBody = try? JSONSerialization.data(withJSONObject: ["avatar_url": "\(publicURL)?t=\(Int(Date().timeIntervalSince1970))"])

            URLSession.shared.dataTask(with: updateRequest) { _, _, _ in
                DispatchQueue.main.async { completion(.success("\(publicURL)?t=\(Int(Date().timeIntervalSince1970))")) }
            }.resume()
        }.resume()
        }
    }

    static func updateMyProfile(fullName: String, phone: String, completion: @escaping (Result<Void, String>) -> Void) {
        ensureFreshToken {
        guard let userId = currentUserId, let token = currentAccessToken else {
            completion(.failure("لا يوجد مستخدم مسجل دخول"))
            return
        }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)") else {
            completion(.failure("رابط غير صحيح"))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "full_name": fullName,
            "phone": phone
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure("خطأ بالاتصال: \(error.localizedDescription)"))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure("تعذّر حفظ التعديلات"))
                    return
                }
                completion(.success(()))
            }
        }.resume()
        }
    }

    // =====================================================
    // MARK: - تحديث تفضيل الإشعارات
    // =====================================================

    static func updateNotifications(enabled: Bool, completion: @escaping (Result<Void, String>) -> Void) {
        ensureFreshToken {
        guard let userId = currentUserId, let token = currentAccessToken else {
            completion(.failure("لا يوجد مستخدم مسجل دخول"))
            return
        }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)") else {
            completion(.failure("رابط غير صحيح"))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["notifications_enabled": enabled])

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error.localizedDescription))
                    return
                }
                completion(.success(()))
            }
        }.resume()
        }
    }

    // =====================================================
    // MARK: - فحص البشرة بالذكاء الاصطناعي
    // =====================================================

    struct RecommendedProduct: Decodable, Identifiable {
        let id: String?
        let name: String?
        let brand: String?
        let category: String?
        let price: Double?
        let key_ingredient: String?
        let image_url: String?
    }

    struct ProblemSolution: Decodable {
        let problem: String?
        let solution: String?
        let source: String?
        let link: String?
    }

    struct ScanComparison: Decodable {
        let has_previous: Bool
        let previous_score: Int?
        let score_change: Int?
        let previous_scan_date: String?
    }

    struct SkinScanResult: Decodable, Identifiable {
        let id = UUID()

        let type_skin: String?
        let estimated_age: Int?
        let moisture_level: Int?
        let pores_condition: String?
        let dark_circles_percentage: Int?
        let pigmentation: String?
        let sensitivity: String?
        let acne_percentage: Int?
        let fine_lines_percentage: Int?
        let skin_health_score: Int?
        let summary_text: String?
        let concerns: [String]?
        let recommendations: [String]?
        let problems_and_solutions: [ProblemSolution]?
        let recommended_products: [RecommendedProduct]?
        let comparison: ScanComparison?
        let scan_id: String?
        let error: String?

        // نستثني id من الترميز لأنها مو موجودة أصلاً باستجابة السيرفر — بنولّدها محلياً بس
        enum CodingKeys: String, CodingKey {
            case type_skin, estimated_age, moisture_level, pores_condition, dark_circles_percentage,
                 pigmentation, sensitivity, acne_percentage, fine_lines_percentage, skin_health_score,
                 summary_text, concerns, recommendations, problems_and_solutions, recommended_products,
                 comparison, scan_id, error
        }
    }

    static func analyzeSkin(imageBase64: String, completion: @escaping (Result<SkinScanResult, String>) -> Void) {
        ensureFreshToken {
        guard let token = currentAccessToken else {
            completion(.failure("لازم تسجّلي دخول أول"))
            return
        }
        guard let url = URL(string: "\(supabaseURL)/functions/v1/app-skin-scan") else {
            completion(.failure("رابط غير صحيح"))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["image_base64": imageBase64])

        // نطلب وقت إضافي من نظام iOS عشان الفحص يكمل حتى لو المستخدمة طلعت
        // من التطبيق (زر الرئيسية، أو بدّلت لتطبيق تاني) أثناء انتظار النتيجة
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "GlowFitSkinScan") {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }

        func finish(_ result: Result<SkinScanResult, String>) {
            DispatchQueue.main.async {
                completion(result)
            }
            if backgroundTaskID != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
                backgroundTaskID = .invalid
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                finish(.failure("خطأ بالاتصال: \(error.localizedDescription)"))
                return
            }
            guard let data = data else {
                finish(.failure("استجابة فاضية من الخادم"))
                return
            }
            guard let result = try? JSONDecoder().decode(SkinScanResult.self, from: data) else {
                finish(.failure("تعذّر قراءة نتيجة التحليل"))
                return
            }
            if let err = result.error {
                finish(.failure(err))
                return
            }
            // نحفظ آخر نتيجة فحص محلياً عشان تضل متاحة حتى لو المستخدمة طلعت من الشاشة ورجعت
            UserDefaults.standard.set(data, forKey: "gf_last_scan_result")
            finish(.success(result))
        }.resume()
        } // نهاية ensureFreshToken
    }

    /// آخر نتيجة فحص محفوظة محلياً (لو موجودة) — تستخدم لعرضها من جديد بدون إعادة تحليل
    static func getLastCachedScanResult() -> SkinScanResult? {
        guard let data = UserDefaults.standard.data(forKey: "gf_last_scan_result") else { return nil }
        return try? JSONDecoder().decode(SkinScanResult.self, from: data)
    }

    // =====================================================
    // MARK: - رابط موقّت وآمن لعرض صورة فحص خاصة (البَكِت خاص مش عام)
    // =====================================================

    static func getSignedScanImageURL(path: String, completion: @escaping (String?) -> Void) {
        ensureFreshToken {
        guard let token = currentAccessToken,
              let url = URL(string: "\(supabaseURL)/storage/v1/object/sign/skin-scan-photos/\(path)") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["expiresIn": 3600])

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                guard error == nil, let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let signedURL = json["signedURL"] as? String else {
                    completion(nil)
                    return
                }
                completion("\(supabaseURL)/storage/v1\(signedURL)")
            }
        }.resume()
        }
    }

    // =====================================================
    // MARK: - جلب سجل الفحوصات الكامل (لشاشة التقارير)
    // =====================================================

    struct ScanHistoryItem: Decodable, Identifiable {
        let id: String
        let created_at: String
        let image_url: String?
        let skin_health_score: Int?
        let estimated_age: Int?
        let moisture_level: Int?
        let acne_percentage: Int?
        let dark_circles_percentage: Int?
        let fine_lines_percentage: Int?
        let pores_condition: String?
        let pigmentation: String?
        let sensitivity: String?
        let summary_text: String?
        let concerns: [String]?
        let recommendations: [String]?
        let problems_and_solutions: [ProblemSolution]?
    }

    static func getScanHistory(limit: Int = 20, completion: @escaping ([ScanHistoryItem]) -> Void) {
        ensureFreshToken {
        guard let userId = currentUserId, let token = currentAccessToken else {
            completion([])
            return
        }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/skin_scans?select=id,created_at,image_url,skin_health_score,estimated_age,moisture_level,acne_percentage,dark_circles_percentage,fine_lines_percentage,pores_condition,pigmentation,sensitivity,summary_text,concerns,recommendations,problems_and_solutions&user_id=eq.\(userId)&order=created_at.desc&limit=\(limit)") else {
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil, let data = data,
                      let rows = try? JSONDecoder().decode([ScanHistoryItem].self, from: data) else {
                    completion([])
                    return
                }
                completion(rows)
            }
        }.resume()
        }
    }

    // =====================================================
    // MARK: - جلب آخر فحص حقيقي من قاعدة البيانات (للصفحة الرئيسية)
    // =====================================================

    struct LatestScan: Decodable {
        let skin_health_score: Int?
        let summary_text: String?
        let created_at: String?
    }

    static func getLatestScan(completion: @escaping (LatestScan?) -> Void) {
        ensureFreshToken {
        guard let userId = currentUserId, let token = currentAccessToken else {
            completion(nil)
            return
        }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/skin_scans?select=skin_health_score,summary_text,created_at&user_id=eq.\(userId)&order=created_at.desc&limit=1") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil, let data = data,
                      let rows = try? JSONDecoder().decode([LatestScan].self, from: data),
                      let first = rows.first else {
                    completion(nil)
                    return
                }
                completion(first)
            }
        }.resume()
        }
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
