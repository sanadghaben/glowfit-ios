//
//  IngredientScannerView.swift
//  GlowFit
//
//  ماسح المكونات — شاشات الرحلة كاملة (كاميرا ← مراجعة ← نتيجة) + بوابة الإعلان + الخطأ.
//  المرحلة الأولى: واجهة ببيانات تجريبية. الربط بالخادم والإعلان المكافئ الحقيقي لاحقاً.
//

import SwiftUI
import PhotosUI

private enum ScannerStep { case camera, review, gate, analyzing, result, error }

struct IngredientScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: ScannerStep = .camera
    @State private var showCameraPicker = false
    @State private var galleryItem: PhotosPickerItem?
    @State private var ingredients: [String] = IngredientScanResult.mockRawList
    // تجريبي: المسحة المجانية مرة باليوم — يُنقل للخادم لاحقاً
    @AppStorage("scanner_mock_last_free_day") private var lastFreeDay: String = ""
    @State private var showMockInterstitial = false

    private var todayKey: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: Date())
    }
    private var freeScanAvailable: Bool { lastFreeDay != todayKey }

    var body: some View {
        ZStack {
            AuthBackgroundView()
            switch step {
            case .camera:
                ScannerCameraStep(freeAvailable: freeScanAvailable,
                                  onClose: { dismiss() },
                                  onShutter: capture,
                                  galleryItem: $galleryItem)
            case .review:
                ScannerReviewStep(ingredients: $ingredients,
                                  onBack: { step = .camera },
                                  onAnalyze: startAnalysis)
            case .gate:
                ScannerGateStep(onWatch: watchAd,
                                onLater: { step = .review },
                                onClose: { step = .review })
            case .analyzing:
                ScannerAnalyzingStep()
            case .result:
                ScannerResultStep(result: .mock, onNew: { step = .camera }, onClose: { dismiss() })
            case .error:
                ScannerErrorStep(onRetry: { step = .camera }, onClose: { dismiss() })
            }
        }
        .autoLayoutDirection()
        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraCapture(useFrontCamera: false) { _ in step = .review }.ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showMockInterstitial) {
            ScannerInterstitialMock { showMockInterstitial = false; runAnalysis() }
        }
        .onChange(of: galleryItem) { item in
            if item != nil { galleryItem = nil; step = .review }
        }
    }

    private func capture() {
        if CameraAvailability.isAvailable { showCameraPicker = true } else { step = .review } // المحاكي
    }

    private func startAnalysis() {
        if freeScanAvailable { runAnalysis() } else { step = .gate }
    }

    private func watchAd() {
        // TODO(API/AdMob): إعلان مكافأة حقيقي. لو غير متوفر → إعلان بيني. هنا عرض تجريبي للبديل.
        showMockInterstitial = true
    }

    private func runAnalysis() {
        step = .analyzing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            if freeScanAvailable { lastFreeDay = todayKey }
            step = .result
        }
    }
}

// MARK: - Shared bits

private struct RoundIconButton: View {
    let system: String
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(AuthColors.inputBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AuthColors.inputBorder, lineWidth: 1))
        }
        .accessibilityLabel(label)
    }
}

private struct GradientButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon) }
                Text(title).font(.custom("Tajawal-Bold", size: 17))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                       startPoint: .leading, endPoint: .trailing))
            .cornerRadius(14)
        }
    }
}

private struct CardBox<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .background(AuthColors.cardBackground)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(AuthColors.cardBorder, lineWidth: 1))
    }
}

// MARK: - 2 · Camera

private struct ScannerCameraStep: View {
    let freeAvailable: Bool
    let onClose: () -> Void
    let onShutter: () -> Void
    @Binding var galleryItem: PhotosPickerItem?

