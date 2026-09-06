import SwiftUI

// MARK: - Reports View
struct ReportsView: View {
    @State private var selectedPeriod: ReportPeriod = .weekly
    @State private var showShare      = false
    @State private var showFilter     = false
    @State private var showBeforeAfter = false
    @State private var selectedReport: ReportEntry? = nil

    @State private var scans: [GlowFitAPI.ScanHistoryItem] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            if isLoading {
                ProgressView().tint(.white)
            } else if scans.isEmpty {
                EmptyReportsView()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ReportsHeaderView(showShare: $showShare, showFilter: $showFilter)
                        PeriodSelectorView(selected: $selectedPeriod)
                        SkinScoreRingCard(latest: scans[0], showBeforeAfter: $showBeforeAfter)
                        ReportsMetricsGrid(latest: scans[0])
                        WeeklyProgressChart(scans: scans)
                        AIRecommendationCard(latest: scans[0])
                        ReportHistorySection(scans: scans, selectedReport: $selectedReport)
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showFilter)      { ReportFilterSheet() }
        .sheet(isPresented: $showBeforeAfter) { BeforeAfterView(scans: scans) }
        .sheet(item: $selectedReport)          { ReportDetailSheet(report: $0) }
        .shareSheet(isPresented: $showShare,
                    items: ["تقرير بشرتي على GlowFit AI\nالنتيجة: \(scans.first?.skin_health_score ?? 0)/100 ✨"])
        .onAppear(perform: loadHistory)
    }

    private func loadHistory() {
        GlowFitAPI.getScanHistory(limit: 20) { history in
            self.scans = history
            self.isLoading = false
        }
    }
}

// MARK: - Empty State (لسا ما سوّت أي فحص)
struct EmptyReportsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("📊").font(.system(size: 50))
            Text("لسا ما عندك تقارير")
                .font(.custom("Tajawal-Bold", size: 18))
                .foregroundColor(.white)
            Text("سوّي فحص بشرة أول عشان يبدأ يتكوّن تقريرك هون")
                .font(.custom("Tajawal-Regular", size: 13))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Period Enum
enum ReportPeriod: String, CaseIterable {
    case weekly  = "أسبوعي"
    case monthly = "شهري"
    case yearly  = "سنوي"
}

// MARK: - Header
struct ReportsHeaderView: View {
    @Binding var showShare: Bool
    @Binding var showFilter: Bool
    var body: some View {
        HStack {
            Button(action: { showShare = true }) {
                GlowHeaderButton(systemImage: "square.and.arrow.up")
            }
            Spacer()
            Text("تقرير البشرة")
                .font(.custom("Tajawal-Bold", size: 20))
                .foregroundColor(.white)
            Spacer()
            Button(action: { showFilter = true }) {
                GlowHeaderButton(systemImage: "slider.horizontal.3")
            }
        }
    }
}

struct GlowHeaderButton: View {
    let systemImage: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
                .frame(width: 40, height: 40)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1))
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Period Selector
struct PeriodSelectorView: View {
    @Binding var selected: ReportPeriod
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ReportPeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.custom("Tajawal-Bold", size: 14))
                        .foregroundColor(selected == period ? .white : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if selected == period {
                                    LinearGradient(
                                        colors: [AuthColors.primaryPurple.opacity(0.5), AuthColors.primaryPink.opacity(0.3)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                    .cornerRadius(10)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}

// MARK: - Score Ring Card
struct SkinScoreRingCard: View {
    @State private var ringProgress: CGFloat = 0
    let latest: GlowFitAPI.ScanHistoryItem
    @Binding var showBeforeAfter: Bool
    var score: Int { latest.skin_health_score ?? 0 }

    private var lastScanLabel: String {
        "آخر فحص: " + GlowFitAPI.humanRelativeDate(latest.created_at)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.05), lineWidth: 12).frame(width: 160, height: 160)
                    Circle()
                        .trim(from: 0, to: ringProgress * CGFloat(score) / 100)
                        .stroke(LinearGradient(colors: [AuthColors.primaryPink, AuthColors.primaryPurple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 160, height: 160).rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.5).delay(0.3), value: ringProgress)
                    Text("\(score)").font(.system(size: 42, weight: .black))
                        .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                VStack(spacing: 8) {
                    Text(scoreLabel(for: score)).font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                    if let summary = latest.summary_text {
                        Text(summary)
                            .font(.custom("Tajawal-Regular", size: 13)).foregroundColor(Color.white.opacity(0.5))
                            .multilineTextAlignment(.center).padding(.horizontal, 10)
                    }
                }
                // Before/After button
                Button(action: { showBeforeAfter = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left.arrow.right").font(.system(size: 13))
                        Text("مقارنة قبل / بعد").font(.custom("Tajawal-Bold", size: 13))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 9)
                    .background(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.6), AuthColors.primaryPink.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                }
            }
            .frame(maxWidth: .infinity).padding(30)

            Text(lastScanLabel)
                .font(.custom("Tajawal-Regular", size: 11)).foregroundColor(Color.white.opacity(0.4))
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.black.opacity(0.3)).cornerRadius(8).padding(16)
        }
        .background(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.15), AuthColors.primaryPink.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AuthColors.primaryPurple.opacity(0.2), lineWidth: 1))
        .onAppear { withAnimation { ringProgress = 1 } }
    }

    private func scoreLabel(for score: Int) -> String {
        switch score {
        case 85...100: return "بشرة صحية ومشرقة ✨"
        case 65..<85:  return "بشرة بحالة جيدة 🙂"
        case 40..<65:  return "بشرتك محتاجة اهتمام أكتر 💧"
        default:       return "خلينا نشتغل سوا على بشرتك 🌱"
        }
    }
}

