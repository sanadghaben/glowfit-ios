import SwiftUI

/// نظام ترجمة بسيط ومستقل بالكامل عن أي إعدادات مشروع خارجية —
/// بيحدد اللغة تلقائياً حسب لغة الجهاز: عربي لو الجهاز عربي، إنجليزي لأي لغة تانية.
enum AppLanguage {
    static var isArabic: Bool {
        let code = Locale.preferredLanguages.first ?? "en"
        return code.hasPrefix("ar")
    }

    static var layoutDirection: LayoutDirection {
        isArabic ? .rightToLeft : .leftToRight
    }

    static var locale: Locale {
        isArabic ? Locale(identifier: "ar") : Locale(identifier: "en")
    }
}

/// دالة الترجمة الأساسية — L("مفتاح") بترجع النص المناسب حسب لغة الجهاز
func L(_ key: String) -> String {
    let dict = AppLanguage.isArabic ? AppStrings.ar : AppStrings.en
    return dict[key] ?? key
}

/// امتداد بسيط عشان أي شاشة تطبّق الاتجاه الصحيح تلقائياً بسطر واحد بدل ما تثبّته يدوياً
extension View {
    func autoLayoutDirection() -> some View {
        self.environment(\.layoutDirection, AppLanguage.layoutDirection)
    }
}
