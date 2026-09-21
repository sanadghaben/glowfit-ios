import SwiftUI

struct ResetPasswordOTPView: View {
    @Environment(\.presentationMode) var presentationMode
    let email: String
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @State private var otp1 = ""; @State private var otp2 = ""; @State private var otp3 = ""
    @State private var otp4 = ""; @State private var otp5 = ""; @State private var otp6 = ""
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showSuccess = false

    @FocusState private var focusedField: Int?

    var body: some View {
        ZStack {
            AuthBackgroundView()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 15/255, green: 12/255, blue: 20/255).opacity(0.9))
                                .frame(width: 65, height: 65)
                                .overlay(Circle().stroke(AuthColors.primaryPurple.opacity(0.25), lineWidth: 1))
                            Image(systemName: "key.horizontal")
                                .font(.system(size: 24))
                                .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        Text(L("reset_password_title"))
                            .font(.custom("Tajawal-Black", size: 22))
                            .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text(String(format: L("reset_password_subtitle"), email))
                            .font(.custom("Tajawal-Regular", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    // OTP boxes
                    HStack(spacing: 8) {
                        otpBox($otp1, index: 1); otpBox($otp2, index: 2)
                        otpBox($otp3, index: 3); otpBox($otp4, index: 4); otpBox($otp5, index: 5); otpBox($otp6, index: 6)
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("reset_password_new"))
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            CustomTextField(icon: "🔒", placeholder: "8 أحرف على الأقل", text: $newPassword, isSecure: true, textAlignment: .trailing)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("reset_password_confirm"))
                                .font(.custom("Tajawal-Medium", size: 13))
                                .foregroundColor(AuthColors.textSecondary)
                            CustomTextField(icon: "🔒", placeholder: "أعيدي كتابتها", text: $confirmPassword, isSecure: true, textAlignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 20)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.custom("Tajawal-Medium", size: 13))
                            .foregroundColor(Color(red: 248/255, green: 113/255, blue: 113/255))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    ZStack {
                        PrimaryButton(title: isLoading ? "" : "تعيين كلمة المرور", action: submit)
                            .disabled(isLoading)
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .padding(.horizontal, 20)

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("← العودة لتسجيل الدخول")
                            .font(.custom("Tajawal-Medium", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .autoLayoutDirection()
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                focusedField = 1
            }
        }
        .alert(L("reset_password_success_title"), isPresented: $showSuccess) {
            Button(L("ok_button")) { isLoggedIn = true }
        } message: {
            Text(L("reset_password_success_message"))
        }
    }

    private var fullCode: String { otp1 + otp2 + otp3 + otp4 + otp5 + otp6 }

    @ViewBuilder
    private func otpBox(_ binding: Binding<String>, index: Int) -> some View {
        TextField("", text: binding)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.custom("Tajawal-Bold", size: 20))
            .foregroundColor(.white)
            .frame(width: 44, height: 52)
            .background(AuthColors.inputBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AuthColors.inputBorder, lineWidth: 1))
            .focused($focusedField, equals: index)
            .onChange(of: binding.wrappedValue) { newValue in
                if newValue.count > 1 {
                    binding.wrappedValue = String(newValue.suffix(1))
                }
                if !newValue.isEmpty && index < 6 {
                    focusedField = index + 1
                } else if newValue.isEmpty && index > 1 {
                    focusedField = index - 1
                }
            }
    }

    private func submit() {
        errorMessage = nil
        guard fullCode.count == 6 else {
            errorMessage = L("otp_enter_full_code"); return
        }
        guard newPassword.count >= 8 else {
            errorMessage = "كلمة المرور الجديدة لازم تكون 8 أحرف على الأقل"; return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "كلمة المرور وتأكيدها مش متطابقين"; return
        }
        isLoading = true
        GlowFitAPI.completePasswordReset(email: email, token: fullCode, newPassword: newPassword) { result in
            isLoading = false
            switch result {
            case .success:
                showSuccess = true
            case .failure(let message):
                errorMessage = message
            }
        }
    }
}
