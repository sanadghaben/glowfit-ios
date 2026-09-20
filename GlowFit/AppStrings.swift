import Foundation

/// قاموس الترجمات — كل شاشة نترجمها بنضيف مفاتيحها هون تحت تعليق باسم الشاشة.
/// أضيفي مفتاح جديد بالعربي والإنجليزي مع بعض دايماً عشان ما تنكسر الترجمة.
enum AppStrings {

    static let ar: [String: String] = [
        // MARK: - Splash
        "splash_tagline": "جمالكِ الذكي يبدأ هنا ✨",
        "splash_loading": "جاري التحميل...",

        // MARK: - Onboarding
        "onboarding_skip": "تخطي",
        "onboarding_next": "التالي",
        "onboarding_start": "ابدأ الآن",
        "onboarding_1_title": "فحص ذكي لبشرتك",
        "onboarding_1_desc": "مسح ضوئي دقيق باستخدام الذكاء الاصطناعي لتحليل بشرتك وفهم احتياجاتها في ثوانٍ.",
        "onboarding_2_title": "نقاط تقييم البشرة",
        "onboarding_2_desc": "احصلي على تقييم تفصيلي لصحة بشرتك مع تحليل دقيق للمسامات، الهالات، ونضارة الوجه.",
        "onboarding_3_title": "روتين مخصص لكِ",
        "onboarding_3_desc": "جدول عناية يومي مصمم خصيصاً ليناسب نوع بشرتك، مع تتبع مستمر للنتائج وتطور صحة البشرة.",
        "onboarding_1_pill1": "🤖 ذكاء اصطناعي", "onboarding_1_pill2": "📸 تحليل فوري", "onboarding_1_pill3": "✨ دقة عالية",
        "onboarding_2_pill1": "📊 تقييم شامل", "onboarding_2_pill2": "🔍 تحليل دقيق", "onboarding_2_pill3": "💡 نصائح ذكية",
        "onboarding_3_pill1": "📅 روتين يومي", "onboarding_3_pill2": "📈 تتبع التقدم", "onboarding_3_pill3": "🌟 نتائج ملحوظة",
    ]

    static let en: [String: String] = [
        // MARK: - Splash
        "splash_tagline": "Your smart glow starts here ✨",
        "splash_loading": "Loading...",

        // MARK: - Onboarding
        "onboarding_skip": "Skip",
        "onboarding_next": "Next",
        "onboarding_start": "Get Started",
        "onboarding_1_title": "Smart Skin Scan",
        "onboarding_1_desc": "A precise AI-powered scan that analyzes your skin and understands its needs in seconds.",
        "onboarding_2_title": "Skin Health Score",
        "onboarding_2_desc": "Get a detailed assessment of your skin health with accurate analysis of pores, dark circles, and radiance.",
        "onboarding_3_title": "A Routine Made For You",
        "onboarding_3_desc": "A daily care schedule designed specifically for your skin type, with continuous tracking of results and skin health progress.",
        "onboarding_1_pill1": "🤖 AI Powered", "onboarding_1_pill2": "📸 Instant Analysis", "onboarding_1_pill3": "✨ High Accuracy",
        "onboarding_2_pill1": "📊 Full Assessment", "onboarding_2_pill2": "🔍 Precise Analysis", "onboarding_2_pill3": "💡 Smart Tips",
        "onboarding_3_pill1": "📅 Daily Routine", "onboarding_3_pill2": "📈 Progress Tracking", "onboarding_3_pill3": "🌟 Visible Results",
    ]
}
