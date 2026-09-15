import SwiftUI

// MARK: - Read-state tracking (محلي بس، بسيط وكافي)
enum NotificationReadStore {
    private static let key = "gf_read_notification_ids"

    static func isRead(_ id: String) -> Bool {
        readIds().contains(id)
    }
    static func markRead(_ id: String) {
        var ids = readIds()
        ids.insert(id)
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
    static func markAllRead(_ ids: [String]) {
        var current = readIds()
        ids.forEach { current.insert($0) }
        UserDefaults.standard.set(Array(current), forKey: key)
    }
    private static func readIds() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }
}

// MARK: - Notifications View
struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications: [GlowFitAPI.AppNotification] = []
    @State private var isLoading = true
    @State private var showClearAlert = false
    @State private var selectedFilter = "الكل"

    let filters = ["الكل", "الروتين", "التقارير", "المتجر"]

    private func typeMatches(_ n: GlowFitAPI.AppNotification, _ filter: String) -> Bool {
        switch filter {
        case "الروتين": return n.type == "routine"
        case "التقارير": return n.type == "scan"
        case "المتجر": return n.type == "order"
        default: return true
        }
    }

    var filtered: [GlowFitAPI.AppNotification] {
        selectedFilter == "الكل" ? notifications : notifications.filter { typeMatches($0, selectedFilter) }
    }
    var unread: [GlowFitAPI.AppNotification] { filtered.filter { !NotificationReadStore.isRead($0.id) } }
    var read: [GlowFitAPI.AppNotification] { filtered.filter { NotificationReadStore.isRead($0.id) } }
    var unreadCount: Int { unread.count }

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 0) {
                NotifHeaderView(unreadCount: unreadCount, dismiss: dismiss, onClear: { showClearAlert = true })
                    .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 16)

                NotifFilterBar(filters: filters, selected: $selectedFilter)
                    .padding(.bottom, 12)

                if isLoading {
                    Spacer(); ProgressView().tint(.white); Spacer()
                } else if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Text("🔔").font(.system(size: 52))
                        Text("لا توجد إشعارات").font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                        Text("ستظهر إشعاراتك هنا عند وصولها")
                            .font(.custom("Tajawal-Regular", size: 14)).foregroundColor(Color.white.opacity(0.4))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if !unread.isEmpty {
                                NotifSectionHeader(title: "غير مقروءة", count: unreadCount)
                                ForEach(unread) { notif in
                                    NotifRow(notif: notif, isRead: false)
                                        .onTapGesture { handleTap(notif) }
                                }
                                .padding(.horizontal, 20)
                            }
                            if !read.isEmpty {
                                NotifSectionHeader(title: "السابقة", count: nil)
                                ForEach(read) { notif in
                                    NotifRow(notif: notif, isRead: true)
                                        .onTapGesture { handleTap(notif) }
                                }
                                .padding(.horizontal, 20)
                            }
                            Color.clear.frame(height: 100)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .alert("تحديد الكل كمقروء", isPresented: $showClearAlert) {
            Button("تحديد الكل", role: .destructive) {
                NotificationReadStore.markAllRead(notifications.map { $0.id })
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("هل تريدين تحديد كل الإشعارات كمقروءة؟")
        }
        .onAppear(perform: loadNotifications)
    }

    private func loadNotifications() {
        GlowFitAPI.getNotificationsFeed { fetched in
            notifications = fetched
            isLoading = false
        }
    }

    private func handleTap(_ notif: GlowFitAPI.AppNotification) {
        NotificationReadStore.markRead(notif.id)
        if let route = notif.route {
            let tab: Tab? = {
                switch route {
                case "reports": return .reports
                case "routine": return .routine
                case "store": return .home // المتجر بيتفتح كـ sheet من الرئيسية
                case "home": return .home
                default: return nil
                }
            }()
            if let tab = tab {
                NotificationRouter.shared.pendingTab = tab
                dismiss()
            }
        }
    }
}

// MARK: - Header
struct NotifHeaderView: View {
    let unreadCount: Int
    var dismiss: DismissAction
    let onClear: () -> Void

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            Spacer()
            VStack(spacing: 2) {
                Text("الإشعارات")
                    .font(.custom("Tajawal-Bold", size: 20))
                    .foregroundColor(.white)
                if unreadCount > 0 {
                    Text("\(unreadCount) غير مقروءة")
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(AuthColors.primaryPink)
                }
            }
            Spacer()
            Button(action: onClear) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - Filter Bar
struct NotifFilterBar: View {
    let filters: [String]
    @Binding var selected: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { f in
                    Button(action: { withAnimation { selected = f } }) {
                        Text(f)
                            .font(.custom("Tajawal-Bold", size: 13))
                            .foregroundColor(selected == f ? .white : Color.white.opacity(0.4))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selected == f
                                    ? LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                     startPoint: .leading, endPoint: .trailing).cornerRadius(20)
                                    : LinearGradient(colors: [Color.white.opacity(0.05)],
                                                     startPoint: .leading, endPoint: .trailing).cornerRadius(20)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Section Header
struct NotifSectionHeader: View {
    let title: String
    let count: Int?
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.custom("Tajawal-Bold", size: 14))
                .foregroundColor(Color.white.opacity(0.5))
            if let count = count {
                ZStack {
                    Circle().fill(AuthColors.primaryPink).frame(width: 20, height: 20)
                    Text("\(count)").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Notification Row
struct NotifRow: View {
    let notif: GlowFitAPI.AppNotification
    let isRead: Bool

    private var icon: String {
        switch notif.type {
        case "scan": return "🔬"
        case "order": return "🛍️"
        case "routine": return "☀️"
        default: return "🔔"
        }
    }
    private var iconBg: Color {
        switch notif.type {
        case "scan": return Color(red: 0.58, green: 0.20, blue: 0.92).opacity(0.2)
        case "order": return Color(red: 0.93, green: 0.28, blue: 0.60).opacity(0.2)
        case "routine": return Color(red: 0.98, green: 0.75, blue: 0.14).opacity(0.2)
        default: return AuthColors.primaryPurple.opacity(0.2)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(iconBg).frame(width: 48, height: 48)
                Text(icon).font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Text(notif.title)
                        .font(.custom("Tajawal-Bold", size: 14))
                        .foregroundColor(isRead ? Color.white.opacity(0.6) : .white)
                        .lineLimit(2)
                    Spacer()
                    if !isRead {
                        Circle().fill(AuthColors.primaryPink).frame(width: 8, height: 8).padding(.top, 4)
                    }
                }
                Text(notif.body)
                    .font(.custom("Tajawal-Regular", size: 12))
                    .foregroundColor(Color.white.opacity(isRead ? 0.3 : 0.55))
                    .lineSpacing(3)
                    .lineLimit(3)
                Text(GlowFitAPI.humanRelativeDate(notif.created_at))
                    .font(.custom("Tajawal-Regular", size: 11))
                    .foregroundColor(Color.white.opacity(0.25))
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(isRead ? Color.white.opacity(0.02) : AuthColors.primaryPurple.opacity(0.06))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isRead ? Color.white.opacity(0.04) : AuthColors.primaryPurple.opacity(0.15), lineWidth: 1)
        )
        .padding(.bottom, 8)
        .contentShape(Rectangle())
    }
}
