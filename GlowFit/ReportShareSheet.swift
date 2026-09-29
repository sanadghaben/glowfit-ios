import SwiftUI

/// نافذة تخلّي المستخدمة تختار بنفسها شو تشارك من تقريرها (الدرجة، المقاييس، الملخص، التوصيات، المشاكل والحلول، رابط التطبيق)
struct ReportShareSheet: View {
    let latest: GlowFitAPI.ScanHistoryItem

    @State private var includeScore = true
    @State private var includeMetrics = true
    @State private var includeSummary = true
    @State private var includeRecommendations = true
    @State private var includeProblems = true
    @State private var includeImage = true

    @State private var scanImage: UIImage? = nil
    @State private var isLoadingImage = false
    @State private var showActivitySheet = false

    private static let appStoreLink = "https://apps.apple.com/us/app/glowfit-ai/id6756659293"

    // MARK: - أي أقسام عندها بيانات فعلية (ما منعرض خيار قسم فاضي)
    private var hasScore: Bool { latest.skin_health_score != nil }
    private var hasMetrics: Bool {
        latest.moisture_level != nil || latest.acne_percentage != nil ||
        latest.dark_circles_percentage != nil || latest.fine_lines_percentage != nil
    }
    private var hasImage: Bool { !(latest.image_url ?? "").isEmpty }
    private var summary: String { (latest.summary_text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
    private var recommendations: [String] {
        (latest.recommendations ?? []).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    private var problems: [GlowFitAPI.ProblemSolution] {
        (latest.problems_and_solutions ?? []).filter { !($0.problem ?? "").isEmpty }
    }

    // ملاحظة: دايماً في محتوى للمشاركة لأنه رابط التطبيق إجباري ولا يمكن إلغاؤه

    // MARK: - بناء الرسالة حسب اختيار المستخدمة
    private var message: String {
        var blocks: [String] = [L("report_share_intro")]

        if includeScore, let score = latest.skin_health_score {
            blocks.append(String(format: L("report_share_score"), score))
        }

        if includeMetrics && hasMetrics {
            var lines: [String] = []
            if let v = latest.moisture_level { lines.append("• \(L("metric_moisture")): \(v)%") }
            if let v = latest.acne_percentage { lines.append("• \(L("metric_acne")): \(v)%") }
            if let v = latest.dark_circles_percentage { lines.append("• \(L("metric_dark_circles")): \(v)%") }
            if let v = latest.fine_lines_percentage { lines.append("• \(L("metric_fine_lines")): \(v)%") }
            blocks.append(lines.joined(separator: "\n"))
        }

        if includeSummary && !summary.isEmpty {
            blocks.append(summary)
        }

        if includeRecommendations && !recommendations.isEmpty {
            let lines = recommendations.map { "• \($0)" }
            blocks.append(L("report_care_recommendations") + "\n" + lines.joined(separator: "\n"))
        }

        if includeProblems && !problems.isEmpty {
            let lines = problems.map { item -> String in
                let problem = item.problem ?? ""
                let solution = item.solution ?? ""
                return solution.isEmpty ? "• \(problem)" : "• \(problem): \(solution)"
            }
            blocks.append(L("report_problems_solutions") + "\n" + lines.joined(separator: "\n"))
        }

        // رابط تحميل التطبيق يُضاف دايماً — إجباري ومش قابل للإلغاء
        blocks.append(L("report_share_cta") + "\n" + Self.appStoreLink)

        return blocks.joined(separator: "\n\n")
    }

    // MARK: - الواجهة
    var body: some View {
        AccountSheet(title: L("share_options_title")) {
            Text(L("share_options_hint"))
                .font(.custom("Tajawal-Regular", size: 13))
                .foregroundColor(Color.white.opacity(0.5))

            VStack(spacing: 10) {
                if hasImage {
                    ShareOptionRow(icon: "🖼️", title: L("share_opt_image"), isOn: $includeImage)
                }
                if hasScore {
                    ShareOptionRow(icon: "📊", title: L("share_opt_score"), isOn: $includeScore)
                }
                if hasMetrics {
                    ShareOptionRow(icon: "🔍", title: L("share_opt_metrics"), isOn: $includeMetrics)
                }
                if !summary.isEmpty {
                    ShareOptionRow(icon: "📝", title: L("share_opt_summary"), isOn: $includeSummary)
                }
                if !recommendations.isEmpty {
                    ShareOptionRow(icon: "💡", title: L("share_opt_recommendations"), isOn: $includeRecommendations)
                }
                if !problems.isEmpty {
                    ShareOptionRow(icon: "🩺", title: L("share_opt_problems"), isOn: $includeProblems)
                }
                // رابط التطبيق إجباري دايماً — صف ثابت بدون مفتاح تفعيل
                HStack(spacing: 12) {
                    Text("🔗").font(.system(size: 20))
                    Text(L("share_opt_link"))
                        .font(.custom("Tajawal-Medium", size: 14))
                        .foregroundColor(.white)
                    Spacer()
                    Text(L("share_always_included"))
                        .font(.custom("Tajawal-Medium", size: 11))
                        .foregroundColor(AuthColors.primaryPurple)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.04))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L("share_preview_label"))
                    .font(.custom("Tajawal-Bold", size: 13))
                    .foregroundColor(Color.white.opacity(0.6))
                Text(message)
                    .font(.custom("Tajawal-Regular", size: 13))
                    .foregroundColor(Color.white.opacity(0.8))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(14)
            }

            Button(action: prepareAndShare) {
                HStack(spacing: 8) {
                    if isLoadingImage {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Text(L("share_button"))
                }
                .font(.custom("Tajawal-Bold", size: 17))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(14)
            }
            .disabled(isLoadingImage)
        }
        .shareSheet(isPresented: $showActivitySheet, items: shareItems)
    }

    private var shareItems: [Any] {
        var items: [Any] = [message]
        if includeImage, let img = scanImage {
            items.append(img)
        }
        return items
    }

    private func prepareAndShare() {
        // لو الصورة مطلوبة وما زلنا ما حمّلناها، نحمّلها أول قبل ما نفتح شيت المشاركة
        guard includeImage, hasImage, scanImage == nil, let path = latest.image_url else {
            showActivitySheet = true
            return
        }
        isLoadingImage = true
        GlowFitAPI.getSignedScanImageURL(path: path) { signedURLString in
            guard let signedURLString = signedURLString, let url = URL(string: signedURLString) else {
                isLoadingImage = false
                showActivitySheet = true
                return
            }
            URLSession.shared.dataTask(with: url) { data, _, _ in
                DispatchQueue.main.async {
                    isLoadingImage = false
                    if let data = data, let img = UIImage(data: data) {
                        scanImage = img
                    }
                    showActivitySheet = true
                }
            }.resume()
        }
    }
}

/// صف خيار واحد: أيقونة + عنوان + مفتاح تفعيل
struct ShareOptionRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 20))
            Text(title)
                .font(.custom("Tajawal-Medium", size: 14))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AuthColors.primaryPurple)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
