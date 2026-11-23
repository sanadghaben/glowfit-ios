import SwiftUI
import UIKit
import GoogleMobileAds

// =====================================================
// MARK: - إعلان المكافأة (Rewarded) لفحص البشرة
// =====================================================
// الفكرة باختصار:
// 1) أول فحص باليوم مجاني وبدون إعلان.
// 2) بعده: المستخدمة بتختار تشوف إعلان قصير مقابل فحص إضافي (حد أقصى باليوم)، أو تشترك Premium.
// 3) الإعلان بيتحمّل مسبقاً بالخلفية عشان يطلع فوراً.
// 4) لو الإعلان مش جاهز أو فشل، ما منوقف المستخدمة: الفحص بيكمّل عادي.
// 5) Premium ما بيشوف إعلانات أبداً.

/// بيحمّل ويعرض إعلان المكافأة، وبيبلّغنا إذا المستخدمة كمّلت الإعلان واستحقت المكافأة
final class RewardedAdManager: NSObject, GADFullScreenContentDelegate {
    static let shared = RewardedAdManager()

    #if DEBUG
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313" // معرّف تجريبي رسمي من جوجل
    #else
    // ⚠️ حط هون معرّف إعلان المكافأة الحقيقي من AdMob (Rewarded) قبل ما تنشر.
    // طالما هو فاضي، نسخة المتجر بتضل زي هلأ: فحص بدون إعلان مكافأة ولا حد يومي.
    private let adUnitID = ""
    #endif

    /// في معرّف إعلان؟ (إذا لا، منلغي البوابة كلها بأمان)
    var isConfigured: Bool { !adUnitID.isEmpty }
    var isReady: Bool { rewardedAd != nil }

    private var rewardedAd: GADRewardedAd?
    private var isLoading = false
    private var earnedReward = false
    private var onReward: (() -> Void)?
    private var onFinish: ((Bool) -> Void)?

    private override init() { super.init() }

    /// تحميل مسبق — بننادي عليه لما تنفتح شاشة الفحص، وبعد كل إعلان
    func preload() {
        guard isConfigured, rewardedAd == nil, !isLoading else { return }
        isLoading = true
        GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                guard error == nil, let ad = ad else { return }
                ad.fullScreenContentDelegate = self
                self.rewardedAd = ad
            }
        }
    }

    /// بيعرض الإعلان. بيرجّع false إذا ما في إعلان جاهز.
    /// - onReward: بتنادى لحظة ما تستحق المكافأة (قبل ما تسكّر الإعلان) — هون منبلّش التحليل
    /// - onFinish: بتنادى لما يسكّر الإعلان، ومعها هل استحقت المكافأة ولا لا
    @discardableResult
    func present(onReward: @escaping () -> Void, onFinish: @escaping (Bool) -> Void) -> Bool {
        guard let ad = rewardedAd, let rootVC = Self.topViewController() else { return false }
        earnedReward = false
        self.onReward = onReward
        self.onFinish = onFinish
        ad.present(fromRootViewController: rootVC) { [weak self] in
            guard let self = self else { return }
            self.earnedReward = true
            let callback = self.onReward
            self.onReward = nil
            DispatchQueue.main.async { callback?() }
        }
        return true
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        finish()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        finish()
    }

    private func finish() {
        rewardedAd = nil
        let callback = onFinish
        let earned = earnedReward
        onFinish = nil
        onReward = nil
        DispatchQueue.main.async { callback?(earned) }
        preload() // نجهّز اللي بعده
    }

    /// أعلى شاشة ظاهرة حالياً (عشان الإعلان يطلع فوق أي sheet مفتوح)
    private static func topViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        var top = root
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}

// =====================================================
// MARK: - عدّاد فحوصات اليوم (على الجهاز، بتوقيت عمّان)
// =====================================================
// ملاحظة: هاد العداد على الجهاز بس. الحماية الكاملة (إنه السيرفر يتأكد إنها شافت الإعلان)
// بتنعمل لاحقاً بـ AdMob Server-Side Verification.
enum ScanQuota {
    static let freeScansPerDay = 1
    static let maxAdScansPerDay = 3

