import SwiftUI

// MARK: - Routine View
struct RoutineView: View {
    @State private var selectedSegment: RoutineSegment = .morning
    @State private var steps: [RoutineStep] = RoutineStep.morningSteps
    @State private var currentStreak = 12
    @State private var showAddStep  = false

    var completedCount: Int { steps.filter(\.isDone).count }
    var progress: Double { steps.isEmpty ? 0 : Double(completedCount) / Double(steps.count) }

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // ─── Header ───
                    RoutineHeaderView(showAddStep: $showAddStep)

                    // ─── Segment ───
                    RoutineSegmentPicker(selected: $selectedSegment) { seg in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            steps = seg == .morning ? RoutineStep.morningSteps : RoutineStep.eveningSteps
                        }
                    }

                    // ─── Progress Card ───
                    RoutineProgressCard(
                        completed: completedCount,
                        total: steps.count,
                        progress: progress,
                        streak: currentStreak
                    )

                    // ─── Steps List ───
                    RoutineStepsSection(steps: $steps)

                    // ─── Tips Card ───
                    RoutineTipsCard(segment: selectedSegment)

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showAddStep) {
            AddStepSheet()
        }
    }
}

// MARK: - Segment
enum RoutineSegment: String, CaseIterable {
    case morning = "الصباح ☀️"
    case evening = "المساء 🌙"
}

// MARK: - Model
struct RoutineStep: Identifiable {
    let id = UUID()
    let icon: String
    let iconBg: Color
    let title: String
    let subtitle: String
    let time: String
    var isDone: Bool

    static var morningSteps: [RoutineStep] = [
        RoutineStep(icon: "🧼", iconBg: Color(red:0.58,green:0.20,blue:0.92).opacity(0.18), title: "غسول الوجه",       subtitle: "CeraVe Hydrating Cleanser",        time: "7:00 ص",  isDone: true),
        RoutineStep(icon: "💧", iconBg: Color(red:0.93,green:0.28,blue:0.60).opacity(0.18), title: "سيروم فيتامين C",  subtitle: "TruSkin Vitamin C Serum",          time: "7:05 ص",  isDone: true),
        RoutineStep(icon: "🧴", iconBg: Color(red:0.15,green:0.60,blue:0.98).opacity(0.18), title: "مرطب اليوم",       subtitle: "Neutrogena Hydro Boost",           time: "7:10 ص",  isDone: false),
        RoutineStep(icon: "☀️", iconBg: Color(red:0.98,green:0.75,blue:0.14).opacity(0.18), title: "واقي الشمس SPF 50",subtitle: "La Roche-Posay Anthelios",         time: "7:15 ص",  isDone: false),
    ]

    static var eveningSteps: [RoutineStep] = [
        RoutineStep(icon: "🫧", iconBg: Color(red:0.58,green:0.20,blue:0.92).opacity(0.18), title: "إزالة المكياج",    subtitle: "Bioderma Micellar Water",          time: "9:30 م",  isDone: false),
        RoutineStep(icon: "🧼", iconBg: Color(red:0.93,green:0.28,blue:0.60).opacity(0.18), title: "غسول الليل",       subtitle: "CeraVe Foaming Cleanser",         time: "9:35 م",  isDone: false),
        RoutineStep(icon: "🌿", iconBg: Color(red:0.29,green:0.77,blue:0.50).opacity(0.18), title: "سيروم الريتينول",  subtitle: "Olay Regenerist Retinol 24",      time: "9:40 م",  isDone: false),
        RoutineStep(icon: "🍯", iconBg: Color(red:0.15,green:0.60,blue:0.98).opacity(0.18), title: "كريم الليل",       subtitle: "CeraVe Moisturizing Cream",       time: "9:45 م",  isDone: false),
    ]
}

