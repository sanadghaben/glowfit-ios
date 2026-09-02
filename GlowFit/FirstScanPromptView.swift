//
//  FirstScanPromptView.swift
//  GlowFit
//
//  شاشة تُعرض مرة وحدة بعد نجاح التسجيل مباشرة، تشجّع المستخدمة تسوّي
//  فحص البشرة الأول قبل ما تدخل للتطبيق — مقترحة بقوة بس مو إجبارية.
//

import SwiftUI

struct FirstScanPromptView: View {
    var onContinue: (Tab) -> Void

    @AppStorage("hasSkippedFirstScanPrompt") private var hasSkipped = false

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 26) {
                Spacer()

                Text("✨")
                    .font(.system(size: 64))

                Text("خلينا نتعرف على بشرتك")
                    .font(.custom("Tajawal-Bold", size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("فحص سريع بالذكاء الاصطناعي، وبنبني لك بناءً عليه روتين وتقارير مخصصة بالكامل")
                    .font(.custom("Tajawal-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                VStack(spacing: 14) {
                    benefitRow("📋", "تقرير كامل عن حالة بشرتك")
                    benefitRow("🧴", "روتين عناية يومي مخصص لك")
                    benefitRow("🛍", "منتجات مقترحة تناسب بشرتك بالضبط")
                }
                .padding(20)
                .background(Color.white.opacity(0.04))
                .cornerRadius(20)
                .padding(.horizontal, 24)

                Spacer()

                Button(action: { onContinue(.scan) }) {
                    Text("ابدئي فحصك الأول ✨")
                        .font(.custom("Tajawal-Bold", size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                        .shadow(color: AuthColors.primaryPurple.opacity(0.3), radius: 12, y: 6)
                }
                .padding(.horizontal, 24)

                Button(action: {
                    hasSkipped = true
                    onContinue(.home)
                }) {
                    Text("تخطي حالياً")
                        .font(.custom("Tajawal-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.bottom, 24)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    private func benefitRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Text(text)
                .font(.custom("Tajawal-Medium", size: 13))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Text(icon).font(.system(size: 20))
        }
    }
}

#Preview {
    FirstScanPromptView(onContinue: { _ in })
}