    private let green = IngredientLevel.good.color

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RoundIconButton(system: "xmark", label: L("ingscan_close"), action: onClose)
                Spacer()
                Text(L("ingscan_title")).font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16).padding(.top, 8)

            Text(L("ingscan_camera_hint"))
                .font(.custom("Tajawal-Medium", size: 16))
                .multilineTextAlignment(.center).lineSpacing(4)
                .foregroundColor(.white)
                .padding(.horizontal, 32).padding(.top, 28)

            ZStack {
                ScannerFrameCorners()
                VStack(alignment: .leading, spacing: 11) {
                    ForEach([0.38, 1, 0.92, 0.97, 0.84, 0.95, 0.6], id: \.self) { w in
                        RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(w == 0.38 ? 0.4 : 0.18))
                            .frame(height: w == 0.38 ? 9 : 7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .scaleEffect(x: w, y: 1, anchor: .leading)
                    }
                }
                .padding(28).frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(width: 326, height: 236).padding(.top, 28)

            HStack(spacing: 8) {
                ForEach(["ingscan_tip_light", "ingscan_tip_flat", "ingscan_tip_close"], id: \.self) { k in
                    Text(L(k)).font(.custom("Tajawal-Medium", size: 13)).foregroundColor(Color.white.opacity(0.8))
                        .padding(.vertical, 7).padding(.horizontal, 12)
                        .background(Color.white.opacity(0.06)).cornerRadius(10)
                }
            }.padding(.top, 24)

            Spacer()

            VStack(spacing: 22) {
                if freeAvailable {
                    HStack(spacing: 8) {
                        Circle().fill(green).frame(width: 8, height: 8)
                        Text(L("ingscan_free_ready")).font(.custom("Tajawal-Bold", size: 14)).foregroundColor(green)
                    }
                    .padding(.vertical, 8).padding(.horizontal, 16)
                    .background(green.opacity(0.12)).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(green.opacity(0.25), lineWidth: 1))
                } else {
                    Text(L("ingscan_free_used"))
                        .font(.custom("Tajawal-Medium", size: 13)).foregroundColor(AuthColors.textSecondary)
                }
                HStack {
                    PhotosPicker(selection: $galleryItem, matching: .images) {
                        Image(systemName: "photo").font(.system(size: 20)).foregroundColor(.white)
                            .frame(width: 52, height: 52).background(AuthColors.inputBackground).cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AuthColors.inputBorder, lineWidth: 1))
                    }
                    .accessibilityLabel(L("ingscan_gallery"))
                    Spacer()
                    Button(action: onShutter) {
                        ZStack {
                            Circle().stroke(Color.white, lineWidth: 4).frame(width: 76, height: 76)
                            Circle().fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                         startPoint: .topTrailing, endPoint: .bottomLeading))
                                .frame(width: 56, height: 56)
                        }
                    }
                    .accessibilityLabel(L("ingscan_capture"))
                    Spacer()
                    Color.clear.frame(width: 52, height: 52)
                }
            }
            .padding(.horizontal, 32).padding(.bottom, 32)
        }
    }
}

private struct ScannerFrameCorners: View {
    var body: some View {
        ZStack {
            corner(.topLeading, AuthColors.primaryPink)
            corner(.topTrailing, AuthColors.primaryPink)
            corner(.bottomLeading, AuthColors.primaryPurple)
            corner(.bottomTrailing, AuthColors.primaryPurple)
        }
    }
    private func corner(_ a: Alignment, _ c: Color) -> some View {
        let isTop = (a == .topLeading || a == .topTrailing)
        let isLeading = (a == .topLeading || a == .bottomLeading)
        return Path { p in
            let s: CGFloat = 36
            p.move(to: CGPoint(x: isLeading ? 0 : s, y: isTop ? s : 0))
            p.addLine(to: CGPoint(x: isLeading ? 0 : s, y: isTop ? 0 : s))
            p.addLine(to: CGPoint(x: isLeading ? s : 0, y: isTop ? 0 : s))
        }
        .stroke(c, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
        .frame(width: 36, height: 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: a)
    }
}

// MARK: - 3 · Review

private struct ScannerReviewStep: View {
    @Binding var ingredients: [String]
    let onBack: () -> Void
    let onAnalyze: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RoundIconButton(system: AppLanguage.isArabic ? "chevron.right" : "chevron.left",
                                label: L("ingscan_back"), action: onBack)
                Spacer()
                Text(L("ingscan_review_title")).font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16).padding(.top, 8)

            Text(L("ingscan_review_sub"))
                .font(.custom("Tajawal-Regular", size: 14)).foregroundColor(AuthColors.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32).padding(.top, 14)

            ScrollView {
                CardBox {
                    VStack(spacing: 0) {
                        ForEach(Array(ingredients.enumerated()), id: \.offset) { idx, name in
                            HStack {
                                Text(name).font(.custom("Tajawal-Medium", size: 15)).foregroundColor(.white)
                                    .environment(\.layoutDirection, .leftToRight)
                                Spacer()
                                Button { ingredients.remove(at: idx) } label: {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(Color.white.opacity(0.35))
                                }
                                .accessibilityLabel(L("ingscan_remove"))
                            }
                            .padding(.vertical, 13).padding(.horizontal, 16)
                            if idx < ingredients.count - 1 {
                                Divider().background(AuthColors.cardBorder)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 18)
            }

            VStack(spacing: 8) {
                GradientButton(title: L("ingscan_analyze"), icon: "sparkles", action: onAnalyze)
                    .disabled(ingredients.isEmpty).opacity(ingredients.isEmpty ? 0.5 : 1)
                // بانر (مكان الإعلان): مرتبط بنفس مكوّن التطبيق وبيختفي للمشتركات
                PremiumAwareBannerAd(adUnitID: PremiumAwareBannerAd.productionBannerAdUnitID)
            }
            .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 12)
        }
    }
}

