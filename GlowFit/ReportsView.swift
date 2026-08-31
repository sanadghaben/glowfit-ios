import SwiftUI

// MARK: - Reports View
struct ReportsView: View {
    @State private var selectedPeriod: ReportPeriod = .weekly
    @State private var showShare      = false
    @State private var showFilter     = false
    @State private var showBeforeAfter = false
    @State private var selectedReport: ReportEntry? = nil

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ReportsHeaderView(showShare: $showShare, showFilter: $showFilter)
                    PeriodSelectorView(selected: $selectedPeriod)
                    SkinScoreRingCard(showBeforeAfter: $showBeforeAfter)
                    ReportsMetricsGrid()
                    WeeklyProgressChart()
                    AIRecommendationCard()
                    ReportHistorySection(selectedReport: $selectedReport)
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showFilter)      { ReportFilterSheet() }
        .sheet(isPresented: $showBeforeAfter) { BeforeAfterView() }
        .sheet(item: $selectedReport)          { ReportDetailSheet(report: $0) }
        .shareSheet(isPresented: $showShare,
                    items: ["تقرير بشرتي على GlowFit AI\nالنتيجة: 87/100 ✨\nبشرة صحية ومشرقة!"])
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
    @Binding var showBeforeAfter: Bool
    let score = 87

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
                    Text("بشرة صحية ومشرقة ✨").font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                    Text("مستوى الترطيب ممتاز، مع وجود بعض الجفاف الخفيف في منطقة T-Zone.")
                        .font(.custom("Tajawal-Regular", size: 13)).foregroundColor(Color.white.opacity(0.5))
                        .multilineTextAlignment(.center).padding(.horizontal, 10)
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

            Text("آخر فحص: اليوم، 10:00 ص")
                .font(.custom("Tajawal-Regular", size: 11)).foregroundColor(Color.white.opacity(0.4))
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.black.opacity(0.3)).cornerRadius(8).padding(16)
        }
        .background(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.15), AuthColors.primaryPink.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AuthColors.primaryPurple.opacity(0.2), lineWidth: 1))
        .onAppear { withAnimation { ringProgress = 1 } }
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
    let metrics: [SkinMetric] = [
        SkinMetric(icon: "💧", name: "مستوى الترطيب",     value: 92, color: Color(red: 0.29, green: 0.77, blue: 0.50)),
        SkinMetric(icon: "🔴", name: "حب الشباب",         value: 12, color: Color(red: 0.97, green: 0.44, blue: 0.44)),
        SkinMetric(icon: "👁", name: "الهالات السوداء",   value: 34, color: Color(red: 0.98, green: 0.75, blue: 0.14)),
        SkinMetric(icon: "〰️", name: "الخطوط الدقيقة",    value: 18, color: Color(red: 0.38, green: 0.65, blue: 0.98)),
    ]
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ReportsSectionLabel(icon: "🔍", title: "تحليل مفصّل")
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(metrics) { metric in MetricCard(metric: metric) }
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
    struct ChartData { let label: String; let value: Int; let isActive: Bool }
    let data: [ChartData] = [
        .init(label: "أ.1", value: 65, isActive: false),
        .init(label: "أ.2", value: 68, isActive: false),
        .init(label: "أ.3", value: 74, isActive: false),
        .init(label: "أ.4", value: 80, isActive: false),
        .init(label: "أ.5", value: 83, isActive: false),
        .init(label: "الآن", value: 87, isActive: true),
    ]
    @State private var animated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ReportsSectionLabel(icon: "📈", title: "التطور الأسبوعي")
            VStack(alignment: .leading, spacing: 12) {
                Text("مقارنة نتائج فحص البشرة لآخر 6 أسابيع")
                    .font(.custom("Tajawal-Regular", size: 13))
                    .foregroundColor(Color.white.opacity(0.6))
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data, id: \.label) { item in
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
    var body: some View {
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
                    Text("تحسن ملحوظ! 🎉")
                        .font(.custom("Tajawal-Bold", size: 14))
                        .foregroundColor(.white)
                    Text("لقد انخفضت الهالات السوداء بنسبة 15% مقارنة بالأسبوع الماضي. ننصحك بالاستمرار في استخدام سيروم فيتامين C وشرب كميات كافية من الماء للحفاظ على هذا التوهج.")
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

// MARK: - Report History
struct ReportEntry: Identifiable {
    let id = UUID(); let date: String; let score: Int; let change: Int; let status: String
}

struct ReportHistorySection: View {
    @Binding var selectedReport: ReportEntry?
    let reports: [ReportEntry] = [
        ReportEntry(date: "الأسبوع الماضي",     score: 83, change: +4, status: "تحسن"),
        ReportEntry(date: "منذ أسبوعين",         score: 80, change: +6, status: "تحسن"),
        ReportEntry(date: "منذ ثلاثة أسابيع",   score: 74, change: -2, status: "انخفاض خفيف"),
    ]
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
            // Metrics snapshot
            let snap: [(String,Int,Color)] = [
                ("💧 الترطيب",92, Color(red:0.29,green:0.77,blue:0.50)),
                ("🔴 حب الشباب",12, Color(red:0.97,green:0.44,blue:0.44)),
                ("👁 الهالات",34, Color(red:0.98,green:0.75,blue:0.14)),
                ("〰️ الخطوط",18, Color(red:0.38,green:0.65,blue:0.98)),
            ]
            VStack(spacing: 10) {
                ForEach(snap, id:\.0) { (name,val,col) in
                    HStack {
                        Text(name).font(.custom("Tajawal-Regular",size:14)).foregroundColor(.white)
                        Spacer()
                        Text("\(val)%").font(.custom("Tajawal-Bold",size:14)).foregroundColor(col)
                    }
                    .padding(.horizontal,16).padding(.vertical,12)
                    .background(Color.white.opacity(0.03)).cornerRadius(12)
                }
            }
            // AI note
            HStack(alignment:.top,spacing:12) {
                Text("🤖").font(.system(size:22))
                Text("بناءً على هذا التقرير، يُنصح بالتركيز على مرطب مكثف وتقليل المكياج الثقيل هذا الأسبوع.")
                    .font(.custom("Tajawal-Regular",size:13)).foregroundColor(Color.white.opacity(0.7)).lineSpacing(4)
            }
            .padding(14).background(AuthColors.primaryPurple.opacity(0.08)).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius:14).stroke(AuthColors.primaryPurple.opacity(0.2),lineWidth:1))
        }
    }
}

#Preview { ReportsView() }
