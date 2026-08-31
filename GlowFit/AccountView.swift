import SwiftUI

// MARK: - Account (My Profile) Main View
struct AccountView: View {
    @State private var showEditProfile    = false
    @State private var showNotifications  = false
    @State private var showLanguage       = false
    @State private var showPrivacy        = false
    @State private var showHelp           = false
    @State private var showLogoutAlert    = false
    @State private var showSubscription   = false
    @State private var showSkinUpdate     = false
    @State private var showOrders         = false
    @State private var notificationsOn    = true

    @State private var profile: GlowFitAPI.GFProfile? = nil
    @State private var isLoadingProfile = true

    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    AccountHeaderView(showEditProfile: $showEditProfile)
                    UserAvatarSection(showEditProfile: $showEditProfile, profile: profile, isLoading: isLoadingProfile)
                    if profile?.subscription_tier == "premium" {
                        PremiumBannerView(showSubscription: $showSubscription)
                    }
                    SkinProfileSection(showSkinUpdate: $showSkinUpdate, profile: profile)
                    SettingsSection(
                        notificationsOn: $notificationsOn,
                        showNotifications: $showNotifications,
                        showLanguage: $showLanguage,
                        showPrivacy: $showPrivacy,
                        showHelp: $showHelp,
                        showOrders: $showOrders
                    )
                    .onChange(of: notificationsOn) { newValue in
                        GlowFitAPI.updateNotifications(enabled: newValue) { _ in }
                    }
                    LogoutButton(showAlert: $showLogoutAlert)
                    Text("GlowFit AI • الإصدار 2.1.0")
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(Color.white.opacity(0.2))
                        .padding(.bottom, 10)
                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showEditProfile)  { EditProfileView() }
        .sheet(isPresented: $showNotifications){ NotificationsSettingsView() }
        .sheet(isPresented: $showLanguage)     { LanguageSettingsView() }
        .sheet(isPresented: $showPrivacy)      { PrivacySettingsView() }
        .sheet(isPresented: $showHelp)         { HelpSupportView() }
        .sheet(isPresented: $showSubscription) { SubscriptionManagementView() }
        .sheet(isPresented: $showSkinUpdate)   { SkinTypeUpdateView() }
        .fullScreenCover(isPresented: $showOrders) { OrdersView() }
        .alert("تسجيل الخروج", isPresented: $showLogoutAlert) {
            Button("تسجيل الخروج", role: .destructive) {
                GlowFitAPI.signOut()
                isLoggedIn = false
            }
            Button("إلغاء", role: .cancel) {}
        } message: { Text("هل أنت متأكد من تسجيل الخروج؟") }
        .onAppear(perform: loadProfile)
    }

    private func loadProfile() {
        isLoadingProfile = true
        GlowFitAPI.fetchMyProfile { result in
            isLoadingProfile = false
            switch result {
            case .success(let p):
                profile = p
                notificationsOn = p.notifications_enabled ?? true
            case .failure:
                break // بيبقى العرض الافتراضي لو فشل التحميل (بدون ما نكسر الشاشة)
            }
        }
    }
}

// MARK: - Header
struct AccountHeaderView: View {
    @Binding var showEditProfile: Bool
    var body: some View {
        HStack {
            Spacer()
            Text("الملف الشخصي")
                .font(.custom("Tajawal-Bold", size: 20))
                .foregroundColor(.white)
            Spacer()
            Button(action: { showEditProfile = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1))
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - User Avatar Section
struct UserAvatarSection: View {
    @Binding var showEditProfile: Bool
    var profile: GlowFitAPI.GFProfile?
    var isLoading: Bool

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                // Avatar ring
                ZStack {
                    Circle()
                        .stroke(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        .frame(width: 106, height: 106)
                    Circle()
                        .fill(Color(red: 0.1, green: 0.08, blue: 0.15))
                        .frame(width: 100, height: 100)
                    Text("👩🏻")
                        .font(.system(size: 48))
                }
                // Camera badge
                Button(action: { showEditProfile = true }) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(AuthColors.background, lineWidth: 2))
                        Image(systemName: "camera.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 4, y: 4)
            }

            VStack(spacing: 4) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(profile?.full_name?.isEmpty == false ? profile!.full_name! : "بدون اسم")
                        .font(.custom("Tajawal-Bold", size: 22))
                        .foregroundColor(.white)
                    Text(profile?.email ?? (GlowFitAPI.currentUserId != nil ? "" : "—"))
                        .font(.custom("Tajawal-Regular", size: 14))
                        .foregroundColor(Color.white.opacity(0.4))
                }
            }
        }
    }
}

// MARK: - Premium Banner
struct PremiumBannerView: View {
    @Binding var showSubscription: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("GlowFit Premium ✨")
                    .font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                Text("تتمتعين بكافة ميزات الذكاء الاصطناعي")
                    .font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.6))
            }
            Spacer()
            Button(action: { showSubscription = true }) {
                Text("إدارة الاشتراك")
                    .font(.custom("Tajawal-Bold", size: 13)).foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(ZStack {
            LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.2), AuthColors.primaryPink.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(AuthColors.primaryPink.opacity(0.2)).frame(width: 150, height: 150).blur(radius: 40).offset(x: 60, y: -20)
        })
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AuthColors.primaryPurple.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Skin Profile Section
struct SkinProfileSection: View {
    @Binding var showSkinUpdate: Bool
    var profile: GlowFitAPI.GFProfile?

