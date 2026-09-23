import SwiftUI
import GoogleMobileAds

/// غلاف SwiftUI حول بانر إعلانات جوجل (AdMob)
struct BannerAdView: UIViewRepresentable {
    typealias UIViewType = GADBannerView
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: { $0.isKeyWindow })?.rootViewController
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

/// المكوّن اللي نستخدمه فعلياً بالشاشات — بيتأكد المستخدمة مش مشتركة Premium قبل ما يعرض أي إعلان
struct PremiumAwareBannerAd: View {
    let adUnitID: String
    @State private var isPremium: Bool? = nil // nil = لسا ما تأكدنا

    // ⚠️ معرّف تجريبي رسمي من جوجل للتطوير — استبدليه بمعرّف البانر الحقيقي من حساب AdMob بعد إنشائه
    static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    // معرّف البانر الحقيقي من حساب AdMob الفعلي لتطبيق GlowFit
    static let productionBannerAdUnitID = "ca-app-pub-8721673493100580/2923969747"

    var body: some View {
        Group {
            if isPremium == false {
                BannerAdView(adUnitID: adUnitID)
                    .frame(width: 320, height: 50)
                    .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            guard isPremium == nil else { return }
            GlowFitAPI.fetchMyProfile { result in
                if case .success(let profile) = result {
                    isPremium = (profile.subscription_tier == "premium")
                } else {
                    isPremium = false // ما قدرنا نتأكد؟ منعرض الإعلان بشكل آمن (المستخدمة مش موثّقة Premium)
                }
            }
        }
    }
}
