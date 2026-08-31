import SwiftUI

// MARK: - Notification Model
struct AppNotification: Identifiable {
    let id = UUID()
    let icon: String
    let iconBg: Color
    let title: String
    let body: String
    let time: String
    let type: NotifType
    var isRead: Bool

    enum NotifType { case routine, report, tip, promo, system }
}

extension AppNotification {
    static var samples: [AppNotification] = [
        AppNotification(icon: "🔬", iconBg: Color(red:0.58,green:0.20,blue:0.92).opacity(0.2),
                        title: "نتيجة فحصك جاهزة ✨", body: "حليلة بشرتك لليوم جاهزة. النتيجة: 87/100 – بشرة مشرقة وصحية!",
                        time: "الآن", type: .report, isRead: false),
        AppNotification(icon: "☀️", iconBg: Color(red:0.98,green:0.75,blue:0.14).opacity(0.2),
                        title: "وقت الروتين الصباحي", body: "لا تنسي خطوة واقي الشمس اليوم ☀️ 3 خطوات متبقية",
                        time: "منذ 15 د", type: .routine, isRead: false),
        AppNotification(icon: "💧", iconBg: Color(red:0.15,green:0.60,blue:0.98).opacity(0.2),
                        title: "نصيحة من خبير الذكاء الاصطناعي", body: "مستوى ترطيب بشرتك انخفض قليلاً هذا الأسبوع، نوصي بزيادة استخدام السيروم",
                        time: "منذ ساعة", type: .tip, isRead: true),
        AppNotification(icon: "🛍️", iconBg: Color(red:0.93,green:0.28,blue:0.60).opacity(0.2),
                        title: "منتجات جديدة لك!", body: "أضفنا 4 منتجات جديدة تتطابق مع بشرتك بنسبة +90%. اكتشفيها الآن",
                        time: "منذ 3 س", type: .promo, isRead: true),
        AppNotification(icon: "🌙", iconBg: Color(red:0.29,green:0.77,blue:0.50).opacity(0.2),
                        title: "تذكير الروتين المسائي", body: "حان وقت روتينك المسائي! 4 خطوات لبشرة مثالية أثناء النوم 🌙",
                        time: "أمس", type: .routine, isRead: true),
        AppNotification(icon: "📊", iconBg: Color(red:0.58,green:0.20,blue:0.92).opacity(0.2),
                        title: "تقريرك الأسبوعي", body: "تقرير بشرتك لهذا الأسبوع جاهز. تحسن بنسبة +4 نقاط مقارنة بالأسبوع الماضي",
                        time: "أمس", type: .report, isRead: true),
        AppNotification(icon: "⭐️", iconBg: Color(red:0.98,green:0.75,blue:0.14).opacity(0.2),
                        title: "قيّمي تجربتك", body: "كيف كانت تجربتك مع GlowFit AI هذا الأسبوع؟ شاركينا رأيك",
                        time: "منذ يومين", type: .system, isRead: true),
    ]
}

// MARK: - Notifications View
struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications = AppNotification.samples
    @State private var showClearAlert = false

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 0) {

                // ─── Header ───
                NotifHeaderView(unreadCount: unreadCount, dismiss: dismiss, onClear: {
                    showClearAlert = true
                })
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)

                // ─── Filter Tabs ───
                NotifFilterBar(notifications: $notifications)
                    .padding(.bottom, 12)

                if notifications.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Text("🔔").font(.system(size: 52))
                        Text("لا توجد إشعارات")
                            .font(.custom("Tajawal-Bold", size: 18))
                            .foregroundColor(.white)
                        Text("ستظهر إشعاراتك هنا عند وصولها")
                            .font(.custom("Tajawal-Regular", size: 14))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Unread Section
                            if notifications.contains(where: { !$0.isRead }) {
                                NotifSectionHeader(title: "غير مقروءة", count: unreadCount)
                                ForEach($notifications.filter { !$0.wrappedValue.isRead }) { $notif in
                                    NotifRow(notif: $notif)
                                        .onTapGesture {
                                            withAnimation { notif.isRead = true }
                                        }
                                }
                                .padding(.horizontal, 20)
                            }

                            // Read Section
                            if notifications.contains(where: { $0.isRead }) {
                                NotifSectionHeader(title: "السابقة", count: nil)
                                ForEach($notifications.filter { $0.wrappedValue.isRead }) { $notif in
                                    NotifRow(notif: $notif)
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
        .alert("مسح الإشعارات", isPresented: $showClearAlert) {
            Button("مسح الكل", role: .destructive) {
                withAnimation { notifications.removeAll() }
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("هل تريدين مسح جميع الإشعارات؟")
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
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - Filter Bar
struct NotifFilterBar: View {
    @Binding var notifications: [AppNotification]
    @State private var selected: String = "الكل"
    let filters = ["الكل", "الروتين", "التقارير", "نصائح", "عروض"]

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
                    Circle()
                        .fill(AuthColors.primaryPink)
                        .frame(width: 20, height: 20)
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
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
    @Binding var notif: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(notif.iconBg)
                    .frame(width: 48, height: 48)
                Text(notif.icon).font(.system(size: 22))
            }

            // Content
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Text(notif.title)
                        .font(.custom("Tajawal-Bold", size: 14))
                        .foregroundColor(notif.isRead ? Color.white.opacity(0.6) : .white)
                        .lineLimit(2)
                    Spacer()
                    if !notif.isRead {
                        Circle()
                            .fill(AuthColors.primaryPink)
                            .frame(width: 8, height: 8)
                            .padding(.top, 4)
                    }
                }
                Text(notif.body)
                    .font(.custom("Tajawal-Regular", size: 12))
                    .foregroundColor(Color.white.opacity(notif.isRead ? 0.3 : 0.55))
                    .lineSpacing(3)
                    .lineLimit(3)
                Text(notif.time)
                    .font(.custom("Tajawal-Regular", size: 11))
                    .foregroundColor(Color.white.opacity(0.25))
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(notif.isRead ? Color.white.opacity(0.02) : AuthColors.primaryPurple.opacity(0.06))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(notif.isRead ? Color.white.opacity(0.04) : AuthColors.primaryPurple.opacity(0.15), lineWidth: 1)
        )
        .padding(.bottom, 8)
        .contentShape(Rectangle())
    }
}

#Preview { NotificationsView() }
