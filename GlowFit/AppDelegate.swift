import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

/// يهيّئ Firebase ويدير رمز الجهاز (FCM Token) — لازم لاستقبال إشعارات الدفع الحقيقية
class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

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
