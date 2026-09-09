import Foundation
import UIKit
import UserNotifications

/// يدير التذكيرات المحلية (Local Notifications) لخطوات الروتين — ما بيحتاج أي خدمة خارجية
/// (Firebase/OneSignal)، لأنه تذكير شخصي متكرر يومياً بالوقت اللي تحدّده المستخدمة، مو إشعار من سيرفر.
enum RoutineReminders {

    /// تطلب إذن الإشعارات من المستخدمة (مرة وحدة كافية، بيتذكر النظام الجواب)
    /// ولو وافقت، بنسجّل الجهاز فوراً مع آبل عشان يشتغل استقبال إشعارات Push الحقيقية كمان (نفس الإذن)
    static func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion(granted)
            }
        }
    }

    /// يجدول تذكير يومي متكرر لخطوة معيّنة بالوقت المحدد ("HH:mm")
    static func schedule(stepId: String, title: String, time: String) {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return }

        let content = UNMutableNotificationContent()
        content.title = "وقت روتينك ✨"
        content.body = "حان وقت: \(title)"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = parts[0]
        dateComponents.minute = parts[1]

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "routine_step_\(stepId)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    /// يلغي تذكير خطوة معيّنة (لو انمسح أو تعطّل)
    static func cancel(stepId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["routine_step_\(stepId)"])
    }

    /// يعيد مزامنة كل التذكيرات دفعة وحدة بناءً على أحدث بيانات من قاعدة البيانات
    /// (يشيل القديم ويحط الحالي فقط، عشان ما تتراكم تذكيرات قديمة لخطوات محذوفة)
    static func syncAll(with steps: [GlowFitAPI.RoutineStepData]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for step in steps {
            if let time = step.reminder_time, !time.isEmpty {
                schedule(stepId: step.id, title: step.title ?? "خطوة روتينك", time: time)
            }
        }
    }
}