    private static let concernLabels: [String: (icon: String, label: String)] = [
        "acne_prone": ("🔴", "عرضة للحبوب"),
        "dark_circles": ("👁", "هالات سوداء"),
        "sensitive": ("✨", "حساسة"),
        "dryness": ("🏜", "جفاف"),
        "wrinkles": ("〰️", "خطوط دقيقة"),
        "pigmentation": ("🟤", "تصبغات")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ملف البشرة").font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
            VStack(spacing: 16) {
                HStack {
                    Text("نوع البشرة الحالي").font(.custom("Tajawal-Regular", size: 14)).foregroundColor(Color.white.opacity(0.6))
                    Spacer()
                    Button(action: { showSkinUpdate = true }) {
                        Text("تحديث").font(.custom("Tajawal-Bold", size: 13)).foregroundColor(AuthColors.primaryPurple)
                    }
                }
                if let skinType = profile?.skin_type, !skinType.isEmpty {
                    FlowLayout(spacing: 10) {
                        SkinTag(icon: "💧", label: skinType, isPrimary: true)
                        ForEach(profile?.skin_concerns ?? [], id: \.self) { concern in
                            let info = Self.concernLabels[concern] ?? ("🏷", concern)
                            SkinTag(icon: info.icon, label: info.label, isPrimary: false)
                        }
                    }
                } else {
                    Text("لسا ما سويتِ فحص بشرة — دوسي 'تحديث' لتبدئي")
                        .font(.custom("Tajawal-Regular", size: 13))
                        .foregroundColor(Color.white.opacity(0.35))
                }
            }
            .padding(20).background(Color.white.opacity(0.03)).cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
        }
    }
}

struct SkinTag: View {
    let icon: String; let label: String; let isPrimary: Bool
    var body: some View {
        HStack(spacing: 6) {
            Text(icon); Text(label).font(.custom("Tajawal-Regular", size: 13))
        }
        .foregroundColor(isPrimary ? Color(red: 0.75, green: 0.52, blue: 0.99) : Color.white.opacity(0.8))
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(isPrimary ? AuthColors.primaryPurple.opacity(0.15) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(isPrimary ? AuthColors.primaryPurple.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1))
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0; var y: CGFloat = 0; var maxH: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += maxH + spacing; maxH = 0 }
            x += size.width + spacing; maxH = max(maxH, size.height)
        }
        return CGSize(width: width, height: y + maxH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX; var y = bounds.minY; var maxH: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += maxH + spacing; maxH = 0 }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing; maxH = max(maxH, size.height)
        }
    }
}

// MARK: - Settings Section
struct SettingsSection: View {
    @Binding var notificationsOn: Bool
    @Binding var showNotifications: Bool
    @Binding var showLanguage: Bool
    @Binding var showPrivacy: Bool
    @Binding var showHelp: Bool
    @Binding var showOrders: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("الإعدادات")
                .font(.custom("Tajawal-Bold", size: 16))
                .foregroundColor(.white)

            VStack(spacing: 0) {
                // Orders
                SettingsRow(
                    icon: "shippingbox.fill", iconBg: AuthColors.primaryPink.opacity(0.15), iconColor: AuthColors.primaryPink,
                    title: "طلباتي", subtitle: "تتبع حالة طلباتك والمشتريات"
                ) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14)).foregroundColor(Color.white.opacity(0.3))
                }
                .onTapGesture { showOrders = true }

                Divider().background(Color.white.opacity(0.04))

                // Notifications (toggle)
                SettingsRow(
                    icon: "bell.fill", iconBg: Color.orange.opacity(0.15), iconColor: .orange,
                    title: "الإشعارات والتذكير", subtitle: "تذكير بالروتين اليومي"
                ) {
                    Toggle("", isOn: $notificationsOn)
                        .tint(AuthColors.primaryPurple)
                        .labelsHidden()
                }
                .onTapGesture { showNotifications = true }

                Divider().background(Color.white.opacity(0.04))

                // Language
                SettingsRow(
                    icon: "globe", iconBg: Color.blue.opacity(0.15), iconColor: .blue,
                    title: "لغة التطبيق", subtitle: "العربية"
                ) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14)).foregroundColor(Color.white.opacity(0.3))
                }
                .onTapGesture { showLanguage = true }

                Divider().background(Color.white.opacity(0.04))

                // Privacy
                SettingsRow(
                    icon: "lock.fill", iconBg: Color.green.opacity(0.15), iconColor: .green,
                    title: "الخصوصية والأمان", subtitle: "كلمة المرور، البصمة"
                ) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14)).foregroundColor(Color.white.opacity(0.3))
                }
                .onTapGesture { showPrivacy = true }

                Divider().background(Color.white.opacity(0.04))

                // Help
                SettingsRow(
                    icon: "questionmark.circle.fill", iconBg: Color.purple.opacity(0.15), iconColor: .purple,
                    title: "المساعدة والدعم", subtitle: "الأسئلة الشائعة، تواصل معنا"
                ) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14)).foregroundColor(Color.white.opacity(0.3))
                }
                .onTapGesture { showHelp = true }
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
        }
    }
}

struct SettingsRow<Action: View>: View {
    let icon: String; let iconBg: Color; let iconColor: Color
    let title: String; let subtitle: String
    @ViewBuilder let action: () -> Action

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(iconBg).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.custom("Tajawal-Medium", size: 15)).foregroundColor(.white)
                Text(subtitle).font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
            }
            Spacer()
            action()
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

// MARK: - Logout Button
struct LogoutButton: View {
    @Binding var showAlert: Bool
    var body: some View {
        Button(action: { showAlert = true }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red.opacity(0.1)).frame(width: 36, height: 36)
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16)).foregroundColor(.red)
                }
                Text("تسجيل الخروج")
                    .font(.custom("Tajawal-Medium", size: 15))
                    .foregroundColor(Color(red: 0.99, green: 0.64, blue: 0.64))
                Spacer()
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
            .background(Color.white.opacity(0.03))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
        }
    }
}

#Preview { AccountView() }
