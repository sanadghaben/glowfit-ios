import SwiftUI

// MARK: - SplashView
struct SplashView: View {
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0.0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background color
            Color(red: 10/255, green: 10/255, blue: 15/255)
                .ignoresSafeArea()
            
            // Animated Background Gradients
            AnimatedGradients(isAnimating: isAnimating)
            
            // Particles System
            ParticleSystem()
            
            VStack {
                Spacer()
                
                // Logo Section
                LogoContainer(isAnimating: isAnimating)
                    .padding(.bottom, 30)
                
                // App Name
                Text("GlowFit AI")
                    .font(.custom("Tajawal-Black", size: 40, relativeTo: .largeTitle))
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.pink, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .hueRotation(.degrees(isAnimating ? 30 : 0))
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                    
                
                // Tagline
                Text("جمالكِ الذكي يبدأ هنا ✨")
                    .font(.custom("Tajawal-Light", size: 18, relativeTo: .body))
                    .foregroundColor(Color.white.opacity(0.6))
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                    .padding(.top, 10)
                
                Spacer()
                
                // Loading Bar
                VStack(spacing: 12) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 200, height: 3)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 200 * progress, height: 3)
                    }
                    
                    Text("جاري التحميل...")
                        .font(.custom("Tajawal-Light", size: 12, relativeTo: .caption))
                        .foregroundColor(Color.white.opacity(0.35))
                        .tracking(1)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
                .padding(.bottom, 80)
            }
            
            // Version
            VStack {
                Spacer()
                Text("v1.0.0")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.2))
                    .padding(.bottom, 30)
                    .opacity(textOpacity)
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // For Arabic RTL
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
        
        // Text fade up
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            textOpacity = 1.0
            textOffset = 0
        }
        
        // Progress bar loading
        withAnimation(.easeInOut(duration: 3.0)) {
            progress = 1.0
        }
    }
}

// MARK: - Animated Gradients
struct AnimatedGradients: View {
    var isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Orb 1
            Circle()
                .fill(Color.purple.opacity(0.12))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: 0, y: isAnimating ? -100 : -150)
            
            // Orb 2
            Circle()
                .fill(Color.pink.opacity(0.08))
                .frame(width: 250)
                .blur(radius: 50)
                .offset(x: -100, y: isAnimating ? 150 : 200)
                
            // Orb 3
            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 250)
                .blur(radius: 50)
                .offset(x: 150, y: isAnimating ? 100 : 50)
        }
    }
}

// MARK: - Logo Container
struct LogoContainer: View {
    var isAnimating: Bool
    @State private var ringRotation: Double = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Rotating Ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.3), Color.clear, Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(ringRotation))
                .onAppear {
                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                        ringRotation = 360
                    }
                }
            
            // Outer Pulse Ring
            Circle()
                .stroke(Color.purple.opacity(isAnimating ? 0.2 : 0.1), lineWidth: 2)
                .frame(width: 260, height: 260)
                .shadow(color: Color.purple.opacity(isAnimating ? 0.2 : 0.1), radius: isAnimating ? 40 : 20)
            
            // Inner Circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 26/255, green: 10/255, blue: 46/255), Color(red: 13/255, green: 13/255, blue: 26/255)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle().stroke(Color.purple.opacity(0.15), lineWidth: 1)
                )
                .frame(width: 230, height: 230)
            
            // The actual Logo
            // TODO: استبدل هذا المكون بصورة الشعار الخاصة بك في المستقبل عبر: Image("logo_name")
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .pink.opacity(0.5), radius: 15)
                
                Text("GlowFit")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .pink.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
            }
            .frame(width: 150, height: 150)
            .shadow(color: Color.pink.opacity(0.3), radius: 25)
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
        .onAppear {
            withAnimation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

// MARK: - Particle System
struct ParticleSystem: View {
    // Generate static random positions for performance
    let particles = (0..<25).map { _ in Particle() }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<particles.count, id: \.self) { index in
                    ParticleView(particle: particles[index], size: geometry.size)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct Particle {
    let size: CGFloat = CGFloat.random(in: 2...6)
    let xOffset: CGFloat = CGFloat.random(in: 0...1)
    let color: Color = [Color.purple.opacity(0.6), Color.pink.opacity(0.5), Color.purple.opacity(0.4), Color.pink.opacity(0.5)].randomElement()!
    let duration: Double = Double.random(in: 6...14)
    let delay: Double = Double.random(in: 0...5)
}

struct ParticleView: View {
    let particle: Particle
    let size: CGSize
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .position(
                x: size.width * particle.xOffset,
                y: isAnimating ? -50 : size.height + 50
            )
            .opacity(isAnimating ? 1.0 : 0.0)
            .scaleEffect(isAnimating ? 1.0 : 0.0)
            .onAppear {
                // Initial setup
                DispatchQueue.main.asyncAfter(deadline: .now() + particle.delay) {
                    withAnimation(.linear(duration: particle.duration).repeatForever(autoreverses: false)) {
                        isAnimating = true
                    }
                }
            }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Integration Guide
/*
 كيفية استخدام SwiftUI داخل UIKit (مثل LoginByPhoneVC):
 
 إذا كان تطبيقك يستخدم UIKit كمرحلة أساسية، يمكنك استدعاء هذه الشاشة باستخدام `UIHostingController` كالتالي:
 
 import SwiftUI
 import UIKit
 
 class SplashViewController: UIViewController {
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // إعداد شاشة SwiftUI
         let splashView = SplashView()
         let hostingController = UIHostingController(rootView: splashView)
         
         // إضافتها إلى الواجهة
         addChild(hostingController)
         view.addSubview(hostingController.view)
         hostingController.view.frame = view.bounds
         hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         hostingController.didMove(toParent: self)
         
         // بعد الانتهاء من التحميل، يمكنك الانتقال لشاشة الدخول LoginByPhoneVC
         DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
             // كود الانتقال للشاشة التالية هنا
         }
     }
 }
 */
