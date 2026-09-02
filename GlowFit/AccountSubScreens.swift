import SwiftUI
import PhotosUI

// MARK: - Shared Sheet Container
struct AccountSheet<Content: View>: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    @ViewBuilder let content: () -> Content
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {
                Capsule().fill(Color.white.opacity(0.15)).frame(width: 40, height: 4).padding(.top, 14)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                            .frame(width: 32, height: 32).background(Color.white.opacity(0.07)).clipShape(Circle())
                    }
                    Spacer()
                    Text(title).font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                Divider().background(Color.white.opacity(0.06))
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) { content() }
                        .padding(.horizontal, 20).padding(.vertical, 24)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileView: View {
    @State private var name  = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    @State private var showImageSource   = false
    @State private var showCamera        = false
    @State private var showPhotoLibrary  = false
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        AccountSheet(title: "تعديل الملف الشخصي") {
            // Avatar picker
            VStack(spacing: 12) {
                ZStack(alignment: .bottomLeading) {
                    ZStack {
                        Circle().stroke(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2).frame(width: 96, height: 96)
                        Circle().fill(Color(red: 0.1, green: 0.08, blue: 0.15)).frame(width: 90, height: 90)
                        if let img = selectedImage {
                            Image(uiImage: img).resizable().scaledToFill()
                                .frame(width: 86, height: 86).clipShape(Circle())
                        } else {
                            Text("👩🏻").font(.system(size: 44))
                        }
                    }
                    Button(action: { showImageSource = true }) {
                        ZStack {
                            Circle().fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                         startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 28, height: 28)
                                .overlay(Circle().stroke(Color(red:0.04,green:0.04,blue:0.07), lineWidth: 2))
                            Image(systemName: "camera.fill").font(.system(size: 11)).foregroundColor(.white)
                        }
                    }.offset(x: 4, y: 4)
                }
                Text("تغيير الصورة (قريباً)").font(.custom("Tajawal-Medium", size: 13)).foregroundColor(AuthColors.primaryPurple.opacity(0.6))
            }
            .frame(maxWidth: .infinity)

            // Fields
            EditField(label: "الاسم الكامل",       icon: "person.fill",  text: $name)
            EditField(label: "البريد الإلكتروني (غير قابل للتعديل)", icon: "envelope.fill", text: $email, keyboardType: .emailAddress)
                .disabled(true)
                .opacity(0.5)
            EditField(label: "رقم الجوال",          icon: "phone.fill",    text: $phone, keyboardType: .phonePad)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.custom("Tajawal-Medium", size: 13))
                    .foregroundColor(Color(red: 248/255, green: 113/255, blue: 113/255))
            }

            Button(action: saveChanges) {
                if isSaving {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                } else {
                    Text("حفظ التغييرات")
                        .font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                }
            }
            .disabled(isSaving || isLoading)
            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(14).shadow(color: AuthColors.primaryPurple.opacity(0.3), radius: 10, y: 5)
        }
        // Image source picker (اختيار الصورة فقط لهلق، الرفع الفعلي رح ينضاف لاحقاً)
        .confirmationDialog("اختاري مصدر الصورة", isPresented: $showImageSource, titleVisibility: .visible) {
            Button("الكاميرا")      { showCamera = true }
            Button("مكتبة الصور")  { showPhotoLibrary = true }
            Button("إلغاء", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoLibrary, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { item in
            guard let item = item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run { selectedImage = img }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) { CameraView(capturedImage: $selectedImage) }
        .onAppear(perform: loadProfile)
    }

    private func loadProfile() {
        GlowFitAPI.fetchMyProfile { result in
            isLoading = false
            switch result {
            case .success(let profile):
                name = profile.full_name ?? ""
                email = profile.email ?? (GlowFitAPI.currentUserEmail ?? "")
                phone = profile.phone ?? ""
            case .failure(let message):
                errorMessage = message
            }
        }
    }

    private func saveChanges() {
        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil
        GlowFitAPI.updateMyProfile(fullName: name, phone: phone) { result in
            isSaving = false
            switch result {
            case .success:
                dismiss()
            case .failure(let message):
                errorMessage = message
            }
        }
    }
}