// MARK: - Metrics Grid
struct SkinMetric: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let value: Int
    let color: Color
}

struct ReportsMetricsGrid: View {
    let latest: GlowFitAPI.ScanHistoryItem
    var metrics: [SkinMetric] {
        var list: [SkinMetric] = []
        if let v = latest.moisture_level { list.append(SkinMetric(icon: "💧", name: "مستوى الترطيب", value: v, color: Color(red: 0.29, green: 0.77, blue: 0.50))) }
        if let v = latest.acne_percentage { list.append(SkinMetric(icon: "🔴", name: "حب الشباب", value: v, color: Color(red: 0.97, green: 0.44, blue: 0.44))) }
        if let v = latest.dark_circles_percentage { list.append(SkinMetric(icon: "👁", name: "الهالات السوداء", value: v, color: Color(red: 0.98, green: 0.75, blue: 0.14))) }
        if let v = latest.fine_lines_percentage { list.append(SkinMetric(icon: "〰️", name: "الخطوط الدقيقة", value: v, color: Color(red: 0.38, green: 0.65, blue: 0.98))) }
        return list
    }
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        if !metrics.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                ReportsSectionLabel(icon: "🔍", title: "تحليل مفصّل")
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(metrics) { metric in MetricCard(metric: metric) }
                }
            }
        }
    }
}

struct MetricCard: View {
    let metric: SkinMetric
    @State private var barWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(metric.color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Text(metric.icon).font(.system(size: 16))
                }
                Spacer()
                Text("\(metric.value)%")
                    .font(.custom("Tajawal-Bold", size: 16))
                    .foregroundColor(metric.color)
            }
            Text(metric.name)
                .font(.custom("Tajawal-Regular", size: 12))
                .foregroundColor(Color.white.opacity(0.5))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.08)).frame(height: 4)
                    RoundedRectangle(cornerRadius: 4).fill(metric.color)
                        .frame(width: geo.size.width * barWidth * CGFloat(metric.value) / 100, height: 4)
                        .animation(.easeOut(duration: 1.0).delay(0.4), value: barWidth)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        .onAppear { barWidth = 1 }
    }
}

// MARK: - Weekly Chart
struct WeeklyProgressChart: View {
    let scans: [GlowFitAPI.ScanHistoryItem]
    struct ChartData { let label: String; let value: Int; let isActive: Bool }

    var data: [ChartData] {
        // نرتّب أقدم للأحدث، وناخذ آخر 6 فحوصات بس
        let ordered = Array(scans.reversed().suffix(6))
        return ordered.enumerated().map { index, scan in
            let isLast = index == ordered.count - 1
            return ChartData(
                label: isLast ? "الآن" : "فحص \(index + 1)",
                value: scan.skin_health_score ?? 0,
                isActive: isLast
            )
        }
    }
    @State private var animated = false

    var body: some View {
        if data.count >= 2 {
            VStack(alignment: .leading, spacing: 16) {
                ReportsSectionLabel(icon: "📈", title: "التطور الزمني")
                VStack(alignment: .leading, spacing: 12) {
                    Text("مقارنة نتائج آخر \(data.count) فحوصات")
                        .font(.custom("Tajawal-Regular", size: 13))
                        .foregroundColor(Color.white.opacity(0.6))
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                            SingleChartBar(label: item.label, value: item.value,
                                           isActive: item.isActive, animated: animated)
                        }
                    }
                    .frame(height: 150)
                    .padding(.bottom, 8)
                    .overlay(Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1), alignment: .bottom)
                }
                .padding(20)
                .background(Color.white.opacity(0.03))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 1.0)) { animated = true }
                }
            }
        }
    }
}

