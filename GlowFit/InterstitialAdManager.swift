import GoogleMobileAds
import UIKit

/// يدير تحميل وعرض الإعلان البيني (بين الشاشات) — بيحترم حالة الاشتراك تلقائياً
/// وبيعرض في كل مرة تتوفّر فيها إعلان جاهز (بدون حد أقصى)
final class InterstitialAdManager: NSObject, GADFullScreenContentDelegate {
    static let shared = InterstitialAdManager()

    // معرّف الإعلان البيني الحقيقي من حساب AdMob
    private let adUnitID = "ca-app-pub-8721673493100580/2341030714"

    private var interstitial: GADInterstitialAd?
    private var isPremium = false

    private override init() {
        super.init()
        loadAd()
    }

    /// نحدّث حالة الاشتراك كل ما نعرف فيها شي جديد (بتنادى من أي مكان بعد ما نجيب البروفايل)
    func updatePremiumStatus(_ premium: Bool) {
        isPremium = premium
    }

    private func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self, error == nil else { return }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }

    /// تعرض الإعلان البيني لو: المستخدمة مش Premium، وفيه إعلان جاهز حالياً
    func showIfAppropriate() {
        guard !isPremium, let interstitial = interstitial,
              let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        interstitial.present(fromRootViewController: rootVC)
    }

    // بعد ما ينعرض الإعلان (أو يفشل)، نحضّر وحد جديد للمرة الجاية
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.interstitial = nil
        loadAd()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.interstitial = nil
        loadAd()
    }
}