// MARK: - Camera View Wrapper
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera; picker.delegate = context.coordinator; return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.capturedImage = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
    }
}

// MARK: - Edit Field
struct EditField: View {
    let label: String; let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.custom("Tajawal-Medium", size: 13)).foregroundColor(Color.white.opacity(0.5))
            HStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(Color.white.opacity(0.3)).frame(width: 20)
                TextField("", text: $text).font(.custom("Tajawal-Regular", size: 15)).foregroundColor(.white)
                    .keyboardType(keyboardType).autocapitalization(.none)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.white.opacity(0.04)).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
}

// MARK: - Notifications Settings
struct NotificationsSettingsView: View {
    @State private var dailyReminder  = true
    @State private var scanReminder   = true
    @State private var productUpdates = false
    @State private var aiInsights     = true
    @State private var showTimePicker = false
    @State private var reminderTime   = Date()

    var formattedTime: String {
        let f = DateFormatter(); f.timeStyle = .short; f.locale = Locale(identifier: "ar")
        return f.string(from: reminderTime)
    }
    var body: some View {
        AccountSheet(title: "الإشعارات والتذكير") {
            VStack(spacing: 0) {
                NotifToggleRow(icon: "sun.max.fill", iconColor: .orange,  title: "تذكير الروتين اليومي",    subtitle: "صباحاً ومساءً",            isOn: $dailyReminder)
                Divider().background(Color.white.opacity(0.05))
                NotifToggleRow(icon: "camera.fill",  iconColor: .purple,  title: "تذكير فحص البشرة",        subtitle: "كل أسبوع",                  isOn: $scanReminder)
                Divider().background(Color.white.opacity(0.05))
                NotifToggleRow(icon: "sparkles",     iconColor: .pink,    title: "رؤى الذكاء الاصطناعي",   subtitle: "تحليلات ونصائح جديدة",      isOn: $aiInsights)
                Divider().background(Color.white.opacity(0.05))
                NotifToggleRow(icon: "bag.fill",     iconColor: .blue,    title: "عروض المنتجات",           subtitle: "تحديثات المتجر",            isOn: $productUpdates)
            }
            .background(Color.white.opacity(0.03)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))

            VStack(alignment: .leading, spacing: 12) {
                Text("وقت التذكير").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                Button(action: { showTimePicker.toggle() }) {
                    HStack {
                        Image(systemName: "clock.fill").foregroundColor(AuthColors.primaryPurple)
                        Text(formattedTime).font(.custom("Tajawal-Medium", size: 15)).foregroundColor(.white)
                        Spacer()
                        Text("تغيير").font(.custom("Tajawal-Bold", size: 13)).foregroundColor(AuthColors.primaryPurple)
                    }
                    .padding(16).background(Color.white.opacity(0.03)).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                }
                if showTimePicker {
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel).labelsHidden().colorScheme(.dark)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct NotifToggleRow: View {
    let icon: String; let iconColor: Color; let title: String; let subtitle: String
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(iconColor.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.custom("Tajawal-Medium", size: 14)).foregroundColor(.white)
                Text(subtitle).font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
            }
            Spacer()
            Toggle("", isOn: $isOn).tint(AuthColors.primaryPurple).labelsHidden()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

// MARK: - Language Settings
struct LanguageSettingsView: View {
    @State private var selected = "ar"
    @Environment(\.dismiss) var dismiss
    let langs: [(id: String, flag: String, name: String, local: String)] = [
        ("ar","🇸🇦","العربية","Arabic"), ("en","🇺🇸","الإنجليزية","English"),
        ("fr","🇫🇷","الفرنسية","Français"), ("tr","🇹🇷","التركية","Türkçe"),
    ]
    var body: some View {
        AccountSheet(title: "لغة التطبيق") {
            VStack(spacing: 0) {
                ForEach(langs, id: \.id) { lang in
                    Button(action: { selected = lang.id }) {
                        HStack(spacing: 14) {
                            Text(lang.flag).font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lang.name).font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                                Text(lang.local).font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
                            }
                            Spacer()
                            if selected == lang.id {
                                ZStack {
                                    Circle().fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 24, height: 24)
                                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                                }
                            } else {
                                Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5).frame(width: 24, height: 24)
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 16)
                    }
                    if lang.id != langs.last?.id { Divider().background(Color.white.opacity(0.05)) }
                }
            }
            .background(Color.white.opacity(0.03)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))

            Button(action: { dismiss() }) {
                Text("تطبيق اللغة")
                    .font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
            }
        }
    }
}