struct SingleChartBar: View {
    let label: String; let value: Int; let isActive: Bool; let animated: Bool
    var barH: CGFloat { animated ? CGFloat(value) * 1.2 : 0 }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isActive ? AuthColors.primaryPink : AuthColors.primaryPurple)
                .opacity(animated ? 1 : 0)
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.03)).frame(height: 120)
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive
                          ? LinearGradient(colors: [AuthColors.primaryPink.opacity(0.3), AuthColors.primaryPink], startPoint: .bottom, endPoint: .top)
                          : LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.2), AuthColors.primaryPurple], startPoint: .bottom, endPoint: .top))
                    .frame(height: barH)
                    .shadow(color: isActive ? AuthColors.primaryPink.opacity(0.3) : .clear, radius: 8)
                    .animation(.easeOut(duration: 1.0), value: animated)
            }
            Text(label).font(.system(size: 11)).foregroundColor(Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - AI Recommendation
struct AIRecommendationCard: View {
    let latest: GlowFitAPI.ScanHistoryItem
    var body: some View {
        if let tip = (latest.recommendations?.first) ?? latest.summary_text {
            VStack(alignment: .leading, spacing: 16) {
                ReportsSectionLabel(icon: "🤖", title: "نصيحة خبير الذكاء الاصطناعي")
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.2), AuthColors.primaryPink.opacity(0.2)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        Text("✨").font(.system(size: 22))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("بناءً على آخر فحص")
                            .font(.custom("Tajawal-Bold", size: 14))
                            .foregroundColor(.white)
                        Text(tip)
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(Color.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                }
                .padding(16)
                .background(LinearGradient(colors: [Color.blue.opacity(0.1), AuthColors.primaryPurple.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(16)
                .overlay(
                    HStack {
                        RoundedRectangle(cornerRadius: 4).fill(AuthColors.primaryPurple).frame(width: 4)
                        Spacer()
                    }, alignment: .leading
                )
            }
        }
    }
}

// MARK: - Report History
struct ReportEntry: Identifiable {
    let id: String
    let date: String
    let score: Int
    let change: Int
    let status: String
    let age: Int?
    let moisture: Int?
    let acne: Int?
    let darkCircles: Int?
    let fineLines: Int?
    let poresCondition: String?
    let pigmentation: String?
    let sensitivity: String?
    let concerns: [String]?
    let recommendations: [String]?
    let problemsAndSolutions: [GlowFitAPI.ProblemSolution]?
    let recommendation: String?
}

struct ReportHistorySection: View {
    let scans: [GlowFitAPI.ScanHistoryItem]
    @Binding var selectedReport: ReportEntry?

    var reports: [ReportEntry] {
        scans.enumerated().map { index, scan in
            let previousScore = (index + 1 < scans.count) ? scans[index + 1].skin_health_score : nil
            let change = (scan.skin_health_score != nil && previousScore != nil) ? scan.skin_health_score! - previousScore! : 0
            return ReportEntry(
                id: scan.id,
                date: relativeDate(scan.created_at),
                score: scan.skin_health_score ?? 0,
                change: change,
                status: change > 0 ? "تحسّن" : (change < 0 ? "تراجع" : "بدون تغيير"),
                age: scan.estimated_age,
                moisture: scan.moisture_level,
                acne: scan.acne_percentage,
                darkCircles: scan.dark_circles_percentage,
                fineLines: scan.fine_lines_percentage,
                poresCondition: scan.pores_condition,
                pigmentation: scan.pigmentation,
                sensitivity: scan.sensitivity,
                concerns: scan.concerns,
                recommendations: scan.recommendations,
                problemsAndSolutions: scan.problems_and_solutions,
                recommendation: scan.recommendations?.first ?? scan.summary_text
            )
        }
    }

    private func relativeDate(_ raw: String) -> String {
        GlowFitAPI.humanRelativeDate(raw)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ReportsSectionLabel(icon: "🗂", title: "سجل التقارير")
            VStack(spacing: 0) {
                ForEach(reports) { report in
                    Button(action: { selectedReport = report }) {
                        ReportHistoryRow(report: report)
                    }
                }
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        }
    }
}

struct ReportHistoryRow: View {
    let report: ReportEntry
    var changeColor: Color { report.change >= 0 ? Color(red: 0.29, green: 0.77, blue: 0.50) : Color(red: 0.97, green: 0.44, blue: 0.44) }
    var changeIcon: String { report.change >= 0 ? "arrow.up.right" : "arrow.down.right" }
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(AuthColors.primaryPurple.opacity(0.1)).frame(width: 44, height: 44)
                Text("\(report.score)").font(.custom("Tajawal-Bold", size: 16))
                    .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(report.date).font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                Text(report.status).font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
            }.padding(.horizontal, 12)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: changeIcon).font(.system(size: 12, weight: .bold))
                Text("\(report.change > 0 ? "+" : "")\(report.change)").font(.custom("Tajawal-Bold", size: 13))
            }
            .foregroundColor(changeColor).padding(.horizontal, 10).padding(.vertical, 5)
            .background(changeColor.opacity(0.1)).cornerRadius(8)
            Image(systemName: "chevron.left").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.3)).padding(.leading, 8)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .overlay(Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1), alignment: .bottom)
        .contentShape(Rectangle())
    }
}

