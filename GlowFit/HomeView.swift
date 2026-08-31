import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .home
    @State private var showNotifications = false
    @State private var showStore = false
    
    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            
            // Background Orbs
            AuthBackgroundView()
            
            VStack(spacing: 0) {
                // Main Content
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeContentView(selectedTab: $selectedTab, showNotifications: $showNotifications, showStore: $showStore)
                    case .scan:
                        SkinScanView()
                    case .reports:
                        ReportsView()
                    case .routine:
                        RoutineView()
                    case .profile:
                        AccountView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showNotifications) { NotificationsView() }
        .sheet(isPresented: $showStore)         { StoreView() }
    }
}

// MARK: - Helper Views

struct HomeContentView: View {
    @Binding var selectedTab: Tab
    @Binding var showNotifications: Bool
    @Binding var showStore: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HomeHeaderView(selectedTab: $selectedTab, showNotifications: $showNotifications)
                
                // Main Score Card
                SkinScoreCard()
                
                // Quick Actions
                QuickActionsView(showStore: $showStore)
                
                // Daily Routine
                DailyRoutineView()
                
                // Bottom Padding for Tab Bar
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

struct HomeHeaderView: View {
    @Binding var selectedTab: Tab
    @Binding var showNotifications: Bool

    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .profile
                }
            }) {
                HStack {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(AuthColors.cardBackground)
                            .frame(width: 45, height: 45)
                            .overlay(
                                Circle().stroke(AuthColors.primaryPurple.opacity(0.4), lineWidth: 2)
                            )
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                    }
                    
                    // Greeting
                    VStack(alignment: .leading, spacing: 2) {
                        Text("مرحباً 👋")
                            .font(.custom("Tajawal-Medium", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                        Text("نورة الأحمد")
                            .font(.custom("Tajawal-Bold", size: 18))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                }
            }
            
            Spacer()
            
            // Notification Bell — tappable
            Button(action: { showNotifications = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(AuthColors.primaryPink, .white)
                }
            }
        }
    }
}

struct SkinScoreCard: View {
    @State private var progressWidth: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("تقييم بشرتك اليوم")
                .font(.custom("Tajawal-Medium", size: 14))
                .foregroundColor(Color.white.opacity(0.6))
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("87")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("/ 100")
                    .font(.custom("Tajawal-Medium", size: 16))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressWidth, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.vertical, 4)
            
            Text("بشرتك بحالة ممتازة! استمري 🌟")
                .font(.custom("Tajawal-Regular", size: 12))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                LinearGradient(
                    colors: [AuthColors.primaryPurple.opacity(0.2), AuthColors.primaryPink.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Blurry Orb
                Circle()
                    .fill(AuthColors.primaryPink.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .offset(x: 80, y: -30) // Positioned top-right
            }
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AuthColors.primaryPurple.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                progressWidth = 0.87
            }
        }
    }
}

struct QuickActionsView: View {
    @Binding var showStore: Bool
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ActionCardView(icon: "👩‍⚕️", title: "استشارة خبير", subtitle: "تحدثي مع أخصائي", action: {})
            ActionCardView(icon: "📊", title: "تقرير مفصّل", subtitle: "نتائج آخر فحص", action: {})
            ActionCardView(icon: "🛍️", title: "منتجات مقترحة", subtitle: "مناسبة لبشرتك", action: { showStore = true })
            ActionCardView(icon: "📅", title: "الروتين اليومي", subtitle: "3 خطوات متبقية", action: {})
        }
    }
}

struct ActionCardView: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(icon)
                    .font(.system(size: 28))
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.custom("Tajawal-Bold", size: 14))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.custom("Tajawal-Regular", size: 11))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.03))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
}

struct DailyRoutineView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("روتينك الصباحي ☀️")
                    .font(.custom("Tajawal-Bold", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Button("عرض الكل") { }
                    .font(.custom("Tajawal-Medium", size: 13))
                    .foregroundColor(AuthColors.primaryPurple)
            }
            
            VStack(spacing: 10) {
                RoutineItemView(icon: "🧴", iconBgColor: AuthColors.primaryPurple.opacity(0.15), title: "غسول الوجه", time: "7:00 صباحاً", isCompleted: true)
                RoutineItemView(icon: "💧", iconBgColor: AuthColors.primaryPink.opacity(0.15), title: "سيروم فيتامين C", time: "7:05 صباحاً", isCompleted: true)
                RoutineItemView(icon: "☀️", iconBgColor: Color.blue.opacity(0.15), title: "واقي الشمس SPF 50", time: "7:10 صباحاً", isCompleted: false)
            }
        }
        .padding(.bottom, 20)
    }
}

struct RoutineItemView: View {
    let icon: String
    let iconBgColor: Color
    let title: String
    let time: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBgColor)
                    .frame(width: 42, height: 42)
                Text(icon)
                    .font(.system(size: 20))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Tajawal-Bold", size: 14))
                    .foregroundColor(.white)
                Text(time)
                    .font(.custom("Tajawal-Regular", size: 12))
                    .foregroundColor(Color.white.opacity(0.3))
            }
            
            Spacer()
            
            // Checkbox
            ZStack {
                Circle()
                    .stroke(isCompleted ? Color.clear : Color.white.opacity(0.15), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Tab Bar Elements

enum Tab {
    case home
    case scan
    case reports
    case routine
    case profile
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Bar Background
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Color(red: 10/255, green: 10/255, blue: 15/255).opacity(0.95)
            }
            .frame(height: 75)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            
            // Tab Bar Items
            HStack(spacing: 0) {
                TabBarItem(icon: "house.fill", title: "الرئيسية", tab: .home, selectedTab: $selectedTab)
                TabBarItem(icon: "chart.bar.fill", title: "التقارير", tab: .reports, selectedTab: $selectedTab)
                
                // Prominent Center Scan Button
                VStack(spacing: 4) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = .scan
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: AuthColors.primaryPurple.opacity(0.4), radius: 10, x: 0, y: 5)
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 2)
                                )
                            
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -20) // Floating effect without getting clipped
                    
                    Text("فحص البشرة")
                        .font(.custom("Tajawal-Medium", size: 10))
                        .foregroundColor(selectedTab == .scan ? AuthColors.primaryPurple : Color.white.opacity(0.3))
                        .offset(y: -12)
                }
                .frame(maxWidth: .infinity)
                
                TabBarItem(icon: "calendar", title: "الروتين", tab: .routine, selectedTab: $selectedTab)
                TabBarItem(icon: "person.fill", title: "حسابي", tab: .profile, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let tab: Tab
    @Binding var selectedTab: Tab
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.custom("Tajawal-Medium", size: 10))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AuthColors.primaryPurple.opacity(0.15) : Color.clear)
            )
            .foregroundColor(isSelected ? AuthColors.primaryPurple : Color.white.opacity(0.3))
        }
    }
}

#Preview {
    HomeView()
}
