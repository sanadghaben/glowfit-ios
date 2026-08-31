import SwiftUI

struct SkinScanView: View {
    @State private var isScanning = false
    @State private var scanLineOffset: CGFloat = -150
    @State private var showAnalyzing = false
    
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
                    Text("تأكدي من الإضاءة الجيدة وعدم وجود مكياج للحصول على أدق النتائج ✨")
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 40) {
                        Button(action: {}) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        // Capture Button
                        Button(action: { toggleScan() }) {
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
    }
    
    private func toggleScan() {
        withAnimation {
            isScanning.toggle()
        }
        
        if isScanning {
            scanLineOffset = -150
            
            // Simulate scanning duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    showAnalyzing = true
                }
                
                // Simulate analysis completion
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isScanning = false
                        showAnalyzing = false
                    }
                }
            }
        }
    }
}

#Preview {
    SkinScanView()
}
