import SwiftUI

// MARK: - Routine View
struct RoutineView: View {
    @State private var selectedSegment: RoutineSegment = .morning
    @State private var routines: [GlowFitAPI.RoutineData] = []
    @State private var allSteps: [GlowFitAPI.RoutineStepData] = []
    @State private var completionsByDate: [String: [String]] = [:]
    @State private var isLoading = true
    @State private var isGenerating = false
    @State private var errorMessage: String? = nil

    private var todayString: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: Date())
    }

    private var currentRoutineId: String? {
        routines.first(where: { $0.time_of_day == (selectedSegment == .morning ? "morning" : "evening") })?.id
    }
    private var currentSteps: [GlowFitAPI.RoutineStepData] {
        guard let id = currentRoutineId else { return [] }
        return allSteps.filter { $0.routine_id == id }.sorted { ($0.step_order ?? 0) < ($1.step_order ?? 0) }
    }
    private var completedTodayIds: Set<String> { Set(completionsByDate[todayString] ?? []) }
    private var completedCount: Int { currentSteps.filter { completedTodayIds.contains($0.id) }.count }
    private var progress: Double { currentSteps.isEmpty ? 0 : Double(completedCount) / Double(currentSteps.count) }

    private var allStepIds: Set<String> { Set(allSteps.map { $0.id }) }
    private var streak: Int {
        guard !allSteps.isEmpty else { return 0 }
        let cal = Calendar.current
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        var streakCount = 0, dayOffset = 0, skippedToday = false
        while true {
            guard let date = cal.date(byAdding: .day, value: -dayOffset, to: Date()) else { break }
            let dateStr = formatter.string(from: date)
            let doneCount = Set(completionsByDate[dateStr] ?? []).intersection(allStepIds).count
            if doneCount >= allSteps.count {
                streakCount += 1; dayOffset += 1
            } else if dayOffset == 0 && !skippedToday {
                skippedToday = true; dayOffset += 1
            } else { break }
        }
        return streakCount
    }

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            if isLoading {
                ProgressView().tint(.white)
            } else if routines.isEmpty {
                RoutineEmptyState(isGenerating: $isGenerating, errorMessage: $errorMessage, onGenerate: generateRoutine)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        RoutineHeaderView(isGenerating: isGenerating, onRegenerate: generateRoutine)
                        RoutineSegmentPicker(selected: $selectedSegment)
                        RoutineProgressCard(completed: completedCount, total: currentSteps.count, progress: progress, streak: streak)
                        RoutineStepsSection(steps: currentSteps, isDone: { completedTodayIds.contains($0) }, onToggle: toggleStep)
                        RoutineTipsCard(segment: selectedSegment)
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear(perform: loadAll)
    }

    private func loadAll() {
        GlowFitAPI.getMyRoutines { fetchedRoutines, fetchedSteps in
            routines = fetchedRoutines
            allSteps = fetchedSteps
            GlowFitAPI.getCompletionHistory { history in
                completionsByDate = history
                isLoading = false
            }
        }
    }

    private func generateRoutine() {
        guard !isGenerating else { return }
        isGenerating = true
        errorMessage = nil
        GlowFitAPI.generateRoutine { result in
            switch result {
            case .success:
                loadAll()
                isGenerating = false
            case .failure(let message):
                errorMessage = message
                isGenerating = false
                isLoading = false
            }
        }
    }

    private func toggleStep(_ stepId: String) {
        let isCurrentlyDone = completedTodayIds.contains(stepId)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            var todayList = completionsByDate[todayString] ?? []
            if isCurrentlyDone {
                todayList.removeAll { $0 == stepId }
            } else {
                todayList.append(stepId)
            }
            completionsByDate[todayString] = todayList
        }
        GlowFitAPI.toggleStepCompletion(stepId: stepId, isCompleting: !isCurrentlyDone) { success in
            if !success {
                withAnimation {
                    var todayList = completionsByDate[todayString] ?? []
                    if isCurrentlyDone {
                        todayList.append(stepId)
                    } else {
                        todayList.removeAll { $0 == stepId }
                    }
                    completionsByDate[todayString] = todayList
                }
            }
        }
    }
}