// MARK: - Privacy & Security
struct PrivacySettingsView: View {
    @State private var biometric         = true
    @State private var showChangePassword = false
    @State private var showPrivacyPolicy  = false
    @State private var showTerms          = false
    @State private var showDeleteAlert    = false
    @State private var showContactUs      = false

    var body: some View {
        AccountSheet(title: "الخصوصية والأمان") {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.15)).frame(width: 36, height: 36)
                        Image(systemName: "faceid").font(.system(size: 18)).foregroundColor(.green)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Face ID / Touch ID").font(.custom("Tajawal-Medium", size: 14)).foregroundColor(.white)
                        Text("تسجيل دخول بالبصمة").font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
                    }
                    Spacer()
                    Toggle("", isOn: $biometric).tint(AuthColors.primaryPurple).labelsHidden()
                }
                .padding(16)
                Divider().background(Color.white.opacity(0.05))
                Button(action: { showChangePassword = true }) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.15)).frame(width: 36, height: 36)
                            Image(systemName: "key.fill").font(.system(size: 16)).foregroundColor(.orange)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("تغيير كلمة المرور").font(.custom("Tajawal-Medium", size: 14)).foregroundColor(.white)
                            Text("يُنصح بالتغيير كل 3 أشهر").font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
                        }
                        Spacer()
                        Image(systemName: "chevron.left").font(.system(size: 13)).foregroundColor(Color.white.opacity(0.3))
                    }.padding(16)
                }
            }
            .background(Color.white.opacity(0.03)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))

            VStack(alignment: .leading, spacing: 12) {
                Text("بيانات الخصوصية").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                // Privacy Policy
                Button(action: { showPrivacyPolicy = true }) {
                    PrivacyLinkRow(icon: "doc.text.fill",          color: .blue,   title: "سياسة الخصوصية")
                }
                // Terms
                Button(action: { showTerms = true }) {
                    PrivacyLinkRow(icon: "list.bullet.rectangle",  color: .purple, title: "الشروط والأحكام")
                }
                // Delete account
                Button(action: { showDeleteAlert = true }) {
                    PrivacyLinkRow(icon: "trash.fill",             color: .red,    title: "حذف الحساب")
                }
            }
        }
        .sheet(isPresented: $showChangePassword) { ChangePasswordView() }
        .sheet(isPresented: $showPrivacyPolicy)  { PrivacyPolicyView() }
        .sheet(isPresented: $showTerms)          { TermsConditionsView() }
        .sheet(isPresented: $showContactUs)      { ContactUsView() }
        .alert("حذف الحساب نهائياً", isPresented: $showDeleteAlert) {
            Button("حذف الحساب", role: .destructive) { /* handle delete */ }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("سيتم حذف جميع بياناتك وتاريخ فحوصاتك بشكل نهائي ولا يمكن التراجع عن هذا الإجراء.")
        }
    }
}

struct PrivacyLinkRow: View {
    let icon: String; let color: Color; let title: String
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 15)).foregroundColor(color)
            }
            Text(title).font(.custom("Tajawal-Medium", size: 14))
                .foregroundColor(color == .red ? Color(red: 0.99, green: 0.64, blue: 0.64) : .white)
            Spacer()
            Image(systemName: "chevron.left").font(.system(size: 13)).foregroundColor(Color.white.opacity(0.3))
        }
        .padding(16).background(Color.white.opacity(0.03)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}

