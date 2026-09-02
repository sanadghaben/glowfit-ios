//
//  PostLoginGateView.swift
//  GlowFit
//
//  بعد تسجيل الدخول مباشرة، هاي الشاشة بتتأكد هل المستخدمة سوّت فحص بشرة
//  من قبل أو لأ — لو لأ (وما تخطّته سابقاً)، بتعرض شاشة اقتراح الفحص الأول.
//  غير هيك، بتوديها على طول للصفحة الرئيسية.
//

import SwiftUI

struct PostLoginGateView: View {
    @AppStorage("hasSkippedFirstScanPrompt") private var hasSkipped = false

    @State private var isChecking = true
    @State private var needsFirstScanPrompt = false
    @State private var initialTab: Tab = .home

    var body: some View {
        Group {
            if isChecking {
                ZStack {
                    AuthColors.background.ignoresSafeArea()
                    ProgressView().tint(.white)
                }
            } else if needsFirstScanPrompt {
                FirstScanPromptView(onContinue: { tab in
                    initialTab = tab
                    needsFirstScanPrompt = false
                })
            } else {
                HomeView(initialTab: initialTab)
            }
        }
        .onAppear(perform: checkFirstScanStatus)
    }

    private func checkFirstScanStatus() {
        // لو سبق وتخطّت الاقتراح، ما نزعجها فيه من جديد
        if hasSkipped {
            isChecking = false
            needsFirstScanPrompt = false
            return
        }

        GlowFitAPI.fetchMyProfile { result in
            isChecking = false
            switch result {
            case .success(let profile):
                let hasSkinType = (profile.skin_type != nil && !(profile.skin_type?.isEmpty ?? true))
                needsFirstScanPrompt = !hasSkinType
            case .failure:
                // لو تعذّر التحقق لأي سبب، ما نمنع المستخدمة من دخول التطبيق
                needsFirstScanPrompt = false
            }
        }
    }
}
