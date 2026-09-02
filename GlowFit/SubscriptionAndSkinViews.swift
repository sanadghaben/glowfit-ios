import SwiftUI

// MARK: - Subscription Management
struct SubscriptionManagementView: View {
    @State private var selectedPlan: String = "yearly"
    @State private var showCancelAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        AccountSheet(title: "إدارة الاشتراك") {

            // Current status
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(LinearGradient(colors:[AuthColors.primaryPurple.opacity(0.2),AuthColors.primaryPink.opacity(0.15)],startPoint:.topLeading,endPoint:.bottomTrailing)).frame(width:52,height:52)
                    Text("✨").font(.system(size:24))
                }
                VStack(alignment:.leading,spacing:4) {
                    Text("GlowFit Premium").font(.custom("Tajawal-Bold",size:16)).foregroundColor(.white)
                    Text("الاشتراك نشط • يتجدد 15 يونيو 2025").font(.custom("Tajawal-Regular",size:12)).foregroundColor(Color.white.opacity(0.5))
                }
                Spacer()
                Text("✅").font(.system(size:20))
            }
            .padding(16).background(LinearGradient(colors:[AuthColors.primaryPurple.opacity(0.15),AuthColors.primaryPink.opacity(0.1)],startPoint:.leading,endPoint:.trailing))
            .cornerRadius(16).overlay(RoundedRectangle(cornerRadius:16).stroke(AuthColors.primaryPurple.opacity(0.3),lineWidth:1))

            // Plans
            VStack(alignment:.leading,spacing:12) {
                Text("خطط الاشتراك").font(.custom("Tajawal-Bold",size:15)).foregroundColor(.white)
                PlanCard(id:"monthly", title:"شهري", price:"49 ر.س", period:"/ شهر", badge:nil, selected:$selectedPlan)
                PlanCard(id:"yearly",  title:"سنوي", price:"399 ر.س", period:"/ سنة", badge:"وفري 32%", selected:$selectedPlan)
                PlanCard(id:"lifetime",title:"مدى الحياة", price:"999 ر.س", period:"مرة واحدة", badge:"الأفضل قيمة", selected:$selectedPlan)
            }

            // Features list
            VStack(alignment:.leading,spacing:10) {
                Text("ما يتضمنه Premium").font(.custom("Tajawal-Bold",size:15)).foregroundColor(.white)
                ForEach(["فحص البشرة غير المحدود بالذكاء الاصطناعي",
                         "تقارير تفصيلية أسبوعية وشهرية",
                         "توصيات منتجات مخصصة لبشرتك",
                         "استشارات خبراء الجلدية",
                         "روتين ذكي يتكيف مع بشرتك"], id:\.self) { feat in
                    HStack(spacing:10) {
                        Image(systemName:"checkmark.circle.fill").foregroundColor(AuthColors.primaryPurple).font(.system(size:16))
                        Text(feat).font(.custom("Tajawal-Regular",size:13)).foregroundColor(Color.white.opacity(0.8))
                    }
                }
            }
            .padding(16).background(Color.white.opacity(0.03)).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius:14).stroke(Color.white.opacity(0.06),lineWidth:1))

            // Buttons
            Button(action: { dismiss() }) {
                Text("تأكيد الاشتراك في خطة \(selectedPlan == "monthly" ? "الشهرية" : selectedPlan == "yearly" ? "السنوية" : "مدى الحياة")")
                    .font(.custom("Tajawal-Bold",size:17)).foregroundColor(.white)
                    .frame(maxWidth:.infinity).padding(.vertical,16)
                    .background(LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.leading,endPoint:.trailing))
                    .cornerRadius(14).shadow(color:AuthColors.primaryPurple.opacity(0.3),radius:10,y:5)
            }

            Button(action: { showCancelAlert = true }) {
                Text("إلغاء الاشتراك")
                    .font(.custom("Tajawal-Medium",size:14)).foregroundColor(Color(red:0.99,green:0.64,blue:0.64))
                    .frame(maxWidth:.infinity).padding(.vertical,12)
                    .background(Color.red.opacity(0.07)).cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius:12).stroke(Color.red.opacity(0.15),lineWidth:1))
            }

            Text("يمكن الإلغاء في أي وقت قبل 24 ساعة من التجديد")
                .font(.custom("Tajawal-Regular",size:11)).foregroundColor(Color.white.opacity(0.3))
                .frame(maxWidth:.infinity).multilineTextAlignment(.center)
        }
        .alert("إلغاء الاشتراك", isPresented: $showCancelAlert) {
            Button("تأكيد الإلغاء", role: .destructive) { dismiss() }
            Button("الإبقاء على الاشتراك", role: .cancel) {}
        } message: { Text("سيتم إلغاء اشتراكك في نهاية الفترة الحالية ولن يتم تجديده.") }
    }
}

