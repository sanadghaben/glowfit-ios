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
        // نأخّر الطلب لتيك واحد عشان نضمن إنه SwiftUI خلّص يحدّد حجم المساحة فعلياً (320×50)
        // قبل ما نرسل الطلب — إرساله فوراً جوا makeUIView بيسبّق تحديد الحجم ويطلع "width/height: (0, 0)"
        DispatchQueue.main.async {
            banner.load(GADRequest())
        }
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
            } else if isPremium == nil {
                // لسا ما تأكدنا من حالة الاشتراك — نحجز نفس المساحة عشان ما تختفي الشاشة ولا تقفز لما يوصل الرد
                Color.clear
            }
            // isPremium == true → ما نعرض شي ولا نحجز مساحة
        }
        .frame(width: 320, height: isPremium == true ? 0 : 50)
        .frame(maxWidth: .infinity)
        .onAppear {
            guard isPremium == nil else { return }
            GlowFitAPI.fetchMyProfile { result in
                if case .success(let profile) = result {
                    isPremium = (profile.subscription_tier == "premium")
                } else {
                    isPremium = false // ما قدرنا نتأكد؟ منعرض الإعلان بشكل آمن (المستخدمة مش موثّقة Premium)
                }
                InterstitialAdManager.shared.updatePremiumStatus(isPremium ?? false)
            }
        }
    }
}
