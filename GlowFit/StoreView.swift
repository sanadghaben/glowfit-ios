import SwiftUI

// MARK: - Store View
struct StoreView: View {
    @State private var selectedCategory: StoreCategory = .all
    @State private var searchText = ""
    @State private var selectedProduct: StoreProduct? = nil
    @State private var showCart = false
    @Environment(\.dismiss) var dismiss

    var filteredProducts: [StoreProduct] {
        let base = selectedCategory == .all
            ? StoreProduct.sampleProducts
            : StoreProduct.sampleProducts.filter { $0.category == selectedCategory }
        if searchText.isEmpty { return base }
        return base.filter { $0.name.contains(searchText) || $0.brand.contains(searchText) }
    }

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 0) {

                // ─── Header ───
                StoreHeaderView(dismiss: dismiss, showCart: $showCart)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                // ─── Search ───
                StoreSearchBar(text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                // ─── Categories ───
                StoreCategoryBar(selected: $selectedCategory)
                    .padding(.bottom, 14)

                // ─── Products Grid ───
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // AI Recommendation Banner
                        AIMatchBanner()
                            .padding(.horizontal, 20)

                        // Grid
                        let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(filteredProducts) { product in
                                ProductCard(product: product)
                                    .onTapGesture { selectedProduct = product }
                            }
                        }
                        .padding(.horizontal, 20)

                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(item: $selectedProduct) { p in
            ProductDetailSheet(product: p)
        }
        .fullScreenCover(isPresented: $showCart) {
            CartView()
        }
    }
}

// MARK: - Category Enum
enum StoreCategory: String, CaseIterable {
    case all        = "الكل"
    case cleanser   = "غسول"
    case serum      = "سيروم"
    case moisturizer = "مرطب"
    case sunscreen  = "واقي شمس"
    case mask       = "قناع"
}

// MARK: - Product Model
struct StoreProduct: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let brand: String
    let price: String
    let rating: Double
    let reviews: Int
    let matchPercent: Int
    let category: StoreCategory
    let badgeText: String?
    let description: String
}

extension StoreProduct {
    static let sampleProducts: [StoreProduct] = [
        StoreProduct(icon: "💧", name: "Hydro Boost Gel", brand: "Neutrogena", price: "٨٥ ر.س",
                     rating: 4.8, reviews: 1240, matchPercent: 98, category: .moisturizer,
                     badgeText: "الأعلى تطابقاً", description: "مرطب جيل خفيف يمنح البشرة ترطيباً مكثفاً 48 ساعة بتقنية Hyaluronic Acid."),
        StoreProduct(icon: "✨", name: "Vitamin C Serum", brand: "TruSkin", price: "١١٠ ر.س",
                     rating: 4.7, reviews: 890, matchPercent: 95, category: .serum,
                     badgeText: "مقترح لك", description: "سيروم فيتامين C المركّز لتوحيد لون البشرة وتفتيح الهالات السوداء."),
        StoreProduct(icon: "🧴", name: "Hydrating Cleanser", brand: "CeraVe", price: "٦٥ ر.س",
                     rating: 4.9, reviews: 3200, matchPercent: 92, category: .cleanser,
                     badgeText: nil, description: "غسول لطيف يحافظ على الحاجز الطبيعي للبشرة بثلاثة سيراميدات أساسية."),
        StoreProduct(icon: "☀️", name: "Anthelios SPF 50+", brand: "La Roche-Posay", price: "١٣٥ ر.س",
                     rating: 4.8, reviews: 2100, matchPercent: 90, category: .sunscreen,
                     badgeText: "الأكثر مبيعاً", description: "واقي شمس خفيف الملمس لا يترك أثراً أبيض، مثالي للبشرة الحساسة."),
        StoreProduct(icon: "🌿", name: "Retinol 24 Serum", brand: "Olay", price: "١٤٥ ر.س",
                     rating: 4.6, reviews: 750, matchPercent: 88, category: .serum,
                     badgeText: nil, description: "سيروم الريتينول للعناية الليلية يقلل الخطوط الدقيقة ويجدد خلايا البشرة."),
        StoreProduct(icon: "🍯", name: "Honey Glow Mask", brand: "GlowFit AI", price: "٩٥ ر.س",
                     rating: 4.5, reviews: 310, matchPercent: 85, category: .mask,
                     badgeText: "جديد", description: "قناع العسل المغذي يهب البشرة توهجاً فورياً ويعزز الترطيب العميق."),
    ]
}

