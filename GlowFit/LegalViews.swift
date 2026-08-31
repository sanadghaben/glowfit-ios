import SwiftUI

// MARK: - Privacy Policy
struct PrivacyPolicyView: View {
    var body: some View {
        AccountSheet(title: "سياسة الخصوصية") {
            LegalHeaderBadge(icon: "🔒", title: "سياسة الخصوصية", updated: "آخر تحديث: مايو 2025")
            ForEach(privacySections, id: \.title) { LegalSection(item: $0) }
        }
    }
    let privacySections: [LegalItem] = [
        LegalItem(icon: "📋", title: "المعلومات التي نجمعها", body: "نقوم بجمع المعلومات التي تقدمينها مباشرةً عند إنشاء الحساب مثل الاسم والبريد الإلكتروني، إضافةً إلى بيانات الاستخدام وصور البشرة التي تُستخدم حصرياً لتحليل الذكاء الاصطناعي."),
        LegalItem(icon: "🤖", title: "كيف نستخدم بياناتك", body: "تُستخدم بياناتك لتقديم تحليلات مخصصة لبشرتك، وتحسين توصيات الروتين اليومي، وتطوير دقة نماذج الذكاء الاصطناعي لديها. لا نبيع بياناتك لأي طرف ثالث."),
        LegalItem(icon: "🛡", title: "حماية البيانات", body: "نستخدم تشفير AES-256 لحماية بياناتك أثناء النقل والتخزين. يتم تخزين جميع البيانات على خوادم آمنة موثقة وفق معايير ISO 27001."),
        LegalItem(icon: "🌍", title: "مشاركة البيانات", body: "لا نشارك بياناتك الشخصية مع أطراف ثالثة إلا بموافقتك الصريحة، أو عند الضرورة القانونية، أو مع مزودي الخدمة الموثوقين الذين يلتزمون بسياسة خصوصية صارمة."),
        LegalItem(icon: "🗑", title: "حذف البيانات", body: "يحق لك في أي وقت طلب حذف جميع بياناتك الشخصية من خوادمنا. يمكنك ذلك من خلال الإعدادات > الخصوصية > حذف الحساب، أو عبر التواصل مع فريق الدعم."),
        LegalItem(icon: "📱", title: "ملفات تعريف الارتباط", body: "نستخدم ملفات تعريف الارتباط لتحسين تجربتك وتذكر تفضيلاتك. يمكنك التحكم في هذه الإعدادات من متصفحك أو إعدادات التطبيق."),
        LegalItem(icon: "📞", title: "التواصل بخصوص الخصوصية", body: "لأي استفسار بخصوص خصوصيتك يمكن التواصل مع مسؤول حماية البيانات على: privacy@glowfit.ai"),
    ]
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
