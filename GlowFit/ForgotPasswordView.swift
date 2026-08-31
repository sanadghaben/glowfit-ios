import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    
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
                            
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 24))
                                .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        
                        Text("استعادة كلمة المرور")
                            .font(.custom("Tajawal-Black", size: 24))
                            .fontWeight(.black)
                            .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    
                    // Info
                    Text("أدخلي بريدك الإلكتروني\nوسنرسل لك رابط إعادة تعيين كلمة المرور")
                        .font(.custom("Tajawal-Regular", size: 14))
                        .foregroundColor(AuthColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 10)
                    
                    // Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("البريد الإلكتروني")
                            .font(.custom("Tajawal-Medium", size: 13))
                            .foregroundColor(AuthColors.textSecondary)
                        CustomTextField(icon: "📧", placeholder: "example@email.com", text: $email, keyboardType: .emailAddress, textAlignment: .trailing)
                    }
                    
                    PrimaryButton(title: "إرسال رابط الاستعادة", action: {
                        // Action to send link
                    })
                    .padding(.top, 10)
                    
                    // Footer
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("← العودة لتسجيل الدخول")
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
