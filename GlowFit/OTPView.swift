import SwiftUI
import Combine

struct OTPView: View {
    @Environment(\.presentationMode) var presentationMode
    let email: String
    let password: String

    @State private var otp1 = ""
    @State private var otp2 = ""
    @State private var otp3 = ""
    @State private var otp4 = ""
    @State private var otp5 = ""
    @State private var otp6 = ""
    @State private var otp7 = ""
    @State private var otp8 = ""
    @FocusState private var focusedField: Int?

    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var isResending = false
    @State private var resendMessage: String? = nil

    @State private var secondsRemaining = 45
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                        
                        Text(L("otp_title"))
                            .font(.custom("Tajawal-Black", size: 24))
                            .fontWeight(.black)
                            .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    
                    // Info
                    VStack(spacing: 6) {
                        Text(L("otp_subtitle"))
                            .font(.custom("Tajawal-Regular", size: 14))
                            .foregroundColor(AuthColors.textSecondary)
                        
                        Text(maskedEmail)
                            .font(.custom("Tajawal-Bold", size: 14))
                            .foregroundColor(AuthColors.primaryPurple)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                    .multilineTextAlignment(.center)
                    
                    // OTP Inputs
                    HStack(spacing: 8) {
                        otpBox($otp8, index: 8); otpBox($otp7, index: 7); otpBox($otp6, index: 6); otpBox($otp5, index: 5)
                        otpBox($otp4, index: 4); otpBox($otp3, index: 3); otpBox($otp2, index: 2); otpBox($otp1, index: 1)
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
                        PrimaryButton(title: isLoading ? "" : L("otp_confirm_button"), action: {
                            guard !isLoading else { return }
                            let code = otp1 + otp2 + otp3 + otp4 + otp5 + otp6 + otp7 + otp8
                            guard code.count == 8 else {
                                withAnimation { errorMessage = L("otp_enter_full_code") }
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
                                        BiometricAuth.saveCredentials(email: email, password: password)
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
                    
                    // Resend Timer / Button
                    if let resendMessage = resendMessage {
                        Text(resendMessage)
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(Color(red: 74/255, green: 222/255, blue: 128/255))
                            .padding(.top, 5)
                            .transition(.opacity)
                    } else if secondsRemaining > 0 {
                        Text(String(format: L("otp_resend_in"), timeString))
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.top, 5)
                    } else {
                        Button(action: resendCode) {
                            if isResending {
                                ProgressView().tint(AuthColors.primaryPurple)
                            } else {
                                Text(L("otp_resend_now"))
                                    .font(.custom("Tajawal-Bold", size: 13))
                                    .foregroundColor(AuthColors.primaryPurple)
                            }
                        }
                        .disabled(isResending)
                        .padding(.top, 5)
                    }
                    
                    // Footer
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text(L("otp_edit_email"))
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                    }
                    .padding(.top, 15)
                }
                .authCardStyle()
                
                Spacer()
            }
        }
        .autoLayoutDirection()
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            }
        }
    }

    private var timeString: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func resendCode() {
        guard !isResending else { return }
        isResending = true
        errorMessage = nil
        GlowFitAPI.resendOTP(email: email) { result in
            isResending = false
            switch result {
            case .success:
                withAnimation {
                    resendMessage = "تم إرسال رمز جديد ✓"
                    secondsRemaining = 45
                }
                // نخفي رسالة النجاح بعد ثانيتين ونرجّع العدّاد
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { resendMessage = nil }
                }
            case .failure(let message):
                withAnimation { errorMessage = message }
            }
        }
    }

    private var maskedEmail: String {
        let parts = email.split(separator: "@")
        guard parts.count == 2, let first = parts.first, first.count > 2 else { return email }
        let visible = first.prefix(2)
        return "\(visible)***@\(parts[1])"
    }

    @ViewBuilder
    private func otpBox(_ binding: Binding<String>, index: Int) -> some View {
        TextField("", text: binding)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.custom("Tajawal-Bold", size: 22))
            .foregroundColor(.white)
            .frame(width: 40, height: 52)
            .background(binding.wrappedValue.isEmpty ? AuthColors.inputBackground : AuthColors.primaryPurple.opacity(0.08))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(binding.wrappedValue.isEmpty ? AuthColors.inputBorder : AuthColors.primaryPurple.opacity(0.4), lineWidth: 1)
            )
            .focused($focusedField, equals: index)
            .onChange(of: binding.wrappedValue) { newValue in
                // نخلي خانة وحدة بس تقبل رقم وحيد، وننتقل تلقائياً للخانة الجاية
                if newValue.count > 1 {
                    binding.wrappedValue = String(newValue.suffix(1))
                }
                if !newValue.isEmpty && index > 1 {
                    focusedField = index - 1
                } else if newValue.isEmpty && index < 8 {
                    focusedField = index + 1
                }
            }
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