struct PlanCard: View {
    let id: String; let title: String; let price: String; let period: String; let badge: String?
    @Binding var selected: String
    var isSelected: Bool { selected == id }
    var body: some View {
        Button(action: { withAnimation { selected = id } }) {
            HStack(spacing:14) {
                ZStack {
                    Circle().stroke(isSelected ? LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.topLeading,endPoint:.bottomTrailing) : LinearGradient(colors:[Color.white.opacity(0.2)],startPoint:.leading,endPoint:.trailing), lineWidth:2).frame(width:22,height:22)
                    if isSelected { Circle().fill(LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.topLeading,endPoint:.bottomTrailing)).frame(width:12,height:12) }
                }
                Text(title).font(.custom("Tajawal-Bold",size:15)).foregroundColor(.white)
                if let b = badge {
                    Text(b).font(.custom("Tajawal-Bold",size:10)).foregroundColor(AuthColors.primaryPink)
                        .padding(.horizontal,8).padding(.vertical,3).background(AuthColors.primaryPink.opacity(0.1)).cornerRadius(6)
                }
                Spacer()
                VStack(alignment:.trailing,spacing:1) {
                    Text(price).font(.custom("Tajawal-Bold",size:16)).foregroundColor(isSelected ? AuthColors.primaryPurple : .white)
                    Text(period).font(.custom("Tajawal-Regular",size:11)).foregroundColor(Color.white.opacity(0.4))
                }
            }
            .padding(16)
            .background(isSelected ? AuthColors.primaryPurple.opacity(0.08) : Color.white.opacity(0.03))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius:14).stroke(isSelected ? AuthColors.primaryPurple.opacity(0.4) : Color.white.opacity(0.06),lineWidth:1))
        }
    }
}

// MARK: - Skin Type Update
struct SkinTypeUpdateView: View {
    @State private var profile: GlowFitAPI.GFProfile? = nil
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss

    private let skinTypeInfo: [String: (icon: String, label: String, desc: String)] = [
        "combination": ("💧", "مختلطة", "دهنية في المنطقة T وجافة في الخدين"),
        "dry": ("🌿", "جافة", "تحتاج لترطيب مستمر ومكثف"),
        "oily": ("✨", "دهنية", "إفراز زائد للزيوت طوال اليوم"),
        "normal": ("🌸", "عادية", "بشرة متوازنة ومتجانسة"),
        "sensitive": ("🛡", "حساسة", "تتفاعل بسرعة مع المنتجات")
    ]

    private let concernLabels: [String: String] = [
        "acne": "حب الشباب", "dryness": "جفاف", "oiliness": "زيوت زائدة",
        "pores": "مسام واسعة", "pigmentation": "تصبغات", "dark_circles": "هالات سوداء",
        "fine_lines": "خطوط دقيقة", "sensitivity": "حساسية"
    ]

    var body: some View {
        AccountSheet(title: "ملف بشرتك") {
            if isLoading {
                ProgressView().tint(.white).frame(maxWidth: .infinity).padding(.vertical, 40)
            } else if let type = profile?.skin_type, let info = skinTypeInfo[type] {
                VStack(spacing: 16) {
                    Text(info.icon).font(.system(size: 44))
                    Text(info.label).font(.custom("Tajawal-Bold", size: 22)).foregroundColor(.white)
                    Text(info.desc).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)

                if let concerns = profile?.skin_concerns, !concerns.isEmpty {
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("المخاوف المكتشفة").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                        FlowLayout(spacing: 10) {
                            ForEach(concerns, id: \.self) { concern in
                                Text(concernLabels[concern] ?? concern)
                                    .font(.custom("Tajawal-Medium", size: 13))
                                    .foregroundColor(Color(red: 0.75, green: 0.52, blue: 0.99))
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(AuthColors.primaryPurple.opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                VStack(spacing: 10) {
                    Text("📸 هاي البيانات مأخوذة من آخر فحص بشرة سويتيه بالذكاء الاصطناعي")
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                    Text("عشان تتحدّث، لازم تسوّي فحص جديد — مش تعديل يدوي، عشان النتيجة تضل دقيقة وموثوقة 💡")
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 10)
            } else {
                VStack(spacing: 14) {
                    Text("🔍").font(.system(size: 44))
                    Text("لسا ما سويتِ فحص بشرة")
                        .font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                    Text("روحي لتبويب 'فحص البشرة' وسوّي فحصك الأول عشان يظهر هون نوع بشرتك الحقيقي")
                        .font(.custom("Tajawal-Regular", size: 13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }

            Button(action: { dismiss() }) {
                Text("تم")
                    .font(.custom("Tajawal-Bold",size:17)).foregroundColor(.white)
                    .frame(maxWidth:.infinity).padding(.vertical,16)
                    .background(LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.leading,endPoint:.trailing))
                    .cornerRadius(14).shadow(color:AuthColors.primaryPurple.opacity(0.3),radius:10,y:5)
            }
        }
        .onAppear {
            GlowFitAPI.fetchMyProfile { result in
                isLoading = false
                if case .success(let p) = result { profile = p }
            }
        }
    }
}

#Preview { SubscriptionManagementView() }
