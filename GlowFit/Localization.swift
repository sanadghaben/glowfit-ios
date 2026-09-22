import SwiftUI

/// نظام ترجمة — افتراضياً بيحدد اللغة تلقائياً حسب لغة الجهاز،
/// بس بيدعم كمان اختيار يدوي صريح من شاشة إعدادات اللغة (بيتفوّق على الكشف التلقائي).
enum AppLanguage {
    /// "auto" = اتبعي لغة الجهاز، "ar"/"en" = فرض لغة معيّنة يدوياً
    static var manualOverride: String {
        get { UserDefaults.standard.string(forKey: "gf_language_override") ?? "auto" }
        set { UserDefaults.standard.set(newValue, forKey: "gf_language_override") }
    }

    static var isArabic: Bool {
        switch manualOverride {
        case "ar": return true
        case "en": return false
        default:
            let code = Locale.preferredLanguages.first ?? "en"
            return code.hasPrefix("ar")
        }
    }

    static var layoutDirection: LayoutDirection {
        isArabic ? .rightToLeft : .leftToRight
    }

    static var locale: Locale {
        isArabic ? Locale(identifier: "ar") : Locale(identifier: "en")
    }

    /// سهم "الانتقال للأمام" (زي أسهم صفوف الإعدادات) — يسار بالعربي (RTL)، يمين بالإنجليزي (LTR)
    static var forwardChevron: String {
        isArabic ? "chevron.left" : "chevron.right"
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