// MARK: - Header
struct StoreHeaderView: View {
    var dismiss: DismissAction
    @Binding var showCart: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("المتجر 🛍️")
                    .font(.custom("Tajawal-Bold", size: 22))
                    .foregroundColor(.white)
                Text("منتجات مختارة لبشرتك")
                    .font(.custom("Tajawal-Regular", size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            Spacer()
            Button(action: { showCart = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    Image(systemName: "bag")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Search Bar
struct StoreSearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.white.opacity(0.3))
                .font(.system(size: 15))
            TextField("", text: $text)
                .foregroundColor(.white)
                .placeholder(when: text.isEmpty) {
                    Text("ابحثي عن منتج...").foregroundColor(Color.white.opacity(0.25))
                }
                .font(.custom("Tajawal-Regular", size: 14))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Category Bar
struct StoreCategoryBar: View {
    @Binding var selected: StoreCategory
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(StoreCategory.allCases, id: \.self) { cat in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = cat }
                    }) {
                        Text(cat.rawValue)
                            .font(.custom("Tajawal-Bold", size: 13))
                            .foregroundColor(selected == cat ? .white : Color.white.opacity(0.45))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selected == cat
                                    ? LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                     startPoint: .leading, endPoint: .trailing)
                                        .cornerRadius(20)
                                    : LinearGradient(colors: [Color.white.opacity(0.05)],
                                                     startPoint: .leading, endPoint: .trailing)
                                        .cornerRadius(20)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - AI Match Banner
struct AIMatchBanner: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.3), AuthColors.primaryPink.opacity(0.3)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                Text("🤖").font(.system(size: 24))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("اختار AI منتجاتك!")
                    .font(.custom("Tajawal-Bold", size: 15))
                    .foregroundColor(.white)
                Text("هذه المنتجات تم اختيارها بناءً على نتائج فحص بشرتك الأخير")
                    .font(.custom("Tajawal-Regular", size: 12))
                    .foregroundColor(Color.white.opacity(0.55))
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.12), AuthColors.primaryPink.opacity(0.08)],
                                   startPoint: .leading, endPoint: .trailing))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AuthColors.primaryPurple.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: StoreProduct
    @State private var isWishlisted = false

    var matchColor: Color {
        product.matchPercent >= 95 ? Color(red:0.29,green:0.77,blue:0.50)
        : product.matchPercent >= 85 ? AuthColors.primaryPurple
        : AuthColors.primaryPink
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Product Icon Area
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.1), AuthColors.primaryPink.opacity(0.08)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 110)
                    Text(product.icon).font(.system(size: 48))
                }
                // Badge
                if let badge = product.badgeText {
                    Text(badge)
                        .font(.custom("Tajawal-Bold", size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                   startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                        .padding(8)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .font(.custom("Tajawal-Regular", size: 11))
                    .foregroundColor(Color.white.opacity(0.35))
                Text(product.name)
                    .font(.custom("Tajawal-Bold", size: 13))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }

            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red:0.98,green:0.75,blue:0.14))
                Text(String(format: "%.1f", product.rating))
                    .font(.custom("Tajawal-Bold", size: 11))
                    .foregroundColor(.white)
                Text("(\(product.reviews))")
                    .font(.custom("Tajawal-Regular", size: 10))
                    .foregroundColor(Color.white.opacity(0.3))
            }

            // Match + Price
            HStack {
                // Match %
                HStack(spacing: 3) {
                    Circle().fill(matchColor).frame(width: 5, height: 5)
                    Text("\(product.matchPercent)% تطابق")
                        .font(.custom("Tajawal-Bold", size: 10))
                        .foregroundColor(matchColor)
                }
                Spacer()
                Text(product.price)
                    .font(.custom("Tajawal-Bold", size: 13))
                    .foregroundColor(.white)
            }

            // Add to Cart
            Button(action: {}) {
                Text("أضف للسلة")
                    .font(.custom("Tajawal-Bold", size: 12))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                               startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }
}

// MARK: - Product Detail Sheet
struct ProductDetailSheet: View {
    let product: StoreProduct
    @State private var quantity = 1
    @Environment(\.dismiss) var dismiss

    var body: some View {
        AccountSheet(title: product.name) {
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.15), AuthColors.primaryPink.opacity(0.1)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 160)
                    Text(product.icon).font(.system(size: 70))
                }

                // Brand + Name
                VStack(spacing: 6) {
                    Text(product.brand)
                        .font(.custom("Tajawal-Regular", size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                    Text(product.name)
                        .font(.custom("Tajawal-Bold", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }

                // Rating + Match
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(Color(red:0.98,green:0.75,blue:0.14)).font(.system(size: 13))
                        Text(String(format: "%.1f", product.rating))
                            .font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.white.opacity(0.04)).cornerRadius(10)

                    HStack(spacing: 4) {
                        Circle().fill(AuthColors.primaryPurple).frame(width: 6, height: 6)
                        Text("\(product.matchPercent)% تطابق مع بشرتك")
                            .font(.custom("Tajawal-Bold", size: 13)).foregroundColor(AuthColors.primaryPurple)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(AuthColors.primaryPurple.opacity(0.08)).cornerRadius(10)
                }

                // Description
                Text(product.description)
                    .font(.custom("Tajawal-Regular", size: 14))
                    .foregroundColor(Color.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 4)

                // Quantity + Price
                HStack {
                    // Quantity Stepper
                    HStack(spacing: 0) {
                        Button(action: { if quantity > 1 { quantity -= 1 } }) {
                            Image(systemName: "minus").font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white).frame(width: 36, height: 36)
                        }
                        Text("\(quantity)")
                            .font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                            .frame(width: 36)
                        Button(action: { quantity += 1 }) {
                            Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white).frame(width: 36, height: 36)
                        }
                    }
                    .background(Color.white.opacity(0.05)).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))

                    Spacer()

                    Text(product.price)
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                        startPoint: .leading, endPoint: .trailing))
                }

                // Add to Cart Button
                Button(action: { dismiss() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bag.badge.plus").font(.system(size: 16))
                        Text("أضف إلى السلة")
                            .font(.custom("Tajawal-Bold", size: 17))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                               startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                    .shadow(color: AuthColors.primaryPurple.opacity(0.35), radius: 12, y: 6)
                }
            }
        }
    }
}

#Preview { StoreView() }
