import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import GoogleSignIn

/// يهيّئ Firebase وGoogle Sign-In ويدير رمز الجهاز (FCM Token) — لازم لاستقبال إشعارات الدفع الحقيقية
class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // إعداد تسجيل الدخول بجوجل — رمز التطبيق الخاص بـ iOS (من Google Cloud Console)
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "449373874582-iu1qpl1g8r3j5todft0btrsb1b630slm.apps.googleusercontent.com")

        // لو المستخدمة سبق ووافقت على الإذن من قبل، نسجّل الجهاز تلقائياً كل مرة يفتح فيها التطبيق
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        return true
    }

    // لازمة عشان يرجع تسجيل الدخول بجوجل على التطبيق بنجاح بعد ما يخلص بمتصفح آبل الداخلي
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // آبل بترجّعلنا الـ Device Token بعد ما نطلب الإذن ويوافق المستخدم — نمرره لـ Firebase
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("فشل تسجيل الجهاز للإشعارات: \(error.localizedDescription)")
    }

    // Firebase بيرجّعلنا رمز فريد لهاد الجهاز (FCM Token) — بنحفظه بحساب المستخدمة عشان نقدر نبعتلها إشعارات لاحقاً
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        GlowFitAPI.saveFCMToken(token)
    }

    // إشعار وصل والتطبيق مفتوح قدّامها — نعرضه برضو (مش بس لما التطبيق مقفول)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
