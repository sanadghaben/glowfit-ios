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

        // MARK: - Login
        "login_welcome": "مرحباً بعودتك 💜",
        "login_email_label": "البريد الإلكتروني",
        "login_password_label": "كلمة المرور",
        "login_remember_me": "تذكرني",
        "login_forgot_password": "نسيت كلمة المرور؟",
        "login_or": "أو",
        "login_no_account": "ليس لديك حساب؟",
        "login_create_account": "إنشاء حساب",
        "login_button": "تسجيل الدخول",
        "login_error_email": "يرجى إدخال بريد إلكتروني صحيح",
        "login_error_password": "يرجى إدخال كلمة المرور",

        // MARK: - Signup
        "signup_title": "حساب جديد",
        "signup_subtitle": "ابدأي رحلتك مع GlowFit ✨",
        "signup_full_name": "الاسم الكامل",
        "signup_email": "البريد الإلكتروني",
        "signup_phone": "رقم الجوال",
        "signup_password": "كلمة المرور",
        "signup_gender": "الجنس",
        "signup_female": "أنثى",
        "signup_male": "ذكر",
        "signup_agree_to": "أوافق على",
        "signup_terms_privacy": "الشروط وسياسة الخصوصية",
        "signup_or": "أو",
        "signup_have_account": "لديك حساب بالفعل؟",
        "signup_login": "تسجيل الدخول",
        "signup_button": "إنشاء الحساب",
        "signup_placeholder_name": "أدخلي اسمك الكامل",
        "signup_placeholder_password": "8 أحرف على الأقل",
        "signup_error_terms": "يرجى الموافقة على الشروط وسياسة الخصوصية أولاً",
        "signup_error_url": "رابط الباك آند غير صحيح",
        "signup_error_data": "خطأ في معالجة البيانات",
        "signup_error_network": "خطأ في الاتصال بالشبكة: %@",
        "signup_error_response": "استجابة غير صالحة من خادم الباك آند",
        "signup_error_exists": "هذا البريد الإلكتروني مسجل عندنا بالفعل. سجّلي دخول بدلاً من ذلك.",
        "signup_error_generic": "حدث خطأ أثناء إنشاء الحساب (رمز الخطأ: %d)",
        "signup_error_already_registered": "هذا البريد الإلكتروني مسجل بالفعل",
        "signup_error_password_length": "كلمة المرور يجب أن تكون 8 أحرف على الأقل",
        "signup_error_invalid_email": "يرجى إدخال بريد إلكتروني صحيح",
        "signup_error_rate_limit": "تم تجاوز حد الطلبات المسموح به، يرجى المحاولة لاحقاً",
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

        // MARK: - Login
        "login_welcome": "Welcome back 💜",
        "login_email_label": "Email",
        "login_password_label": "Password",
        "login_remember_me": "Remember me",
        "login_forgot_password": "Forgot password?",
        "login_or": "or",
        "login_no_account": "Don't have an account?",
        "login_create_account": "Create account",
        "login_button": "Log In",
        "login_error_email": "Please enter a valid email",
        "login_error_password": "Please enter your password",

        // MARK: - Signup
        "signup_title": "New Account",
        "signup_subtitle": "Start your journey with GlowFit ✨",
        "signup_full_name": "Full Name",
        "signup_email": "Email",
        "signup_phone": "Phone Number",
        "signup_password": "Password",
        "signup_gender": "Gender",
        "signup_female": "Female",
        "signup_male": "Male",
        "signup_agree_to": "I agree to the",
        "signup_terms_privacy": "Terms & Privacy Policy",
        "signup_or": "or",
        "signup_have_account": "Already have an account?",
        "signup_login": "Log In",
        "signup_button": "Create Account",
        "signup_placeholder_name": "Enter your full name",
        "signup_placeholder_password": "At least 8 characters",
        "signup_error_terms": "Please agree to the Terms & Privacy Policy first",
        "signup_error_url": "Invalid backend URL",
        "signup_error_data": "Error processing data",
        "signup_error_network": "Network connection error: %@",
        "signup_error_response": "Invalid response from backend server",
        "signup_error_exists": "This email is already registered. Please log in instead.",
        "signup_error_generic": "An error occurred while creating the account (error code: %d)",
        "signup_error_already_registered": "This email is already registered",
        "signup_error_password_length": "Password must be at least 8 characters",
        "signup_error_invalid_email": "Please enter a valid email",
        "signup_error_rate_limit": "Request limit exceeded, please try again later",
    ]
}
