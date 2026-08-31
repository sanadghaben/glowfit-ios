import SwiftUI

// MARK: - Privacy Policy
struct PrivacyPolicyView: View {
    @State private var content: String = ""
    @State private var isLoading = true
    @State private var loadError = false

    var body: some View {
        AccountSheet(title: "سياسة الخصوصية") {
            LegalHeaderBadge(icon: "🔒", title: "سياسة الخصوصية", updated: "يُحدَّث تلقائياً")

            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if loadError {
                Text("تعذّر تحميل سياسة الخصوصية حالياً، تأكدي من الإنترنت وحاولي مرة ثانية.")
                    .font(.custom("Tajawal-Regular", size: 14))
                    .foregroundColor(Color.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                Text(content)
                    .font(.custom("Tajawal-Regular", size: 14))
                    .foregroundColor(Color.white.opacity(0.75))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(14)
            }
        }
        .onAppear(perform: loadContent)
    }

    private func loadContent() {
        guard let url = URL(string: "\(GlowFitAPI.supabaseURL)/rest/v1/site_content?select=content&key=eq.privacy_policy") else {
            isLoading = false
            loadError = true
            return
        }
        var request = URLRequest(url: url)
        request.setValue(GlowFitAPI.anonKey, forHTTPHeaderField: "apikey")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                guard error == nil, let data = data,
                      let rows = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                      let first = rows.first,
                      let text = first["content"] as? String, !text.isEmpty else {
                    loadError = true
                    return
                }
                content = text
            }
        }.resume()
    }
}

// MARK: - Terms & Conditions
struct TermsConditionsView: View {
    @State private var accepted = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        AccountSheet(title: "الشروط والأحكام") {
            LegalHeaderBadge(icon: "📄", title: "الشروط والأحكام", updated: "سارية المفعول من: يناير 2025")
            ForEach(termsSections, id: \.title) { LegalSection(item: $0) }

            // Accept section
            HStack(alignment: .top, spacing: 12) {
                Button(action: { withAnimation { accepted.toggle() } }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(accepted ? LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.topLeading,endPoint:.bottomTrailing) : LinearGradient(colors:[Color.white.opacity(0.05)],startPoint:.leading,endPoint:.trailing))
                            .frame(width: 22, height: 22)
                            .overlay(RoundedRectangle(cornerRadius:6).stroke(Color.white.opacity(accepted ? 0 : 0.2),lineWidth:1))
                        if accepted { Image(systemName:"checkmark").font(.system(size:11,weight:.bold)).foregroundColor(.white) }
                    }
                }
                Text("أوافق على جميع الشروط والأحكام المذكورة أعلاه")
                    .font(.custom("Tajawal-Regular",size:13))
                    .foregroundColor(Color.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius:12).stroke(accepted ? AuthColors.primaryPurple.opacity(0.3) : Color.white.opacity(0.06),lineWidth:1))

            Button(action: { if accepted { dismiss() } }) {
                Text("تأكيد القبول")
                    .font(.custom("Tajawal-Bold",size:17)).foregroundColor(.white)
                    .frame(maxWidth:.infinity).padding(.vertical,16)
                    .background(accepted
                                ? LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.leading,endPoint:.trailing)
                                : LinearGradient(colors:[Color.white.opacity(0.08)],startPoint:.leading,endPoint:.trailing))
                    .cornerRadius(14)
            }
            .disabled(!accepted)
        }
    }
    let termsSections: [LegalItem] = [
        LegalItem(icon: "✅", title: "قبول الشروط", body: "باستخدامك تطبيق GlowFit AI، فإنك توافقين على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافقين على أي جزء منها، يُرجى التوقف عن استخدام التطبيق."),
        LegalItem(icon: "👤", title: "حساب المستخدم", body: "أنت مسؤولة عن الحفاظ على سرية بيانات حسابك وكلمة مرورك. يجب إخطارنا فوراً عند الاشتباه بأي استخدام غير مصرح به لحسابك."),
        LegalItem(icon: "💎", title: "الاشتراك والدفع", body: "تتجدد اشتراكات Premium تلقائياً ما لم يتم إلغاؤها قبل 24 ساعة من انتهاء الفترة الحالية. الأسعار قابلة للتغيير مع إشعار مسبق لا يقل عن 30 يوماً."),
        LegalItem(icon: "⚕️", title: "إخلاء المسؤولية الطبية", body: "تحليلات GlowFit AI هي للأغراض المعلوماتية فقط وليست بديلاً عن الاستشارة الطبية المتخصصة. يُنصح دائماً بمراجعة طبيب جلدية متخصص."),
        LegalItem(icon: "🚫", title: "الاستخدام المقبول", body: "يُحظر استخدام التطبيق لأي غرض غير مشروع، أو نشر محتوى مسيء، أو محاولة اختراق الأنظمة، أو إعادة بيع الخدمات دون إذن صريح."),
        LegalItem(icon: "⚖️", title: "القانون الحاكم", body: "تخضع هذه الشروط لقوانين المملكة العربية السعودية، وأي نزاعات تُحسم عبر التحكيم وفق قواعد مركز التحكيم التجاري الخليجي."),
    ]
}

// MARK: - Shared Legal Components
struct LegalItem { let icon: String; let title: String; let body: String }

struct LegalHeaderBadge: View {
    let icon: String; let title: String; let updated: String
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(LinearGradient(colors:[AuthColors.primaryPurple.opacity(0.2),AuthColors.primaryPink.opacity(0.15)],startPoint:.topLeading,endPoint:.bottomTrailing)).frame(width:64,height:64)
                Text(icon).font(.system(size:28))
            }
            Text(updated).font(.custom("Tajawal-Regular",size:12)).foregroundColor(Color.white.opacity(0.35))
                .padding(.horizontal,12).padding(.vertical,5)
                .background(Color.white.opacity(0.04)).cornerRadius(8)
        }
        .frame(maxWidth:.infinity)
        .padding(.vertical,8)
    }
}

struct LegalSection: View {
    let item: LegalItem
    @State private var expanded = true
    var body: some View {
        VStack(alignment:.leading,spacing:0) {
            Button(action:{ withAnimation(.spring(response:0.3)){ expanded.toggle() } }) {
                HStack(spacing:12) {
                    Text(item.icon).font(.system(size:18))
                    Text(item.title).font(.custom("Tajawal-Bold",size:14)).foregroundColor(.white)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down").font(.system(size:12)).foregroundColor(AuthColors.primaryPurple)
                }
                .padding(14)
            }
            if expanded {
                Text(item.body)
                    .font(.custom("Tajawal-Regular",size:13))
                    .foregroundColor(Color.white.opacity(0.65))
                    .lineSpacing(5)
                    .padding(.horizontal,14).padding(.bottom,14)
            }
        }
        .background(Color.white.opacity(0.03))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius:14).stroke(Color.white.opacity(0.06),lineWidth:1))
    }
}

#Preview { PrivacyPolicyView() }
