import SwiftUI

struct SignupView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var isFemale = true
    @State private var agreeTerms = false
    @State private var selectedCountryCode = "+966"
    
    @State private var fullNameError: String? = nil
    @State private var emailError: String? = nil
    @State private var phoneError: String? = nil
    @State private var passwordError: String? = nil
    @State private var navigateToOTP = false
    
    @State private var showPrivacyPolicy = false
    @State private var isLoading = false
    @State private var generalError: String? = nil
    
    var body: some View {
        ZStack {
            AuthBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Logo Section
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 15/255, green: 12/255, blue: 20/255).opacity(0.9))
                                .frame(width: 90, height: 90)
                                .overlay(Circle().stroke(AuthColors.primaryPurple.opacity(0.25), lineWidth: 1))
                                .shadow(color: AuthColors.primaryPurple.opacity(0.15), radius: 20)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 35))
                                .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        
                        Text("حساب جديد")
                            .font(.custom("Tajawal-Black", size: 28))
                            .fontWeight(.black)
                            .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        Text("ابدأي رحلتك مع GlowFit ✨")
                            .font(.custom("Tajawal-Light", size: 14))
                            .foregroundColor(AuthColors.textSecondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Inputs
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("الاسم الكامل")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            CustomTextField(icon: "👤", placeholder: "أدخلي اسمك الكامل", text: $fullName, errorMessage: fullNameError)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("البريد الإلكتروني")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            CustomTextField(icon: "📧", placeholder: "example@email.com", text: $email, keyboardType: .emailAddress, textAlignment: .trailing, errorMessage: emailError)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("رقم الجوال")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            
                            HStack(spacing: 10) {
                                // Country Code Picker mock
                                Menu {
                                    Button("🇸🇦 +966") { selectedCountryCode = "+966" }
                                    Button("🇦🇪 +971") { selectedCountryCode = "+971" }
                                    Button("🇪🇬 +20") { selectedCountryCode = "+20" }
                                } label: {
                                    HStack {
                                        Text(selectedCountryCode)
                                        Image(systemName: "chevron.down").font(.system(size: 10))
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 10)
                                    .frame(width: 90)
                                    .background(AuthColors.inputBackground)
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AuthColors.inputBorder, lineWidth: 1))
                                    .foregroundColor(.white)
                                    .font(.custom("Tajawal-Regular", size: 14))
                                    .environment(\.layoutDirection, .leftToRight)
                                }
                                
                                CustomTextField(icon: "", placeholder: "5XX XXX XXX", text: $phone, keyboardType: .phonePad, textAlignment: .trailing, errorMessage: phoneError)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("كلمة المرور")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            CustomTextField(icon: "🔒", placeholder: "8 أحرف على الأقل", text: $password, isSecure: true, textAlignment: .trailing, errorMessage: passwordError)
                        }
                        
                        // Gender
                        VStack(alignment: .leading, spacing: 8) {
                            Text("الجنس")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            
                            HStack(spacing: 10) {
                                Button(action: { isFemale = true }) {
                                    VStack(spacing: 4) {
                                        Text("👩").font(.system(size: 24))
                                        Text("أنثى").font(.custom("Tajawal-Medium", size: 14))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isFemale ? AuthColors.primaryPurple.opacity(0.1) : AuthColors.cardBackground)
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(isFemale ? AuthColors.primaryPurple.opacity(0.4) : AuthColors.cardBorder, lineWidth: 1))
                                    .foregroundColor(isFemale ? AuthColors.primaryPurple : AuthColors.textSecondary)
                                }
                                
                                Button(action: { isFemale = false }) {
                                    VStack(spacing: 4) {
                                        Text("👨").font(.system(size: 24))
                                        Text("ذكر").font(.custom("Tajawal-Medium", size: 14))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!isFemale ? AuthColors.primaryPurple.opacity(0.1) : AuthColors.cardBackground)
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(!isFemale ? AuthColors.primaryPurple.opacity(0.4) : AuthColors.cardBorder, lineWidth: 1))
                                    .foregroundColor(!isFemale ? AuthColors.primaryPurple : AuthColors.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Terms
                    HStack {
                        Button(action: { agreeTerms.toggle() }) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(agreeTerms ? LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [AuthColors.inputBackground], startPoint: .top, endPoint: .bottom))
                                .frame(width: 20, height: 20)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(agreeTerms ? .clear : Color.white.opacity(0.15), lineWidth: 1))
                                .overlay(
                                    Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white).opacity(agreeTerms ? 1 : 0)
                                )
                        }
                        
                        HStack(spacing: 4) {
                            Text("أوافق على")
                                .foregroundColor(AuthColors.textSecondary)
                            Button(action: {
                                showPrivacyPolicy = true
                            }) {
                                Text("الشروط وسياسة الخصوصية")
                                    .foregroundColor(AuthColors.primaryPurple.opacity(0.7))
                                    .underline()
                            }
                        }
                        .font(.custom("Tajawal-Regular", size: 13))
                        
                        Spacer()
                    }
                    
                    if let generalError = generalError {
                        HStack(spacing: 6) {
                            Text("⚠")
                                .font(.system(size: 14))
                            Text(generalError)
                                .font(.custom("Tajawal-Medium", size: 14))
                        }
                        .foregroundColor(Color(red: 248/255, green: 113/255, blue: 113/255))
                        .padding(.horizontal, 4)
                        .padding(.bottom, 5)
                        .transition(.opacity)
                    }
                    
                    // Signup Button
                    ZStack {
                        PrimaryButton(title: isLoading ? "" : "إنشاء الحساب", action: {
                            guard !isLoading else { return }
                            withAnimation {
                                fullNameError = fullName.isEmpty ? "هذا الحقل مطلوب" : nil
                                emailError = (email.isEmpty || !email.contains("@")) ? "يرجى إدخال بريد إلكتروني صحيح" : nil
                                phoneError = phone.isEmpty ? "رقم الجوال مطلوب" : nil
                                passwordError = password.count < 8 ? "كلمة المرور يجب أن تكون 8 أحرف على الأقل" : nil
                            }
                            
                            if fullNameError == nil && emailError == nil && phoneError == nil && passwordError == nil {
                                registerUser()
                            }
                        })
                        .disabled(isLoading || !agreeTerms)
                        .opacity((!agreeTerms) ? 0.6 : 1.0)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    
                    NavigationLink(destination: OTPView(email: email), isActive: $navigateToOTP) {
                        EmptyView()
                    }
                    
                    // Divider
                    HStack {
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                        Text("أو")
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                            .padding(.horizontal, 10)
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                    }
                    .padding(.vertical, 5)
                    
                    // Social Buttons
                    HStack(spacing: 12) {
                        SocialButton(title: "Google", iconName: "G", isSystemImage: false, action: {})
                        SocialButton(title: "Apple", iconName: "applelogo", isSystemImage: true, action: {})
                    }
                    
                    // Footer
                    HStack(spacing: 4) {
                        Text("لديك حساب بالفعل؟")
                            .foregroundColor(AuthColors.textSecondary)
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("تسجيل الدخول")
                                .foregroundColor(AuthColors.primaryPurple)
                                .fontWeight(.bold)
                        }
                    }
                    .font(.custom("Tajawal-Regular", size: 14))
                    .padding(.top, 10)
                }
                .authCardStyle()
                .padding(.vertical, 40)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
    
    // MARK: - Supabase Signup Request
    func registerUser() {
        guard fullNameError == nil && emailError == nil && phoneError == nil && passwordError == nil else { return }
        guard agreeTerms else {
            withAnimation {
                generalError = "يرجى الموافقة على الشروط وسياسة الخصوصية أولاً"
            }
            return
        }
        
        withAnimation {
            generalError = nil
            isLoading = true
        }
        
        var formattedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if formattedPhone.hasPrefix("0") {
            formattedPhone.removeFirst()
        }
        let fullPhone = selectedCountryCode + formattedPhone
        
        let signupData: [String: Any] = [
            "full_name": fullName,
            "phone": fullPhone,
            "gender": isFemale ? "female" : "male"
        ]
        
        let body: [String: Any] = [
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
            "password": password,
            "data": signupData
        ]
        
        guard let url = URL(string: "https://ojaxkhkbyfkcwgavxihq.supabase.co/auth/v1/signup") else {
            withAnimation {
                isLoading = false
                generalError = "رابط الباك آند غير صحيح"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9qYXhraGtieWZrY3dnYXZ4aWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2NTIxNjQsImV4cCI6MjA5MzIyODE2NH0.g5fsf1h9nQ1E3XpBCKMIVkVb7lMCp0uUc5SLUEdNZpM"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            withAnimation {
                isLoading = false
                generalError = "خطأ في معالجة البيانات"
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation {
                    self.isLoading = false
                }
                
                if let error = error {
                    withAnimation {
                        self.generalError = "خطأ في الاتصال بالشبكة: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    withAnimation {
                        self.generalError = "استجابة غير صالحة من خادم الباك آند"
                    }
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // فحص مهم: Supabase بيرجع 200 حتى لو الإيميل مسجل مسبقاً (لأسباب أمنية)،
                    // بس بيرجع identities فاضية بهذي الحالة بدل ما يبعث رمز تحقق جديد
                    var alreadyRegistered = false
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let identities = json["identities"] as? [Any] {
                        alreadyRegistered = identities.isEmpty
                    }

                    withAnimation {
                        if alreadyRegistered {
                            self.generalError = "هذا البريد الإلكتروني مسجل عندنا بالفعل. سجّلي دخول بدلاً من ذلك."
                        } else {
                            self.navigateToOTP = true
                        }
                    }
                } else {
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let errorMsg = json["msg"] as? String ?? (json["error_description"] as? String) {
                                withAnimation {
                                    self.generalError = self.translateError(errorMsg)
                                }
                                return
                            }
                        } catch {
                            // ignore json error
                        }
                    }
                    
                    withAnimation {
                        self.generalError = "حدث خطأ أثناء إنشاء الحساب (رمز الخطأ: \(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }
    func translateError(_ msg: String) -> String {
        if msg.contains("User already registered") {
            return "هذا البريد الإلكتروني مسجل بالفعل"
        } else if msg.contains("Password should be at least") {
            return "كلمة المرور يجب أن تكون 8 أحرف على الأقل"
        } else if msg.contains("Signup requires a valid email") {
            return "يرجى إدخال بريد إلكتروني صحيح"
        } else if msg.contains("rate limit") {
            return "تم تجاوز حد الطلبات المسموح به، يرجى المحاولة لاحقاً"
        }
        return msg
    }
}