// MARK: - 6 · Ad gate

private struct ScannerGateStep: View {
    let onWatch: () -> Void
    let onLater: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack { RoundIconButton(system: "xmark", label: L("ingscan_close"), action: onClose); Spacer() }
                .padding(.horizontal, 16).padding(.top, 8)

            VStack(spacing: 14) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.25), AuthColors.primaryPink.opacity(0.2)],
                                                 startPoint: .topTrailing, endPoint: .bottomLeading))
                        .frame(width: 96, height: 96)
                        .overlay(Circle().stroke(AuthColors.primaryPurple.opacity(0.3), lineWidth: 1))
                    Image(systemName: "play.fill").font(.system(size: 36))
                        .foregroundColor(Color(red: 249/255, green: 168/255, blue: 212/255))
                }
                Text(L("ingscan_gate_title")).font(.custom("Tajawal-Bold", size: 24)).foregroundColor(.white)
                Text(L("ingscan_gate_body")).font(.custom("Tajawal-Regular", size: 14)).lineSpacing(5)
                    .foregroundColor(Color.white.opacity(0.7)).multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32).padding(.top, 48)

            CardBox {
                VStack(spacing: 0) {
                    gateRow("ingscan_gate_point1")
                    Divider().background(AuthColors.cardBorder)
                    gateRow("ingscan_gate_point2")
                }.padding(.horizontal, 16)
            }
            .padding(.horizontal, 20).padding(.top, 28)

            Spacer()

            VStack(spacing: 10) {
                GradientButton(title: L("ingscan_gate_watch"), icon: "play.fill", action: onWatch)
                Button(action: {}) {
                    Text(L("ingscan_gate_premium")).font(.custom("Tajawal-Bold", size: 16))
                        .foregroundColor(Color(red: 191/255, green: 133/255, blue: 252/255))
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(AuthColors.primaryPurple.opacity(0.12)).cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AuthColors.primaryPurple.opacity(0.3), lineWidth: 1))
                }
                Button(action: onLater) {
                    Text(L("ingscan_later")).font(.custom("Tajawal-Medium", size: 15))
                        .foregroundColor(Color.white.opacity(0.65)).padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 24)
        }
    }

    private func gateRow(_ key: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle").foregroundColor(IngredientLevel.good.color)
            Text(L(key)).font(.custom("Tajawal-Regular", size: 14)).foregroundColor(Color.white.opacity(0.85))
            Spacer()
        }.padding(.vertical, 14)
    }
}

// MARK: - Analyzing

private struct ScannerAnalyzingStep: View {
    var body: some View {
        VStack(spacing: 18) {
            ProgressView().progressViewStyle(.circular).tint(AuthColors.primaryPink).scaleEffect(1.6)
            Text(L("ingscan_analyzing")).font(.custom("Tajawal-Medium", size: 16)).foregroundColor(.white)
        }
    }
}

// MARK: - 4 · Result

