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

                Text(L("first_scan_title"))
                    .font(.custom("Tajawal-Bold", size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(L("first_scan_subtitle"))
                    .font(.custom("Tajawal-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                VStack(spacing: 14) {
                    benefitRow("📋", L("first_scan_benefit1"))
                    benefitRow("🧴", L("first_scan_benefit2"))
                    benefitRow("🛍", L("first_scan_benefit3"))
                }
                .padding(20)
                .background(Color.white.opacity(0.04))
                .cornerRadius(20)
                .padding(.horizontal, 24)

                Spacer()

                Button(action: { onContinue(.scan) }) {
                    Text(L("first_scan_start"))
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
                    Text(L("first_scan_skip"))
                        .font(.custom("Tajawal-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.bottom, 24)
            }
        }
        .autoLayoutDirection()
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
