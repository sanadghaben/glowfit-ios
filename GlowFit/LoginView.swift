import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = true
    
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    // For navigation using NavigationStack/NavigationLink
    // Depending on iOS target, we can use NavigationLink directly
    
    var body: some View {
        ZStack {
            AuthBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Logo Section
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 15/255, green: 12/255, blue: 20/255).opacity(0.9))
                                .frame(width: 90, height: 90)
                                .overlay(
                                    Circle().stroke(AuthColors.primaryPurple.opacity(0.25), lineWidth: 1)
                                )
                                .shadow(color: AuthColors.primaryPurple.opacity(0.15), radius: 20)
                            
                            // Placeholder for Logo
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        }
                        .padding(.bottom, 4)
                        
                        Text("GlowFit AI")
                            .font(.custom("Tajawal-Black", size: 28))
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        
                        Text("مرحباً بعودتك 💜")
                            .font(.custom("Tajawal-Light", size: 14))
                            .foregroundColor(AuthColors.textSecondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Inputs
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("البريد الإلكتروني")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            CustomTextField(icon: "📧", placeholder: "example@email.com", text: $email, keyboardType: .emailAddress, textAlignment: .trailing, errorMessage: emailError)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("كلمة المرور")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            CustomTextField(icon: "🔒", placeholder: "••••••••", text: $password, isSecure: true, textAlignment: .trailing, errorMessage: passwordError)
                        }
                    }
                    
                    // Forgot Password & Remember Me
                    HStack {
                        Button(action: {
                            rememberMe.toggle()
                        }) {
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(rememberMe ? LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [AuthColors.inputBackground], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6).stroke(rememberMe ? .clear : Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .opacity(rememberMe ? 1 : 0)
                                    )
                                
                                Text("تذكرني")
                                    .font(.custom("Tajawal-Regular", size: 13))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("نسيت كلمة المرور؟")
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.primaryPurple.opacity(0.7))
                        }
                    }
                    .padding(.top, -5)
                    .padding(.bottom, 5)
                    
                    // Login Button
                    PrimaryButton(title: "تسجيل الدخول", action: {
                        // Simple Validation
                        withAnimation {
                            if email.isEmpty || !email.contains("@") {
                                emailError = "يرجى إدخال بريد إلكتروني صحيح"
                            } else {
                                emailError = nil
                            }
                            
                            if password.isEmpty {
                                passwordError = "يرجى إدخال كلمة المرور"
                            } else {
                                passwordError = nil
                            }
                        }
                        
                        if emailError == nil && passwordError == nil {
                            // Successfully validated, perform login
                            withAnimation {
                                isLoggedIn = true
                            }
                        }
                    })
                    
                    // Divider
                    HStack {
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                        Text("أو")
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                            .padding(.horizontal, 10)
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                    }
                    .padding(.vertical, 10)
                    
                    // Social Buttons
                    HStack(spacing: 12) {
                        SocialButton(title: "Google", iconName: "G", isSystemImage: false, action: {})
                        SocialButton(title: "Apple", iconName: "applelogo", isSystemImage: true, action: {})
                    }
                    
                    // Biometric
                    VStack(spacing: 8) {
                        Button(action: {}) {
                            Circle()
                                .stroke(AuthColors.inputBorder, lineWidth: 1)
                                .background(Circle().fill(AuthColors.inputBackground))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("👆").font(.system(size: 28))
                                )
                        }
                        Text("Face ID / Touch ID")
                            .font(.custom("Tajawal-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.25))
                    }
                    .padding(.top, 5)
                    
                    // Footer
                    HStack(spacing: 4) {
                        Text("ليس لديك حساب؟")
                            .foregroundColor(AuthColors.textSecondary)
                        NavigationLink(destination: SignupView()) {
                            Text("إنشاء حساب")
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
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
        .preferredColorScheme(.dark)
    }
}
