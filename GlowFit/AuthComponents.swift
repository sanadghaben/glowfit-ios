import SwiftUI
import UIKit
// MARK: - App Colors
struct AuthColors {
    static let background = Color(red: 10/255, green: 10/255, blue: 15/255)
    static let primaryPurple = Color(red: 147/255, green: 51/255, blue: 234/255)
    static let primaryPink = Color(red: 236/255, green: 72/255, blue: 153/255)
    static let cardBackground = Color.white.opacity(0.03)
    static let cardBorder = Color.white.opacity(0.06)
    static let inputBackground = Color.white.opacity(0.04)
    static let inputBorder = Color.white.opacity(0.08)
    static let textSecondary = Color.white.opacity(0.5)
}

// MARK: - Auth Background
struct AuthBackgroundView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            
            // Orb 1 (Top Right)
            Circle()
                .fill(AuthColors.primaryPurple.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: isAnimating ? 90 : 50, y: isAnimating ? -100 : -130)
            
            // Orb 2 (Bottom Left)
            Circle()
                .fill(AuthColors.primaryPink.opacity(0.08))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: isAnimating ? -120 : -80, y: isAnimating ? 150 : 200)
            
            // Orb 3 (Center)
            Circle()
                .fill(Color.blue.opacity(0.06))
                .frame(width: 200, height: 200)
                .blur(radius: 80)
                .offset(x: isAnimating ? 30 : -30, y: isAnimating ? 40 : -40)
            
            // Particle System (using existing or simple one if not available globally)
            // Assuming ParticleSystem from SplashView is accessible here
            ParticleSystem()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Particle System (Fallback if not globally available from SplashView)
// Note: Assuming ParticleSystem() is already available in the project. If not, this can be expanded.

// MARK: - Custom TextField
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textAlignment: TextAlignment = .leading
    var errorMessage: String? = nil
    
    @FocusState private var isFocused: Bool
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 18))
                    .opacity(0.3)
                    .padding(.trailing, textAlignment == .trailing ? 0 : 4)
                
                if isSecure && !showPassword {
                    SecureField("", text: $text)
                        .foregroundColor(.white)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder).foregroundColor(.white.opacity(0.2))
                        }
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                        .multilineTextAlignment(textAlignment)
                        .environment(\.layoutDirection, textAlignment == .trailing ? .leftToRight : .rightToLeft)
                } else {
                    TextField("", text: $text)
                        .foregroundColor(.white)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder).foregroundColor(.white.opacity(0.2))
                        }
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                        .multilineTextAlignment(textAlignment)
                        .environment(\.layoutDirection, textAlignment == .trailing ? .leftToRight : .rightToLeft)
                }
            
                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.white.opacity(0.3))
                            .font(.system(size: 16))
                    }
                }
            }
            .padding()
            .background(isFocused ? Color.white.opacity(0.06) : AuthColors.inputBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke((errorMessage != nil && !errorMessage!.isEmpty) ? Color.red.opacity(0.6) : (isFocused ? AuthColors.primaryPurple.opacity(0.5) : AuthColors.inputBorder), lineWidth: 1)
            )
            .shadow(color: (errorMessage != nil && !errorMessage!.isEmpty) ? Color.red.opacity(0.1) : (isFocused ? AuthColors.primaryPurple.opacity(0.1) : .clear), radius: 10)
            .animation(.easeInOut(duration: 0.3), value: isFocused)
            
            if let error = errorMessage, !error.isEmpty {
                HStack(spacing: 6) {
                    Text("⚠")
                        .font(.system(size: 12))
                    Text(error)
                        .font(.custom("Tajawal-Medium", size: 12))
                }
                .foregroundColor(Color(red: 248/255, green: 113/255, blue: 113/255))
                .padding(.horizontal, 4)
                .transition(.opacity)
            }
        }
    }
}

// Helper for Placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Tajawal-Bold", size: 17))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: AuthColors.primaryPurple.opacity(0.3), radius: 12, y: 8)
        }
    }
}

// MARK: - Social Button
struct SocialButton: View {
    let title: String
    let iconName: String // Using systemImage or custom asset
    let isSystemImage: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSystemImage {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                } else {
                    // Assuming we have custom icons in Assets or we just use text/emoji for demo
                    // We'll use a placeholder for Google/Apple if custom images aren't found
                    Text(iconName)
                        .font(.system(size: 18))
                }
                
                Text(title)
                    .font(.custom("Tajawal-Medium", size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AuthColors.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AuthColors.cardBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Auth Card Modifier
struct AuthCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 28)
            .padding(.vertical, 35)
            .background(AuthColors.cardBackground)
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(AuthColors.cardBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
    }
}

extension View {
    func authCardStyle() -> some View {
        modifier(AuthCardModifier())
    }
}
