import SwiftUI

// MARK: - OnboardingView
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    // الألوان المتدرجة لكل صفحة
    let backgroundColors: [[Color]] = [
        [Color.purple.opacity(0.15), Color.purple.opacity(0.05)],
        [Color.pink.opacity(0.15), Color.pink.opacity(0.05)],
        [Color.blue.opacity(0.15), Color.blue.opacity(0.05)]
    ]
    
    var body: some View {
        ZStack {
            // الخلفية الأساسية
            Color(red: 10/255, green: 10/255, blue: 15/255)
                .ignoresSafeArea()
            
            // التدرجات المتغيرة حسب الصفحة
            AnimatedBackground(colors: backgroundColors[currentPage], isAnimating: isAnimating)
            
            // جسيمات عائمة
            ParticleSystem() // ملاحظة: نستخدم نفس الـ ParticleSystem من ملف SplashView
            
            VStack(spacing: 0) {
                // شريط الحالة الوهمي ومساحة علوية
                Spacer().frame(height: 50)
                
                // صفحات الترحيب
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        iconName: "viewfinder",
                        iconColor: .purple,
                        title: "فحص ذكي لبشرتك",
                        description: "مسح ضوئي دقيق باستخدام الذكاء الاصطناعي لتحليل بشرتك وفهم احتياجاتها في ثوانٍ.",
                        pills: ["🤖 ذكاء اصطناعي", "📸 تحليل فوري", "✨ دقة عالية"]
                    ).tag(0)
                    
                    OnboardingPage(
                        iconName: "chart.pie.fill",
                        iconColor: .pink,
                        title: "نقاط تقييم البشرة",
                        description: "احصلي على تقييم تفصيلي لصحة بشرتك مع تحليل دقيق للمسامات، الهالات، ونضارة الوجه.",
                        pills: ["📊 تقييم شامل", "🔍 تحليل دقيق", "💡 نصائح ذكية"]
                    ).tag(1)
                    
                    OnboardingPage(
                        iconName: "calendar.badge.clock",
                        iconColor: .blue,
                        title: "روتين مخصص لكِ",
                        description: "جدول عناية يومي مصمم خصيصاً ليناسب نوع بشرتك، مع تتبع مستمر للنتائج وتطور صحة البشرة.",
                        pills: ["📅 روتين يومي", "📈 تتبع التقدم", "🌟 نتائج ملحوظة"]
                    ).tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // شريط التنقل السفلي
                BottomNavigation(
                    currentPage: $currentPage,
                    totalPages: 3,
                    primaryColor: getPrimaryColor(for: currentPage),
                    onNext: {
                        if currentPage < 2 {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        } else {
                            // TODO: الانتقال إلى الشاشة الرئيسية أو شاشة التسجيل
                            finishOnboarding()
                        }
                    },
                    onSkip: {
                        finishOnboarding()
                    }
                )
                .padding(.bottom, 40)
                .padding(.horizontal, 30)
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // دعم اللغة العربية
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private func getPrimaryColor(for page: Int) -> Color {
        switch page {
        case 0: return .purple
        case 1: return .pink
        case 2: return .blue
        default: return .purple
        }
    }
    
    private func finishOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}

// MARK: - Onboarding Page Content
struct OnboardingPage: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String
    let pills: [String]
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var iconBounce: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // الأيقونة الدائرية
            ZStack {
                Circle()
                    .stroke(iconColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 280, height: 280)
                
                Circle()
                    .stroke(iconColor.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(width: 320, height: 320)
                    .rotationEffect(.degrees(opacity == 1 ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: opacity)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.2), iconColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 220, height: 220)
                    .shadow(color: iconColor.opacity(0.3), radius: 30)
                
                Image(systemName: iconName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(iconColor)
                    .shadow(color: iconColor.opacity(0.5), radius: 15)
                    .offset(y: iconBounce)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            
            Spacer().frame(height: 10)
            
            // النصوص
            VStack(spacing: 16) {
                Text(title)
                    .font(.custom("Tajawal-Black", size: 30, relativeTo: .title))
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(description)
                    .font(.custom("Tajawal-Regular", size: 17, relativeTo: .body))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                
                // الوسوم (Pills)
                HStack(spacing: 10) {
                    ForEach(pills, id: \.self) { pill in
                        Text(pill)
                            .font(.custom("Tajawal-Medium", size: 13))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(iconColor.opacity(0.1))
                            .foregroundColor(iconColor.opacity(0.9))
                            .overlay(
                                Capsule().stroke(iconColor.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 10)
            }
            .opacity(opacity)
            .offset(y: opacity == 1 ? 0 : 20)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                iconBounce = -10
            }
        }
        .onDisappear {
            scale = 0.8
            opacity = 0
            iconBounce = 0
        }
    }
}

// MARK: - Bottom Navigation
struct BottomNavigation: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let primaryColor: Color
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        HStack {
            // زر التخطي
            Button(action: onSkip) {
                Text("تخطي")
                    .font(.custom("Tajawal-Medium", size: 16))
                    .foregroundColor(.white.opacity(0.5))
            }
            .opacity(currentPage == totalPages - 1 ? 0 : 1) // إخفاء في آخر صفحة
            
            Spacer()
            
            // نقاط الصفحات (Page Indicators)
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? primaryColor : Color.white.opacity(0.2))
                        .frame(width: currentPage == index ? 24 : 8, height: 8)
                        .animation(.spring(), value: currentPage)
                }
            }
            
            Spacer()
            
            // زر التالي / ابدأ
            Button(action: onNext) {
                Text(currentPage == totalPages - 1 ? "ابدأ الآن" : "التالي")
                    .font(.custom("Tajawal-Bold", size: 17))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [primaryColor, primaryColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: primaryColor.opacity(0.4), radius: 10, y: 5)
            }
        }
    }
}

// MARK: - Animated Background helper
struct AnimatedBackground: View {
    let colors: [Color]
    let isAnimating: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colors[0])
                .frame(width: 350)
                .blur(radius: 80)
                .offset(x: isAnimating ? 50 : -50, y: isAnimating ? -100 : -150)
            
            Circle()
                .fill(colors[1])
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: isAnimating ? -100 : 50, y: isAnimating ? 150 : 200)
        }
        .animation(.easeInOut(duration: 4), value: colors)
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.dark)
    }
}
