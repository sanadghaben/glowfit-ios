import SwiftUI

struct BeforeAfterView: View {
    let scans: [GlowFitAPI.ScanHistoryItem] // مرتّبة من الأحدث للأقدم (نفس ترتيب سجل التقارير)

    @State private var sliderOffset: CGFloat = 0.5
    @State private var selectedIndex = 1 // index داخل scans (0 = الأحدث "بعد"، الباقي خيارات "قبل")
    @GestureState private var isDragging = false
    @Environment(\.dismiss) var dismiss

    @State private var afterImageURL: String? = nil
    @State private var beforeImageURL: String? = nil
    @State private var isLoadingImages = false

    private var afterScan: GlowFitAPI.ScanHistoryItem? { scans.first }
    private var beforeScan: GlowFitAPI.ScanHistoryItem? {
        guard selectedIndex < scans.count else { return nil }
        return scans[selectedIndex]
    }

    var body: some View {
        AccountSheet(title: "مقارنة قبل / بعد") {
            if scans.count < 2 {
                VStack(spacing: 14) {
                    Text("📸").font(.system(size: 44))
                    Text("تحتاجي فحصين على الأقل للمقارنة")
                        .font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                    Text("سوّي فحص بشرة تاني عشان تقدري تشوفي تطوّر بشرتك بمرور الوقت")
                        .font(.custom("Tajawal-Regular", size: 13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 30)
            } else {
                // Scan picker (اختيار الفحص "القديم" للمقارنة)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(1..<scans.count, id: \.self) { i in
                            Button(action: { withAnimation { selectedIndex = i } }) {
                                Text(i == scans.count - 1 ? "أول فحص" : GlowFitAPI.humanRelativeDate(scans[i].created_at))
                                    .font(.custom("Tajawal-Medium", size: 13))
                                    .foregroundColor(selectedIndex == i ? .white : Color.white.opacity(0.4))
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(selectedIndex == i
                                        ? LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.white.opacity(0.06)], startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }

                // Face comparison slider
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = w * 1.2
                    ZStack {
                        // BEFORE (يمين - الفحص الأقدم المختار)
                        ZStack {
                            LinearGradient(colors: [Color(red: 0.15, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            if let urlString = beforeImageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image { image.resizable().scaledToFill() }
                                    else { Text("👩🏻").font(.system(size: 80)) }
                                }
                            } else {
                                Text("👩🏻").font(.system(size: 80))
                            }
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("قبل")
                                        .font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Color.black.opacity(0.5)).cornerRadius(8)
                                        .padding(14)
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("\(beforeScan?.skin_health_score ?? 0) / 100")
                                        .font(.custom("Tajawal-Bold", size: 16))
                                        .foregroundColor(Color(red: 0.97, green: 0.44, blue: 0.44))
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Color.black.opacity(0.5)).cornerRadius(8)
                                        .padding(14)
                                }
                            }
                        }
                        .frame(width: w, height: h)
                        .cornerRadius(20)
                        .clipped()

                        // AFTER (يسار - أحدث فحص)
                        ZStack {
                            LinearGradient(colors: [Color(red: 0.1, green: 0.08, blue: 0.18), Color(red: 0.15, green: 0.08, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            if let urlString = afterImageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image { image.resizable().scaledToFill() }
                                    else { Text("👩🏻").font(.system(size: 80)) }
                                }
                            } else {
                                Text("👩🏻").font(.system(size: 80))
                            }
                            Circle().fill(AuthColors.primaryPurple.opacity(0.15)).frame(width: 160, height: 160).blur(radius: 30)
                            VStack {
                                HStack {
                                    Text("بعد")
                                        .font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Color.black.opacity(0.5)).cornerRadius(8)
                                        .padding(14)
                                    Spacer()
                                }
                                Spacer()
                                HStack {
                                    Text("\(afterScan?.skin_health_score ?? 0) / 100")
                                        .font(.custom("Tajawal-Bold", size: 16))
                                        .foregroundColor(Color(red: 0.29, green: 0.77, blue: 0.50))
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Color.black.opacity(0.5)).cornerRadius(8)
                                        .padding(14)
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: w * sliderOffset, height: h)
                        .clipped()
                        .frame(width: w, alignment: .leading)

                        Rectangle().fill(.white).frame(width: 2, height: h)
                            .offset(x: w * sliderOffset - w / 2)
                        ZStack {
                            Circle().fill(.white).frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.3), radius: 6)
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold)).foregroundColor(AuthColors.primaryPurple)
                                Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold)).foregroundColor(AuthColors.primaryPurple)
                            }
                        }
                        .offset(x: w * sliderOffset - w / 2)
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    let newX = (val.location.x) / w
                                    sliderOffset = min(max(newX, 0.05), 0.95)
                                }
                        )
                    }
                    .frame(width: w, height: h)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .frame(height: UIScreen.main.bounds.width * 0.85)
                .padding(.horizontal, -4)

                Text("اسحبي المقبض يميناً أو يساراً للمقارنة")
                    .font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity).multilineTextAlignment(.center)

                // Metrics comparison (بيانات حقيقية)
                if let after = afterScan, let before = beforeScan {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("مقارنة المقاييس").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                        improvementRows(before: before, after: after)
                    }
                }
            }
        }
        .onAppear { loadImages() }
        .onChange(of: selectedIndex) { _ in loadImages() }
    }

    @ViewBuilder
    private func improvementRows(before: GlowFitAPI.ScanHistoryItem, after: GlowFitAPI.ScanHistoryItem) -> some View {
        if let b = before.moisture_level, let a = after.moisture_level {
            ImprovementRow(icon: "💧", label: "الترطيب", before: b, after: a, color: Color(red: 0.29, green: 0.77, blue: 0.50), higherIsBetter: true)
        }
        if let b = before.dark_circles_percentage, let a = after.dark_circles_percentage {
            ImprovementRow(icon: "👁", label: "الهالات السوداء", before: b, after: a, color: Color(red: 0.98, green: 0.75, blue: 0.14), higherIsBetter: false)
        }
        if let b = before.acne_percentage, let a = after.acne_percentage {
            ImprovementRow(icon: "🔴", label: "حب الشباب", before: b, after: a, color: Color(red: 0.97, green: 0.44, blue: 0.44), higherIsBetter: false)
        }
        if let b = before.fine_lines_percentage, let a = after.fine_lines_percentage {
            ImprovementRow(icon: "〰️", label: "الخطوط الدقيقة", before: b, after: a, color: Color(red: 0.38, green: 0.65, blue: 0.98), higherIsBetter: false)
        }
    }

    private func loadImages() {
        afterImageURL = nil
        beforeImageURL = nil
        if let path = afterScan?.image_url {
            GlowFitAPI.getSignedScanImageURL(path: path) { url in afterImageURL = url }
        }
        if let path = beforeScan?.image_url {
            GlowFitAPI.getSignedScanImageURL(path: path) { url in beforeImageURL = url }
        }
    }
}