    private static var today: String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Asia/Amman")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private static func key(_ name: String) -> String {
        "gf_scanquota_\(GlowFitAPI.currentUserId ?? "guest")_\(today)_\(name)"
    }

    private static func get(_ name: String) -> Int { UserDefaults.standard.integer(forKey: key(name)) }
    private static func add(_ name: String, _ delta: Int) { UserDefaults.standard.set(get(name) + delta, forKey: key(name)) }

    /// باقيلها الفحص المجاني لليوم؟
    static var hasFreeScan: Bool { get("free_used") < freeScansPerDay }
    /// عندها فحص مفتوح بإعلان وما استخدمته لسا؟ (مثلاً الفحص فشل بعد الإعلان)
    static var hasAdCredit: Bool { get("ad_credits") > 0 }
    /// قديش ضايل فحوصات إضافية بالإعلانات اليوم
    static var adScansLeft: Int { max(0, maxAdScansPerDay - get("ad_unlocked")) }

    static func recordFreeScan() { add("free_used", 1) }
    static func grantAdCredit() { add("ad_unlocked", 1); add("ad_credits", 1) }
    static func consumeAdCredit() { if hasAdCredit { add("ad_credits", -1) } }
}

// =====================================================
// MARK: - شاشة "افتحي فحص إضافي"
// =====================================================
struct SkinScanAdGateView: View {
    /// true = خلصت كل فحوصات اليوم (ما في إعلانات كمان)
    let limitReached: Bool
    let adsLeft: Int
    let message: String?
    let onWatch: () -> Void
    let onPremium: () -> Void
    let onClose: () -> Void

    private let lightPink = Color(red: 249/255, green: 168/255, blue: 212/255)
    private let lightPurple = Color(red: 191/255, green: 133/255, blue: 252/255)

    var body: some View {
        ZStack {
            Color(red: 10/255, green: 10/255, blue: 15/255).opacity(0.97).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(L("scanad_later"))
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 8)

                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.25), AuthColors.primaryPink.opacity(0.2)],
                                                 startPoint: .topTrailing, endPoint: .bottomLeading))
                            .frame(width: 96, height: 96)
                            .overlay(Circle().stroke(AuthColors.primaryPurple.opacity(0.3), lineWidth: 1))
                        Image(systemName: limitReached ? "moon.stars.fill" : "gift.fill")
                            .font(.system(size: 36))
                            .foregroundColor(lightPink)
                    }
                    Text(L(limitReached ? "scanad_limit_title" : "scanad_gate_title"))
                        .font(.custom("Tajawal-Bold", size: 24)).foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text(L(limitReached ? "scanad_limit_body" : "scanad_gate_body"))
                        .font(.custom("Tajawal-Regular", size: 14)).lineSpacing(5)
                        .foregroundColor(Color.white.opacity(0.7)).multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32).padding(.top, 40)

                if !limitReached {
                    VStack(spacing: 0) {
                        gateRow(L("scanad_gate_point1"))
                        Divider().background(Color.white.opacity(0.1))
                        gateRow(String(format: L("scanad_gate_point2"), adsLeft))
                    }
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal, 20).padding(.top, 28)
                }

                if let message = message {
                    Text(message)
                        .font(.custom("Tajawal-Medium", size: 14))
                        .foregroundColor(lightPink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24).padding(.top, 16)
                }

                Spacer()

                VStack(spacing: 10) {
                    if !limitReached {
                        Button(action: onWatch) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text(L("scanad_gate_watch")).font(.custom("Tajawal-Bold", size: 17))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                       startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                        }
                    }
                    Button(action: onPremium) {
                        Text(L("scanad_gate_premium")).font(.custom("Tajawal-Bold", size: 16))
                            .foregroundColor(lightPurple)
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                            .background(AuthColors.primaryPurple.opacity(0.12)).cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AuthColors.primaryPurple.opacity(0.3), lineWidth: 1))
                    }
                    Button(action: onClose) {
                        Text(L("scanad_later")).font(.custom("Tajawal-Medium", size: 15))
                            .foregroundColor(Color.white.opacity(0.65)).padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 130) // فوق شريط التبويبات
            }
        }
        .autoLayoutDirection()
    }

    private func gateRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle").foregroundColor(lightPink)
            Text(text).font(.custom("Tajawal-Regular", size: 14)).foregroundColor(Color.white.opacity(0.85))
            Spacer()
        }
        .padding(.vertical, 14)
    }
}
