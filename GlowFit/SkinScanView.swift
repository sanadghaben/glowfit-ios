import SwiftUI
import PhotosUI

struct SkinScanView: View {
    @State private var isScanning = false
    @State private var scanLineOffset: CGFloat = -150
    @State private var showAnalyzing = false

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var errorMessage: String? = nil
    @State private var scanResult: GlowFitAPI.SkinScanResult? = nil
    @State private var showResultSheet = false
    @State private var showCamera = false
    
    var body: some View {
        ZStack {
            // Camera Background
            Color.black.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("فحص البشرة")
                        .font(.custom("Tajawal-Bold", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { }) {
                        Image(systemName: "questionmark")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Scanner Area
                ZStack {
                    // Instruction Badge
                    Text(isScanning ? "جاري الفحص... يرجى الثبات 📸" : "ضعي وجهك داخل الإطار 👤")
                        .font(.custom("Tajawal-Medium", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isScanning ? AuthColors.primaryPink.opacity(0.2) : Color.black.opacity(0.6))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isScanning ? AuthColors.primaryPink.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .offset(y: -180)
                    
                    // Face Guide
                    Ellipse()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 10]))
                        .foregroundColor(isScanning ? .green : Color.white.opacity(0.5))
                        .frame(width: 220, height: 300)
                        .shadow(color: isScanning ? Color.green.opacity(0.3) : .clear, radius: 10)
                    
                    if isScanning {
                        // Scan Line
                        Rectangle()
                            .fill(
                                LinearGradient(colors: [.clear, AuthColors.primaryPink, AuthColors.primaryPurple, .clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(height: 4)
                            .shadow(color: AuthColors.primaryPink.opacity(0.5), radius: 10, y: 0)
                            .offset(y: scanLineOffset)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                    scanLineOffset = 150
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 400)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(AuthColors.primaryPurple.opacity(0.3), lineWidth: 2)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Bottom Controls
                VStack(spacing: 20) {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.custom("Tajawal-Medium", size: 13))
                            .foregroundColor(Color(red: 248/255, green: 113/255, blue: 113/255))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    } else {
                        Text("تأكدي من الإضاءة الجيدة وعدم وجود مكياج للحصول على أدق النتائج ✨")
                            .font(.custom("Tajawal-Regular", size: 12))
                            .foregroundColor(Color.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    HStack(spacing: 40) {
                        Button(action: {}) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .overlay(
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Color.clear
                            }
                            .frame(width: 50, height: 50)
                        )
                        
                        // Capture Button
                        Button(action: {
                            if CameraAvailability.isAvailable {
                                showCamera = true
                            } else {
                                errorMessage = "الكاميرا مش متوفرة على هذا الجهاز (المحاكي مثلاً)، استخدمي زر المعرض."
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .fill(
                                        isScanning ? LinearGradient(colors: [.red, .red], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: isScanning ? 40 : 66, height: isScanning ? 40 : 66)
                                    .cornerRadius(isScanning ? 10 : 33)
                            }
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.bottom, 120) // Give space for Custom Tab Bar
            }
            
            // Analyzing Overlay
            if showAnalyzing {
                ZStack {
                    Color(red: 10/255, green: 10/255, blue: 15/255).opacity(0.95)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .stroke(AuthColors.primaryPurple.opacity(0.3), lineWidth: 4)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: 0.8)
                                .stroke(AuthColors.primaryPink, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 100, height: 100)
                                .rotationEffect(Angle(degrees: isScanning ? 360 : 0))
                                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: isScanning)
                            
                            Text("✨")
                                .font(.system(size: 40))
                        }
                        
                        Text("جاري تحليل بشرتك...")
                            .font(.custom("Tajawal-Bold", size: 20))
                            .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                        
                        Text("الذكاء الاصطناعي يقوم بفحص مسامك والتجاعيد")
                            .font(.custom("Tajawal-Regular", size: 14))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem = newItem else { return }
            Task { await handleSelectedPhoto(newItem) }
        }
        .sheet(isPresented: $showResultSheet) {
            if let scanResult = scanResult {
                SkinScanResultView(result: scanResult, onDismiss: { showResultSheet = false })
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCapture(onImageCaptured: { image in
                Task { await handleCapturedImage(image) }
            })
            .ignoresSafeArea()
        }
    }

    private func handleCapturedImage(_ uiImage: UIImage) async {
        errorMessage = nil
        let resizedBase64 = resizeAndEncode(uiImage, maxDimension: 800, quality: 0.7)

        await MainActor.run {
            withAnimation {
                isScanning = true
                showAnalyzing = true
            }
        }

        GlowFitAPI.analyzeSkin(imageBase64: resizedBase64) { result in
            withAnimation {
                isScanning = false
                showAnalyzing = false
            }
            switch result {
            case .success(let scan):
                scanResult = scan
                showResultSheet = true
            case .failure(let message):
                errorMessage = message
            }
        }
    }

    private func handleSelectedPhoto(_ item: PhotosPickerItem) async {
        errorMessage = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                await MainActor.run { errorMessage = "تعذّر قراءة الصورة، جرّبي صورة تانية" }
                return
            }

            let resizedBase64 = resizeAndEncode(uiImage, maxDimension: 800, quality: 0.7)

            await MainActor.run {
                withAnimation {
                    isScanning = true
                    showAnalyzing = true
                }
            }

            GlowFitAPI.analyzeSkin(imageBase64: resizedBase64) { result in
                withAnimation {
                    isScanning = false
                    showAnalyzing = false
                }
                switch result {
                case .success(let scan):
                    scanResult = scan
                    showResultSheet = true
                case .failure(let message):
                    errorMessage = message
                }
                selectedPhotoItem = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "صار خطأ أثناء تحميل الصورة"
            }
        }
    }

    private func resizeAndEncode(_ image: UIImage, maxDimension: CGFloat, quality: CGFloat) -> String {
        let size = image.size
        var newSize = size
        if size.width > size.height, size.width > maxDimension {
            newSize = CGSize(width: maxDimension, height: size.height * (maxDimension / size.width))
        } else if size.height > maxDimension {
            newSize = CGSize(width: size.width * (maxDimension / size.height), height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        let jpegData = resizedImage.jpegData(compressionQuality: quality) ?? Data()
        return jpegData.base64EncodedString()
    }

    private func toggleScan() {
        withAnimation {
            isScanning.toggle()
        }
        if isScanning {
            scanLineOffset = -150
        }
    }
}

// MARK: - نتيجة الفحص
struct SkinScanResultView: View {
    let result: GlowFitAPI.SkinScanResult
    let onDismiss: () -> Void

    private let skinLabels: [String: String] = [
        "دهنية": "دهنية", "جافة": "جافة", "مختلطة": "مختلطة", "عادية": "عادية", "حساسة": "حساسة"
    ]

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text("✨")
                        .font(.system(size: 50))
                        .padding(.top, 20)

                    Text("نتيجة فحص بشرتك")
                        .font(.custom("Tajawal-Bold", size: 22))
                        .foregroundColor(.white)

                    if let score = result.skin_health_score {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 10)
                                .frame(width: 120, height: 120)
                            Circle()
                                .trim(from: 0, to: CGFloat(score) / 100)
                                .stroke(
                                    LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                            VStack(spacing: 2) {
                                Text("\(score)")
                                    .font(.custom("Tajawal-Bold", size: 32))
                                    .foregroundColor(.white)
                                Text("من 100")
                                    .font(.custom("Tajawal-Regular", size: 11))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        Text("درجة صحة البشرة")
                            .font(.custom("Tajawal-Medium", size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    if let type = result.type_skin {
                        Text(type)
                            .font(.custom("Tajawal-Bold", size: 18))
                            .foregroundColor(AuthColors.primaryPink)
                            .padding(.horizontal, 20).padding(.vertical, 8)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(20)
                    }

                    if let age = result.estimated_age {
                        Text("العمر التقريبي للبشرة: \(age) سنة")
                            .font(.custom("Tajawal-Medium", size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    if let summary = result.summary_text {
                        Text(summary)
                            .font(.custom("Tajawal-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    VStack(spacing: 14) {
                        metricRow("💧 مستوى الترطيب", result.moisture_level != nil ? "\(result.moisture_level!)%" : nil)
                        metricRow("🕳 حالة المسام", result.pores_condition)
                        metricRow("👁 الهالات السوداء", result.dark_circles_percentage != nil ? "\(result.dark_circles_percentage!)%" : nil)
                        metricRow("🟤 التصبغات", result.pigmentation)
                        metricRow("✨ حساسية البشرة", result.sensitivity)
                        metricRow("🔴 نسبة الحبوب", result.acne_percentage != nil ? "\(result.acne_percentage!)%" : nil)
                        metricRow("〰️ الخطوط الدقيقة", result.fine_lines_percentage != nil ? "\(result.fine_lines_percentage!)%" : nil)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)

                    if let problems = result.problems_and_solutions, !problems.isEmpty {
                        VStack(alignment: .trailing, spacing: 16) {
                            Text("⚠️ المشاكل والحلول").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                            ForEach(Array(problems.enumerated()), id: \.offset) { _, item in
                                VStack(alignment: .trailing, spacing: 6) {
                                    if let problem = item.problem {
                                        Text(problem)
                                            .font(.custom("Tajawal-Bold", size: 13))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    if let solution = item.solution {
                                        Text(solution)
                                            .font(.custom("Tajawal-Regular", size: 12))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    if let source = item.source {
                                        Text("المصدر: " + source)
                                            .font(.custom("Tajawal-Regular", size: 11))
                                            .foregroundColor(.white.opacity(0.35))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.bottom, 6)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(20).background(Color.white.opacity(0.04)).cornerRadius(20)
                        .padding(.horizontal, 20)
                    }

                    if let concerns = result.concerns, !concerns.isEmpty {
                        VStack(alignment: .trailing, spacing: 10) {
                            Text("⚠️ مشاكل مكتشفة").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                            ForEach(concerns, id: \.self) { c in
                                Text("• " + c).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(20).background(Color.white.opacity(0.04)).cornerRadius(20)
                        .padding(.horizontal, 20)
                    }

                    if let tips = result.recommendations, !tips.isEmpty {
                        VStack(alignment: .trailing, spacing: 10) {
                            Text("توصيات العناية").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                            ForEach(tips, id: \.self) { t in
                                Text("💡 " + t).font(.custom("Tajawal-Regular", size: 13)).foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(20).background(Color.white.opacity(0.04)).cornerRadius(20)
                        .padding(.horizontal, 20)
                    }

                    if let products = result.recommended_products, !products.isEmpty {
                        VStack(alignment: .trailing, spacing: 14) {
                            Text("🛍 منتجات مقترحة لك").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                            ForEach(products) { product in
                                HStack(spacing: 12) {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(product.name ?? "").font(.custom("Tajawal-Bold", size: 13)).foregroundColor(.white)
                                        if let ingredient = product.key_ingredient {
                                            Text(ingredient).font(.custom("Tajawal-Regular", size: 11)).foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                    Spacer()
                                    if let price = product.price {
                                        Text("\(Int(price)) ر.س")
                                            .font(.custom("Tajawal-Bold", size: 13))
                                            .foregroundColor(AuthColors.primaryPink)
                                    }
                                }
                                .padding(14)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(14)
                            }
                        }
                        .padding(20).background(Color.white.opacity(0.04)).cornerRadius(20)
                        .padding(.horizontal, 20)
                    }

                    Button(action: onDismiss) {
                        Text("تم")
                            .font(.custom("Tajawal-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    private func metricRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label).font(.custom("Tajawal-Medium", size: 13)).foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value ?? "—")
                .font(.custom("Tajawal-Bold", size: 14))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SkinScanView()
}
