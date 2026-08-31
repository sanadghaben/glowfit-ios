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
                        Button(action: { }) {
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
                        .overlay(
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Color.clear
                            }
                            .frame(width: 80, height: 80)
                        )
                        
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

                    if let type = result.type_skin {
                        Text(type)
                            .font(.custom("Tajawal-Bold", size: 18))
                            .foregroundColor(AuthColors.primaryPink)
                            .padding(.horizontal, 20).padding(.vertical, 8)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(20)
                    }

                    if let summary = result.summary_text {
                        Text(summary)
                            .font(.custom("Tajawal-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    VStack(spacing: 14) {
                        metricRow("💧 مستوى الترطيب", result.moisture_level)
                        metricRow("🔴 نسبة الحبوب", result.acne_percentage)
                        metricRow("👁 الهالات السوداء", result.dark_circles_percentage)
                        metricRow("〰️ الخطوط الدقيقة", result.fine_lines_percentage)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)

                    if let concerns = result.concerns, !concerns.isEmpty {
                        VStack(alignment: .trailing, spacing: 10) {
                            Text("ملاحظات").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
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
    private func metricRow(_ label: String, _ value: Int?) -> some View {
        HStack {
            Text(label).font(.custom("Tajawal-Medium", size: 13)).foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value != nil ? "\(value!)%" : "—")
                .font(.custom("Tajawal-Bold", size: 14))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SkinScanView()
}