// MARK: - Section Label
struct ReportsSectionLabel: View {
    let icon: String; let title: String
    var body: some View {
        HStack(spacing: 8) {
            Text(icon).font(.system(size: 16))
            Text(title).font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
        }
    }
}

// MARK: - Share Sheet Extension
extension View {
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheet(items: items)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Filter Sheet
struct ReportFilterSheet: View {
    @State private var selectedMetrics: Set<String> = ["الترطيب","الهالات"]
    @State private var dateRange = 6.0
    @Environment(\.dismiss) var dismiss
    let allMetrics = ["الترطيب","حب الشباب","الهالات","الخطوط","الإشراق"]
    var body: some View {
        AccountSheet(title: "فلترة التقرير") {
            VStack(alignment: .leading, spacing: 12) {
                Text("المقاييس المعروضة").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                FlowLayout(spacing: 10) {
                    ForEach(allMetrics, id: \.self) { m in
                        Button(action: {
                            if selectedMetrics.contains(m) { selectedMetrics.remove(m) }
                            else { selectedMetrics.insert(m) }
                        }) {
                            Text(m).font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(selectedMetrics.contains(m) ? .white : Color.white.opacity(0.5))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(selectedMetrics.contains(m)
                                    ? LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink], startPoint:.leading, endPoint:.trailing)
                                    : LinearGradient(colors:[Color.white.opacity(0.05)], startPoint:.leading, endPoint:.trailing))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("نطاق الفترة الزمنية: آخر \(Int(dateRange)) أسابيع").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                Slider(value: $dateRange, in: 1...12, step: 1).tint(AuthColors.primaryPurple)
            }
            Button(action: { dismiss() }) {
                Text("تطبيق الفلتر")
                    .font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink], startPoint:.leading, endPoint:.trailing))
                    .cornerRadius(14)
            }
        }
    }
}

// MARK: - Report Detail Sheet
struct ReportDetailSheet: View {
    let report: ReportEntry
    var changeColor: Color { report.change >= 0 ? Color(red:0.29,green:0.77,blue:0.50) : Color(red:0.97,green:0.44,blue:0.44) }

    private let concernLabels: [String: String] = [
        "acne": "حب الشباب", "dryness": "جفاف", "oiliness": "زيوت زائدة",
        "pores": "مسام واسعة", "pigmentation": "تصبغات", "dark_circles": "هالات سوداء",
        "fine_lines": "خطوط دقيقة", "sensitivity": "حساسية"
    ]

    var snap: [(String, Int, Color)] {
        var list: [(String, Int, Color)] = []
        if let v = report.moisture    { list.append(("💧 الترطيب", v, Color(red:0.29,green:0.77,blue:0.50))) }
        if let v = report.acne        { list.append(("🔴 حب الشباب", v, Color(red:0.97,green:0.44,blue:0.44))) }
        if let v = report.darkCircles { list.append(("👁 الهالات", v, Color(red:0.98,green:0.75,blue:0.14))) }
        if let v = report.fineLines   { list.append(("〰️ الخطوط", v, Color(red:0.38,green:0.65,blue:0.98))) }
        return list
    }

