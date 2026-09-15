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
    static func schedule(stepId: String, title: String, time: String, isMorning: Bool) {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return }

        let content = UNMutableNotificationContent()
        content.title = isMorning ? "روتينك الصباحي ☀️" : "روتينك المسائي 🌙"
        content.body = "حان وقت: \(title) — دوسي هون لتفتحي روتينك"
        content.sound = .default
        content.userInfo = ["route": "routine"] // عشان لما تضغط عليه ننقّلها لصفحة الروتين مباشرة

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
    static func syncAll(with steps: [GlowFitAPI.RoutineStepData], routines: [GlowFitAPI.RoutineData]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let morningRoutineIds = Set(routines.filter { $0.time_of_day == "morning" }.map { $0.id })
        for step in steps {
            if let time = step.reminder_time, !time.isEmpty {
                let isMorning = morningRoutineIds.contains(step.routine_id)
                schedule(stepId: step.id, title: step.title ?? "خطوة روتينك", time: time, isMorning: isMorning)
            }
        }
    }
}
