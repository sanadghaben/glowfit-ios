import SwiftUI

/// نافذة تخلّي المستخدمة تختار بنفسها شو تشارك من تقريرها (الدرجة، المقاييس، الملخص، التوصيات، المشاكل والحلول، رابط التطبيق)
struct ReportShareSheet: View {
    let latest: GlowFitAPI.ScanHistoryItem

    @State private var includeScore = true
    @State private var includeMetrics = true
    @State private var includeSummary = true
    @State private var includeRecommendations = true
    @State private var includeProblems = true
    @State private var includeLink = true

    private static let appStoreLink = "https://apps.apple.com/us/app/glowfit-ai/id6756659293"

    // MARK: - أي أقسام عندها بيانات فعلية (ما منعرض خيار قسم فاضي)
    private var hasScore: Bool { latest.skin_health_score != nil }
    private var hasMetrics: Bool {
        latest.moisture_level != nil || latest.acne_percentage != nil ||
        latest.dark_circles_percentage != nil || latest.fine_lines_percentage != nil
    }
    private var summary: String { (latest.summary_text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
    private var recommendations: [String] {
        (latest.recommendations ?? []).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    private var problems: [GlowFitAPI.ProblemSolution] {
        (latest.problems_and_solutions ?? []).filter { !($0.problem ?? "").isEmpty }
    }

    private var anythingSelected: Bool {
        (includeScore && hasScore)
            || (includeMetrics && hasMetrics)
            || (includeSummary && !summary.isEmpty)
            || (includeRecommendations && !recommendations.isEmpty)
            || (includeProblems && !problems.isEmpty)
            || includeLink
    }

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

        if includeLink {
            blocks.append(L("report_share_cta") + "\n" + Self.appStoreLink)
        }

        return blocks.joined(separator: "\n\n")
    }

    // MARK: - الواجهة
    var body: some View {
        AccountSheet(title: L("share_options_title")) {
            Text(L("share_options_hint"))
                .font(.custom("Tajawal-Regular", size: 13))
                .foregroundColor(Color.white.opacity(0.5))

            VStack(spacing: 10) {
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
                ShareOptionRow(icon: "🔗", title: L("share_opt_link"), isOn: $includeLink)
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

            if anythingSelected {
                ShareLink(item: message) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text(L("share_button"))
                    }
                    .font(.custom("Tajawal-Bold", size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
                }
            } else {
                Text(L("share_nothing_selected"))
                    .font(.custom("Tajawal-Medium", size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
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
