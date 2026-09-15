import Foundation
import Combine

/// وسيط بسيط بين الإشعارات (اللي بتتعامل معها AppDelegate) والواجهة (HomeView) —
/// لما المستخدمة تضغط على إشعار، بنسجّل هون "لوين لازم ننقلها"، والواجهة بتراقب هاد المتغيّر وتنفّذ الانتقال
final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()
    private init() {}

    @Published var pendingTab: Tab? = nil
}