struct ChangePasswordView: View {
    @State private var current = ""; @State private var newPass = ""; @State private var confirm = ""
    @State private var showSuccess = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        AccountSheet(title: "تغيير كلمة المرور") {
            EditField(label: "كلمة المرور الحالية",  icon: "lock.fill",      text: $current)
            EditField(label: "كلمة المرور الجديدة",  icon: "lock.open.fill", text: $newPass)
            EditField(label: "تأكيد كلمة المرور",    icon: "lock.open.fill", text: $confirm)
            Button(action: { showSuccess = true }) {
                Text("تحديث كلمة المرور")
                    .font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
            }
        }
        .alert("تم التحديث ✅", isPresented: $showSuccess) {
            Button("حسناً") { dismiss() }
        } message: { Text("تم تغيير كلمة المرور بنجاح.") }
    }
}

// MARK: - Help & Support
struct HelpSupportView: View {
    @State private var expandedFAQ: String? = nil
    @State private var showContactUs = false

    let faqs: [(q: String, a: String)] = [
        ("كيف أبدأ فحص البشرة؟", "اضغطي على زر 'فحص البشرة' في الشريط السفلي، ثم وجّهي الكاميرا نحو وجهك في ضوء جيد واتبعي التعليمات."),
        ("كم مرة يجب أن أفحص بشرتي؟", "ننصح بالفحص الأسبوعي للحصول على تتبع دقيق للتحسينات والتغيرات في بشرتك."),
        ("هل يمكنني تغيير روتيني اليومي؟", "نعم، يمكنك تعديل الروتين من شاشة الروتين والضغط على زر التعديل لكل خطوة."),
        ("كيف أُلغي اشتراكي في Premium؟", "اذهبي إلى الملف الشخصي > إدارة الاشتراك، ثم اتبعي خيار إلغاء الاشتراك."),
    ]

    var body: some View {
        AccountSheet(title: "المساعدة والدعم") {
            // Contact channels
            HStack(spacing: 10) {
                // Live Chat
                Button(action: { showContactUs = true }) {
                    SupportChannelCard(icon: "message.fill", label: "تواصل معنا", sub: "متاح 9ص–9م", color: AuthColors.primaryPurple)
                }
                // Email → opens ContactUsView
                Button(action: { showContactUs = true }) {
                    SupportChannelCard(icon: "envelope.fill", label: "البريد الإلكتروني", sub: "support@glowfit.ai", color: AuthColors.primaryPink)
                }
                // Phone
                Button(action: {
                    if let url = URL(string: "tel:800XXXXXXX") { UIApplication.shared.open(url) }
                }) {
                    SupportChannelCard(icon: "phone.fill", label: "اتصل بنا", sub: "800-XXX-XXXX", color: Color(red:0.23,green:0.65,blue:0.98))
                }
            }

            // FAQ
            VStack(alignment: .leading, spacing: 12) {
                Text("الأسئلة الشائعة").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                VStack(spacing: 8) {
                    ForEach(faqs, id: \.q) { faq in
                        FAQItem(question: faq.q, answer: faq.a, expanded: expandedFAQ == faq.q) {
                            withAnimation(.spring(response: 0.3)) {
                                expandedFAQ = expandedFAQ == faq.q ? nil : faq.q
                            }
                        }
                    }
                }
            }

            // Full contact form button
            Button(action: { showContactUs = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                    Text("إرسال رسالة للدعم")
                }
                .font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(14)
            }
        }
        .sheet(isPresented: $showContactUs) { ContactUsView() }
    }
}

struct SupportChannelCard: View {
    let icon: String; let label: String; let sub: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            }
            Text(label).font(.custom("Tajawal-Bold", size: 12)).foregroundColor(.white).multilineTextAlignment(.center)
            Text(sub).font(.custom("Tajawal-Regular", size: 10)).foregroundColor(Color.white.opacity(0.4)).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(Color.white.opacity(0.03)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.15), lineWidth: 1))
    }
}

struct FAQItem: View {
    let question: String; let answer: String; let expanded: Bool; let toggle: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                HStack {
                    Text(question).font(.custom("Tajawal-Medium", size: 14)).foregroundColor(.white).multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down").font(.system(size: 12)).foregroundColor(AuthColors.primaryPurple)
                }
                .padding(14)
            }
            if expanded {
                Text(answer).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(Color.white.opacity(0.6))
                    .lineSpacing(4).padding(.horizontal, 14).padding(.bottom, 14)
            }
        }
        .background(Color.white.opacity(0.03)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
