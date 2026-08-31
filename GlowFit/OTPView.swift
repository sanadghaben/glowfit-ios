import SwiftUI

struct OTPView: View {
    @Environment(\.presentationMode) var presentationMode
    let email: String

    @State private var otp1 = ""
    @State private var otp2 = ""
    @State private var otp3 = ""
    @State private var otp4 = ""
    @State private var otp5 = ""
    @State private var otp6 = ""

    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        ZStack {
            AuthBackgroundView()
            
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    // Logo Section
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 15/255, green: 12/255, blue: 20/255).opacity(0.9))
                                .frame(width: 65, height: 65)
                                .overlay(Circle().stroke(AuthColors.primaryPurple.opacity(0.25), lineWidth: 1))
                                .shadow(color: AuthColors.primaryPurple.opacity(0.12), radius: 15)
                            
                            Image(systemName: "envelope.open.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        
                        Text("تأكيد البريد الإلكتروني")
                            .font(.custom("Tajawal-Black", size: 24))
                            .fontWeight(.black)
                            .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    
                    // Info
                    VStack(spacing: 6) {
                        Text("تم إرسال رمز التحقق إلى بريدك الإلكتروني")
                            .font(.custom("Tajawal-Regular", size: 14))
                            .foregroundColor(AuthColors.textSecondary)
                        
                        Text(maskedEmail)
                            .font(.custom("Tajawal-Bold", size: 14))
                            .foregroundColor(AuthColors.primaryPurple)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                    .multilineTextAlignment(.center)
                    
                    // OTP Inputs
                    HStack(spacing: 10) {
                        OTPTextField(text: $otp1)
                        OTPTextField(text: $otp2)
                        OTPTextField(text: $otp3)
                        OTPTextField(text: $otp4)
                        OTPTextField(text: $otp5)
                        OTPTextField(text: $otp6)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    .padding(.vertical, 10)

                    if let errorMessage = errorMessage {
                        HStack(spacing: 6) {
                            Text("⚠")
                            Text(errorMessage)
                                .font(.custom("Tajawal-Medium", size: 14))
                        }
                        .foregroundColor(Color(red: 248/255, green: 113/255, blue: 113/255))
                        .transition(.opacity)
                    }

                    ZStack {
                        PrimaryButton(title: isLoading ? "" : "تأكيد الرمز", action: {
                            guard !isLoading else { return }
                            let code = otp1 + otp2 + otp3 + otp4 + otp5 + otp6
                            guard code.count == 6 else {
                                withAnimation { errorMessage = "أدخلي الرمز كامل (6 أرقام)" }
                                return
                            }

                            withAnimation {
                                isLoading = true
                                errorMessage = nil
                            }

                            GlowFitAPI.verifyOTP(email: email, token: code) { result in
                                withAnimation {
                                    isLoading = false
                                    switch result {
                                    case .success:
                                        isLoggedIn = true
                                    case .failure(let message):
                                        errorMessage = message
                                    }
                                }
                            }
                        })
                        .disabled(isLoading)

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    
                    // Resend Timer
                    Text("إعادة الإرسال بعد 00:45")
                        .font(.custom("Tajawal-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.top, 5)
                    
                    // Footer
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("← تعديل البريد الإلكتروني")
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                    }
                    .padding(.top, 15)
                }
                .authCardStyle()
                
                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarHidden(true)
    }

    private var maskedEmail: String {
        let parts = email.split(separator: "@")
        guard parts.count == 2, let first = parts.first, first.count > 2 else { return email }
        let visible = first.prefix(2)
        return "\(visible)***@\(parts[1])"
    }
}

struct OTPTextField: View {
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.custom("Tajawal-Bold", size: 24))
            .foregroundColor(.white)
            .frame(width: 55, height: 60)
            .background(text.isEmpty ? AuthColors.inputBackground : AuthColors.primaryPurple.opacity(0.08))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(text.isEmpty ? AuthColors.inputBorder : AuthColors.primaryPurple.opacity(0.4), lineWidth: 1)
            )
    }
}
