import SwiftUI

struct OTPView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var otp1 = "4"
    @State private var otp2 = "8"
    @State private var otp3 = ""
    @State private var otp4 = ""
    
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
                        
                        Text("us***@email.com")
                            .font(.custom("Tajawal-Bold", size: 14))
                            .foregroundColor(AuthColors.primaryPurple)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                    .multilineTextAlignment(.center)
                    
                    // OTP Inputs
                    HStack(spacing: 12) {
                        OTPTextField(text: $otp1)
                        OTPTextField(text: $otp2)
                        OTPTextField(text: $otp3)
                        OTPTextField(text: $otp4)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    .padding(.vertical, 10)
                    
                    PrimaryButton(title: "تأكيد الرمز", action: {
                        withAnimation {
                            isLoggedIn = true
                        }
                    })
                    
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
