import UIKit
import GoogleMobileAds

// =====================================================
// MARK: - إعلان المكافأة (Rewarded) لفحص البشرة
// =====================================================
// الفكرة باختصار:
// 1) أول فحص باليوم مجاني وبدون إعلان.
// 2) بعده: كل فحص بيطلع قبله تنبيه صغير، والمستخدمة بتشوف إعلان قصير عشان يبلّش الفحص.
// 3) الإعلان بيتحمّل مسبقاً بالخلفية عشان يطلع فوراً.
// 4) لو الإعلان مش جاهز أو فشل، ما منوقف المستخدمة: الفحص بيكمّل عادي.
// 5) لو صار في اشتراك Premium مستقبلاً، ما بيشوف إعلانات.

/// بيحمّل ويعرض إعلان المكافأة، وبيبلّغنا إذا المستخدمة كمّلت الإعلان واستحقت المكافأة
final class RewardedAdManager: NSObject, GADFullScreenContentDelegate {
    /// شو صار بالإعلان بعد ما انسكّر
    enum Outcome { case earned, closedEarly, failedToShow }

    static let shared = RewardedAdManager()

    private let adUnitID = "ca-app-pub-8721673493100580/8336720126" // وحدة المكافأة الحقيقية (iOS)، بكل النسخ

    /// في معرّف إعلان؟ (إذا لا، منلغي البوابة كلها بأمان)
    var isConfigured: Bool { !adUnitID.isEmpty }
    var isReady: Bool { rewardedAd != nil }

    private var rewardedAd: GADRewardedAd?
    private var isLoading = false
    private var earnedReward = false
    private var onReward: (() -> Void)?
    private var onFinish: ((Outcome) -> Void)?

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
    /// - onFinish: بتنادى لما يسكّر الإعلان: استحقت المكافأة، سكّرته بكير، أو ما قدر ينعرض أصلاً
    @discardableResult
    func present(onReward: @escaping () -> Void, onFinish: @escaping (Outcome) -> Void) -> Bool {
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
        finish(.failedToShow)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        finish(earnedReward ? .earned : .closedEarly)
    }

    private func finish(_ outcome: Outcome) {
        rewardedAd = nil
        let callback = onFinish
        onFinish = nil
        onReward = nil
        DispatchQueue.main.async { callback?(outcome) }
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

    private static func value(_ name: String) -> Int { UserDefaults.standard.integer(forKey: key(name)) }
    private static func add(_ name: String, _ delta: Int) { UserDefaults.standard.set(value(name) + delta, forKey: key(name)) }

    /// باقيلها الفحص المجاني لليوم؟
    static var hasFreeScan: Bool { value("free_used") < freeScansPerDay }
    /// عندها فحص مفتوح بإعلان وما استخدمته لسا؟ (مثلاً الفحص فشل بعد الإعلان)
    static var hasAdCredit: Bool { value("ad_credits") > 0 }

    static func recordFreeScan() { add("free_used", 1) }
    static func grantAdCredit() { add("ad_credits", 1) }
    static func consumeAdCredit() { if hasAdCredit { add("ad_credits", -1) } }
}