struct ImprovementRow: View {
    let icon: String; let label: String; let before: Int; let after: Int; let color: Color
    let higherIsBetter: Bool
    var diff: Int { after - before }
    var isImproved: Bool { higherIsBetter ? diff > 0 : diff < 0 }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(icon).font(.system(size: 16))
                Text(label).font(.custom("Tajawal-Medium", size: 14)).foregroundColor(.white)
                Spacer()
                if diff != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: isImproved ? "arrow.up.right" : "arrow.down.right").font(.system(size: 11))
                        Text(isImproved ? "تحسّن \(abs(diff))%" : "زاد \(abs(diff))%").font(.custom("Tajawal-Bold", size: 12))
                    }
                    .foregroundColor(isImproved ? Color(red: 0.29, green: 0.77, blue: 0.50) : Color(red: 0.97, green: 0.44, blue: 0.44))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background((isImproved ? Color(red: 0.29, green: 0.77, blue: 0.50) : Color(red: 0.97, green: 0.44, blue: 0.44)).opacity(0.1)).cornerRadius(6)
                } else {
                    Text("بدون تغيير").font(.custom("Tajawal-Medium", size: 12)).foregroundColor(.white.opacity(0.4))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.06)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(color)
                        .frame(width: geo.size.width * CGFloat(after) / 100, height: 6)
                    RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.3))
                        .frame(width: 2, height: 12)
                        .offset(x: geo.size.width * CGFloat(before) / 100 - 1)
                }
            }
            .frame(height: 12)
            HStack {
                Text("قبل: \(before)%").font(.custom("Tajawal-Regular", size: 11)).foregroundColor(Color.white.opacity(0.35))
                Spacer()
                Text("بعد: \(after)%").font(.custom("Tajawal-Bold", size: 11)).foregroundColor(color)
            }
        }
        .padding(14).background(Color.white.opacity(0.03)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