private struct ScannerResultStep: View {
    let result: IngredientScanResult
    let onNew: () -> Void
    let onClose: () -> Void
    @State private var open: Set<String> = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RoundIconButton(system: "xmark", label: L("ingscan_close"), action: onClose)
                Spacer()
                Text(L("ingscan_result_title")).font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16).padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ring.padding(.top, 14)
                    Text(L(result.verdict.titleKey)).font(.custom("Tajawal-Bold", size: 22)).foregroundColor(result.verdict.color)
                    Text(L("ingscan_result_sub")).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(AuthColors.textSecondary)

                    section("bad", "ingscan_sec_bad", count: result.ingredients.filter { $0.level == .bad || $0.level == .caution }.count) {
                        ForEach(result.ingredients.filter { $0.level == .bad || $0.level == .caution }) { row($0) }
                    }
                    section("conf", "ingscan_sec_conflicts", count: result.conflicts.count) {
                        ForEach(result.conflicts) { c in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(c.first) + \(c.second)").font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                                    .environment(\.layoutDirection, .leftToRight)
                                Text(L(c.noteKey)).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(Color.white.opacity(0.7))
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 10)
                        }
                    }
                    section("good", "ingscan_sec_good", count: result.ingredients.filter { $0.level == .good }.count) {
                        ForEach(result.ingredients.filter { $0.level == .good }) { row($0) }
                    }
                    section("all", "ingscan_sec_all", count: result.ingredients.count) {
                        ForEach(result.ingredients) { row($0) }
                    }

                    GradientButton(title: L("ingscan_new"), icon: "camera.viewfinder", action: onNew).padding(.top, 6)
                }
                .padding(.horizontal, 20).padding(.bottom, 16)
            }
            PremiumAwareBannerAd(adUnitID: PremiumAwareBannerAd.productionBannerAdUnitID).padding(.bottom, 8)
        }
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.08), lineWidth: 12)
            Circle().trim(from: 0, to: CGFloat(result.percent) / 100)
                .stroke(result.verdict.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(result.percent)%").font(.custom("Tajawal-Bold", size: 40)).foregroundColor(.white)
        }
        .frame(width: 150, height: 150)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(result.percent)%")
    }

    private func row(_ i: ScannedIngredient) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(i.level.color).frame(width: 8, height: 8).padding(.top, 7)
            VStack(alignment: .leading, spacing: 3) {
                Text(i.name).font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                    .environment(\.layoutDirection, .leftToRight)
                Text(L(i.explanationKey)).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(Color.white.opacity(0.7))
            }
            Spacer(minLength: 0)
        }.padding(.vertical, 10)
    }

    @ViewBuilder
    private func section<C: View>(_ id: String, _ titleKey: String, count: Int, @ViewBuilder content: () -> C) -> some View {
        if count > 0 {
            CardBox {
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if open.contains(id) { open.remove(id) } else { open.insert(id) }
                        }
                    } label: {
                        HStack {
                            Text(L(titleKey)).font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                            Text("\(count)").font(.custom("Tajawal-Medium", size: 12)).foregroundColor(AuthColors.textSecondary)
                            Spacer()
                            Image(systemName: open.contains(id) ? "chevron.up" : "chevron.down")
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(AuthColors.textSecondary)
                        }.padding(16)
                    }
                    if open.contains(id) {
                        VStack(spacing: 0) { content() }.padding(.horizontal, 16).padding(.bottom, 6)
                    }
                }
            }
        }
    }
}

// MARK: - 5 · Error

private struct ScannerErrorStep: View {
    let onRetry: () -> Void
    let onClose: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack { RoundIconButton(system: "xmark", label: L("ingscan_close"), action: onClose); Spacer() }
                .padding(.horizontal, 16).padding(.top, 8)
            VStack(spacing: 14) {
                Image(systemName: "text.viewfinder").font(.system(size: 44)).foregroundColor(AuthColors.primaryPink)
                    .frame(width: 96, height: 96).background(AuthColors.primaryPink.opacity(0.12)).clipShape(Circle())
                Text(L("ingscan_error_title")).font(.custom("Tajawal-Bold", size: 22)).foregroundColor(.white)
                Text(L("ingscan_error_body")).font(.custom("Tajawal-Regular", size: 14)).lineSpacing(5)
                    .foregroundColor(Color.white.opacity(0.7)).multilineTextAlignment(.center)
            }.padding(.horizontal, 32).padding(.top, 60)
            Spacer()
            GradientButton(title: L("ingscan_retry"), icon: "camera", action: onRetry)
                .padding(.horizontal, 20).padding(.bottom, 24)
        }
    }
}

// MARK: - 7 · Interstitial fallback (mock)

private struct ScannerInterstitialMock: View {
    let onClose: () -> Void
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    Text(L("ingscan_ad_badge")).font(.custom("Tajawal-Medium", size: 12)).foregroundColor(.white)
                        .padding(.vertical, 3).padding(.horizontal, 10).background(Color.white.opacity(0.2)).cornerRadius(6)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark").foregroundColor(.white).frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.18)).clipShape(Circle())
                    }.accessibilityLabel(L("ingscan_close"))
                }.padding(.horizontal, 16).padding(.top, 8)
                Spacer()
                Text(L("ingscan_ad_placeholder")).font(.custom("Tajawal-Bold", size: 16)).foregroundColor(Color.white.opacity(0.7))
                Spacer()
                Text(L("ingscan_ad_after")).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(Color.white.opacity(0.7))
                    .padding(.bottom, 30)
            }
        }
    }
}
