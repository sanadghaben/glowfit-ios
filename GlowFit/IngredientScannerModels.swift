//
//  IngredientScannerModels.swift
//  GlowFit
//
//  ماسح المكونات — النماذج وبيانات تجريبية ثابتة (المرحلة الأولى: واجهة فقط، بدون ربط بالخادم).
//

import SwiftUI

enum IngredientLevel {
    case good, neutral, caution, bad

    var color: Color {
        switch self {
        case .good: return Color(red: 74/255, green: 222/255, blue: 128/255)
        case .neutral: return Color.white.opacity(0.5)
        case .caution: return Color(red: 251/255, green: 191/255, blue: 36/255)
        case .bad: return Color(red: 248/255, green: 113/255, blue: 113/255)
        }
    }
}

struct ScannedIngredient: Identifiable {
    let id = UUID()
    let name: String
    let explanationKey: String   // مفتاح شرح بسيط للمكوّن
    let level: IngredientLevel
}

struct IngredientConflict: Identifiable {
    let id = UUID()
    let first: String
    let second: String
    let noteKey: String
}

enum ScanVerdict {
    case suitable, careful, unsuitable

    static func from(percent: Int) -> ScanVerdict {
        percent >= 80 ? .suitable : (percent >= 50 ? .careful : .unsuitable)
    }
    var titleKey: String {
        switch self {
        case .suitable: return "ingscan_verdict_suitable"
        case .careful: return "ingscan_verdict_careful"
        case .unsuitable: return "ingscan_verdict_unsuitable"
        }
    }
    var color: Color {
        switch self {
        case .suitable: return IngredientLevel.good.color
        case .careful: return IngredientLevel.caution.color
        case .unsuitable: return IngredientLevel.bad.color
        }
    }
}

struct IngredientScanResult {
    let percent: Int
    let ingredients: [ScannedIngredient]
    let conflicts: [IngredientConflict]
    var verdict: ScanVerdict { .from(percent: percent) }

    /// بيانات تجريبية للعرض فقط — ستُستبدل بنتيجة الخادم لاحقاً
    static let mock = IngredientScanResult(
        percent: 72,
        ingredients: [
            ScannedIngredient(name: "Aqua", explanationKey: "ingscan_mock_aqua", level: .neutral),
            ScannedIngredient(name: "Glycerin", explanationKey: "ingscan_mock_glycerin", level: .good),
            ScannedIngredient(name: "Niacinamide", explanationKey: "ingscan_mock_niacinamide", level: .good),
            ScannedIngredient(name: "Retinol", explanationKey: "ingscan_mock_retinol", level: .caution),
            ScannedIngredient(name: "Glycolic Acid", explanationKey: "ingscan_mock_glycolic", level: .caution),
            ScannedIngredient(name: "Alcohol Denat.", explanationKey: "ingscan_mock_alcohol", level: .bad),
            ScannedIngredient(name: "Parfum", explanationKey: "ingscan_mock_parfum", level: .caution)
        ],
        conflicts: [
            IngredientConflict(first: "Retinol", second: "Glycolic Acid", noteKey: "ingscan_mock_conflict")
        ]
    )

    static let mockRawList: [String] = mock.ingredients.map { $0.name }
}
