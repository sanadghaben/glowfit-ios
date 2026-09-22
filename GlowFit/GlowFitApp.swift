//
//  GlowFitApp.swift
//  GlowFit
//
//  Created by SAN on 4/25/26.
//

import SwiftUI

@main
struct GlowFitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // نراقب اختيار اللغة مباشرة من هون — أي تغيير فيها بيخلي iOS يعيد بناء الواجهة كاملة تلقائياً
    @AppStorage("gf_language_override") private var languageOverride: String = "auto"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(languageOverride) // يجبر SwiftUI يعيد بناء كل شاشات التطبيق من الصفر فور تغيير اللغة
        }
    }
}