    var body: some View {
        AccountSheet(title: "تفاصيل التقرير") {
            // Score
            VStack(spacing: 8) {
                Text("\(report.score)").font(.system(size: 56, weight: .black))
                    .foregroundStyle(LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink], startPoint:.topLeading, endPoint:.bottomTrailing))
                Text(report.date).font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                HStack(spacing: 6) {
                    Image(systemName: report.change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(report.change > 0 ? "+" : "")\(report.change) نقطة")
                }
                .font(.custom("Tajawal-Bold", size: 14)).foregroundColor(changeColor)
                .padding(.horizontal, 14).padding(.vertical, 6).background(changeColor.opacity(0.1)).cornerRadius(10)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 8)

            // Metrics snapshot (نسب مئوية)
            if !snap.isEmpty {
                VStack(spacing: 10) {
                    ForEach(snap, id: \.0) { (name, val, col) in
                        HStack {
                            Text(name).font(.custom("Tajawal-Regular",size:14)).foregroundColor(.white)
                            Spacer()
                            Text("\(val)%").font(.custom("Tajawal-Bold",size:14)).foregroundColor(col)
                        }
                        .padding(.horizontal,16).padding(.vertical,12)
                        .background(Color.white.opacity(0.03)).cornerRadius(12)
                    }
                }
            }

            // مؤشرات وصفية (مش نسب) — العمر، المسام، التصبغات، الحساسية
            let descriptiveRows: [(String, String)] = [
                report.age.map { ("🎂 العمر التقريبي", "\($0) سنة") },
                report.poresCondition.map { ("🕳 حالة المسام", $0) },
                report.pigmentation.map { ("🟤 التصبغات", $0) },
                report.sensitivity.map { ("✨ حساسية البشرة", $0) }
            ].compactMap { $0 }

            if !descriptiveRows.isEmpty {
                VStack(spacing: 10) {
                    ForEach(descriptiveRows, id: \.0) { (label, value) in
                        HStack {
                            Text(label).font(.custom("Tajawal-Regular", size: 14)).foregroundColor(.white)
                            Spacer()
                            Text(value).font(.custom("Tajawal-Bold", size: 13)).foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Color.white.opacity(0.03)).cornerRadius(12)
                    }
                }
            }

            // الملاحظات المكتشفة
            if let concerns = report.concerns, !concerns.isEmpty {
                VStack(alignment: .trailing, spacing: 10) {
                    Text("⚠️ ملاحظات مكتشفة").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                    FlowLayout(spacing: 10) {
                        ForEach(concerns, id: \.self) { c in
                            Text(concernLabels[c] ?? c)
                                .font(.custom("Tajawal-Medium", size: 12))
                                .foregroundColor(Color(red: 0.75, green: 0.52, blue: 0.99))
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(AuthColors.primaryPurple.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(14).background(Color.white.opacity(0.03)).cornerRadius(14)
            }

            // المشاكل والحلول مع المصدر
            if let problems = report.problemsAndSolutions, !problems.isEmpty {
                VStack(alignment: .trailing, spacing: 14) {
                    Text("🩺 المشاكل والحلول").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                    ForEach(Array(problems.enumerated()), id: \.offset) { _, item in
                        VStack(alignment: .trailing, spacing: 6) {
                            if let problem = item.problem {
                                Text(problem).font(.custom("Tajawal-Bold", size: 13)).foregroundColor(.white.opacity(0.9))
                            }
                            if let solution = item.solution {
                                Text(solution).font(.custom("Tajawal-Regular", size: 12)).foregroundColor(.white.opacity(0.6))
                            }
                            if let source = item.source {
                                if let linkString = item.link, let url = URL(string: linkString) {
                                    Link(destination: url) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "link").font(.system(size: 9))
                                            Text("المصدر: " + source).font(.custom("Tajawal-Regular", size: 10)).underline()
                                        }
                                    }.foregroundColor(AuthColors.primaryPink.opacity(0.8))
                                } else {
                                    Text("المصدر: " + source).font(.custom("Tajawal-Regular", size: 10)).foregroundColor(.white.opacity(0.35))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom, 6)
                    }
                }
                .padding(14).background(Color.white.opacity(0.03)).cornerRadius(14)
            }

            // كل التوصيات (مش أول وحدة بس)
            if let recs = report.recommendations, recs.count > 0 {
                VStack(alignment: .trailing, spacing: 10) {
                    Text("💡 توصيات العناية").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                    ForEach(recs, id: \.self) { r in
                        Text("• " + r).font(.custom("Tajawal-Regular", size: 12)).foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(14).background(AuthColors.primaryPurple.opacity(0.08)).cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius:14).stroke(AuthColors.primaryPurple.opacity(0.2),lineWidth:1))
            }
        }
    }
}

#Preview { ReportsView() }
