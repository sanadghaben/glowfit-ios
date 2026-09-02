//
//  ContentView.swift
//  GlowFit
//
//  Created by SAN on 4/25/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        // الانتقال لشاشة الترحيب بعد 3.5 ثانية
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else if !hasSeenOnboarding {
                OnboardingView()
            } else if !isLoggedIn {
                NavigationView {
                    LoginView()
                }
            } else {
                PostLoginGateView()
            }
        }
    }
}

#Preview {
    ContentView()
}