// MARK: - Header
struct RoutineHeaderView: View {
    @Binding var showAddStep: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("روتين العناية")
                    .font(.custom("Tajawal-Bold", size: 22))
                    .foregroundColor(.white)
                Text("خطواتك اليومية للبشرة")
                    .font(.custom("Tajawal-Regular", size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            Spacer()
            Button(action: { showAddStep = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Segment Picker
struct RoutineSegmentPicker: View {
    @Binding var selected: RoutineSegment
    var onChange: (RoutineSegment) -> Void
    var body: some View {
        HStack(spacing: 0) {
            ForEach(RoutineSegment.allCases, id: \.self) { seg in
                Button(action: {
                    selected = seg
                    onChange(seg)
                }) {
                    Text(seg.rawValue)
                        .font(.custom("Tajawal-Bold", size: 14))
                        .foregroundColor(selected == seg ? .white : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            Group {
                                if selected == seg {
                                    LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.55), AuthColors.primaryPink.opacity(0.35)],
                                                   startPoint: .leading, endPoint: .trailing)
                                    .cornerRadius(10)
                                } else { Color.clear }
                            }
                        )
                }
            }
        }
        .padding(5)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}

// MARK: - Progress Card
struct RoutineProgressCard: View {
    let completed: Int
    let total: Int
    let progress: Double
    let streak: Int
    @State private var animated = false

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(completed) / \(total)")
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("خطوات مكتملة اليوم")
                        .font(.custom("Tajawal-Regular", size: 13))
                        .foregroundColor(Color.white.opacity(0.45))
                }
                Spacer()
                // Streak Badge
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(red:0.98,green:0.75,blue:0.14).opacity(0.15))
                            .frame(width: 52, height: 52)
                        Text("🔥")
                            .font(.system(size: 26))
                    }
                    Text("\(streak) يوم")
                        .font(.custom("Tajawal-Bold", size: 12))
                        .foregroundColor(Color(red:0.98,green:0.75,blue:0.14))
                }
            }
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.07)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * (animated ? progress : 0), height: 8)
                        .animation(.easeOut(duration: 1.0).delay(0.2), value: animated)
                }
            }
            .frame(height: 8)

            HStack {
                Label("تقدم رائع! استمري 💪", systemImage: "sparkles")
                    .font(.custom("Tajawal-Medium", size: 12))
                    .foregroundColor(AuthColors.primaryPurple)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.custom("Tajawal-Bold", size: 12))
                    .foregroundColor(AuthColors.primaryPink)
            }
        }
        .padding(22)
        .background(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.15), AuthColors.primaryPink.opacity(0.1)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AuthColors.primaryPurple.opacity(0.2), lineWidth: 1))
        .onAppear { withAnimation { animated = true } }
    }
}

// MARK: - Steps Section
struct RoutineStepsSection: View {
    @Binding var steps: [RoutineStep]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("📋").font(.system(size: 16))
                Text("الخطوات").font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
            }
            VStack(spacing: 10) {
                ForEach($steps) { $step in
                    RoutineStepCard(step: $step)
                        .transition(.asymmetric(insertion: .slide, removal: .opacity))
                }
            }
        }
    }
}

// MARK: - Step Card
struct RoutineStepCard: View {
    @Binding var step: RoutineStep
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(step.iconBg)
                    .frame(width: 48, height: 48)
                Text(step.icon).font(.system(size: 22))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.custom("Tajawal-Bold", size: 15))
                    .foregroundColor(step.isDone ? Color.white.opacity(0.5) : .white)
                    .strikethrough(step.isDone, color: Color.white.opacity(0.3))
                Text(step.subtitle)
                    .font(.custom("Tajawal-Regular", size: 12))
                    .foregroundColor(Color.white.opacity(0.3))
            }

            Spacer()

            // Time
            Text(step.time)
                .font(.custom("Tajawal-Regular", size: 11))
                .foregroundColor(Color.white.opacity(0.3))

            // Check
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    step.isDone.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(step.isDone ? Color.clear : Color.white.opacity(0.15), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if step.isDone {
                        Circle()
                            .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(step.isDone ? Color.white.opacity(0.02) : Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(step.isDone ? AuthColors.primaryPurple.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Tips Card
struct RoutineTipsCard: View {
    let segment: RoutineSegment
    var tipText: String {
        segment == .morning
            ? "نصيحة: ضعي واقي الشمس كآخر خطوة قبل الخروج بـ 15 دقيقة لأفضل حماية ☀️"
            : "نصيحة: تجنبي لمس وجهك بعد الريتينول واتركيه يمتص بالكامل قبل النوم 🌙"
    }
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.2), AuthColors.primaryPink.opacity(0.2)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)
                Text("💡").font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("نصيحة اليوم")
                    .font(.custom("Tajawal-Bold", size: 14))
                    .foregroundColor(.white)
                Text(tipText)
                    .font(.custom("Tajawal-Regular", size: 13))
                    .foregroundColor(Color.white.opacity(0.65))
                    .lineSpacing(4)
            }
        }
        .padding(18)
        .background(LinearGradient(colors: [Color.blue.opacity(0.08), AuthColors.primaryPurple.opacity(0.08)],
                                   startPoint: .leading, endPoint: .trailing))
        .cornerRadius(18)
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: 4).fill(AuthColors.primaryPurple).frame(width: 4)
                Spacer()
            }, alignment: .leading
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AuthColors.primaryPurple.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Add Step Sheet
struct AddStepSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var stepTitle = ""
    @State private var stepTime  = ""

    var body: some View {
        AccountSheet(title: "إضافة خطوة جديدة") {
            VStack(spacing: 16) {
                CustomTextField(icon: "✏️", placeholder: "اسم الخطوة", text: $stepTitle)
                CustomTextField(icon: "⏰", placeholder: "الوقت (مثال: 8:00 ص)", text: $stepTime)
                Button(action: { dismiss() }) {
                    Text("إضافة الخطوة")
                        .font(.custom("Tajawal-Bold", size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                   startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(14)
                }
            }
        }
    }
}

#Preview { RoutineView() }