// MARK: - Empty State (ما في روتين لسا)
struct RoutineEmptyState: View {
    @Binding var isGenerating: Bool
    @Binding var errorMessage: String?
    let onGenerate: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("🧴").font(.system(size: 50))
            Text("لسا ما عندك روتين")
                .font(.custom("Tajawal-Bold", size: 18))
                .foregroundColor(.white)
            Text("بنبني لك روتين صباحي ومسائي مخصص بناءً على آخر فحص بشرة سويتيه")
                .font(.custom("Tajawal-Regular", size: 13))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.custom("Tajawal-Medium", size: 13))
                    .foregroundColor(Color(red: 0.97, green: 0.44, blue: 0.44))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Button(action: onGenerate) {
                if isGenerating {
                    ProgressView().tint(.white).frame(maxWidth: 220).padding(.vertical, 16)
                } else {
                    Text("بناء روتيني الآن ✨")
                        .font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                        .frame(maxWidth: 220).padding(.vertical, 16)
                }
            }
            .disabled(isGenerating)
            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}

// MARK: - Segment
enum RoutineSegment: String, CaseIterable {
    case morning = "الصباح ☀️"
    case evening = "المساء 🌙"
}

// MARK: - Header
struct RoutineHeaderView: View {
    let isGenerating: Bool
    let onRegenerate: () -> Void
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
            Button(action: onRegenerate) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 40, height: 40)
                    if isGenerating {
                        ProgressView().tint(.white).scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(isGenerating)
        }
    }
}

// MARK: - Segment Picker
struct RoutineSegmentPicker: View {
    @Binding var selected: RoutineSegment
    var body: some View {
        HStack(spacing: 0) {
            ForEach(RoutineSegment.allCases, id: \.self) { seg in
                Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { selected = seg } }) {
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
                VStack(spacing: 4) {
                    ZStack {
                        Circle().fill(Color(red: 0.98, green: 0.75, blue: 0.14).opacity(0.15)).frame(width: 52, height: 52)
                        Text("🔥").font(.system(size: 26))
                    }
                    Text("\(streak) يوم")
                        .font(.custom("Tajawal-Bold", size: 12))
                        .foregroundColor(Color(red: 0.98, green: 0.75, blue: 0.14))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.07)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * (animated ? progress : 0), height: 8)
                        .animation(.easeOut(duration: 1.0).delay(0.2), value: animated)
                }
            }
            .frame(height: 8)

            HStack {
                Label(progress >= 1 ? "خلصتي كل خطوات اليوم! 🎉" : "تقدم رائع! استمري 💪", systemImage: "sparkles")
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
        .onChange(of: progress) { _ in
            animated = false
            withAnimation(.easeOut(duration: 0.8)) { animated = true }
        }
    }
}

// MARK: - Steps Section
struct RoutineStepsSection: View {
    let steps: [GlowFitAPI.RoutineStepData]
    let isDone: (String) -> Bool
    let onToggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("📋").font(.system(size: 16))
                Text("الخطوات").font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
            }
            VStack(spacing: 10) {
                ForEach(steps) { step in
                    RoutineStepCard(step: step, done: isDone(step.id), onToggle: { onToggle(step.id) })
                }
            }
        }
    }
}

// MARK: - Step Card
struct RoutineStepCard: View {
    let step: GlowFitAPI.RoutineStepData
    let done: Bool
    let onToggle: () -> Void

    private var subtitle: String {
        if let product = step.products, let name = product.name {
            return product.brand != nil ? "\(product.brand!) — \(name)" : name
        }
        return step.custom_note ?? ""
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(AuthColors.primaryPurple.opacity(0.18))
                    .frame(width: 48, height: 48)
                Text(step.icon ?? "✨").font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title ?? "خطوة")
                    .font(.custom("Tajawal-Bold", size: 15))
                    .foregroundColor(done ? Color.white.opacity(0.5) : .white)
                    .strikethrough(done, color: Color.white.opacity(0.3))
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(Color.white.opacity(0.3))
                        .lineLimit(1)
                }
            }
            Spacer()

            Button(action: onToggle) {
                ZStack {
                    Circle().stroke(done ? Color.clear : Color.white.opacity(0.15), lineWidth: 2).frame(width: 26, height: 26)
                    if done {
                        Circle()
                            .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(done ? Color.white.opacity(0.02) : Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(done ? AuthColors.primaryPurple.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1))
    }
}

// MARK: - Tips Card
struct RoutineTipsCard: View {
    let segment: RoutineSegment
    var tipText: String {
        segment == .morning
            ? "نصيحة: ضعي واقي الشمس كآخر خطوة قبل الخروج بـ 15 دقيقة لأفضل حماية ☀️"
            : "نصيحة: تجنبي لمس وجهك بعد السيروم واتركيه يمتص بالكامل قبل النوم 🌙"
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
