import SwiftUI

// MARK: - Store View
struct StoreView: View {
    @StateObject private var cart = CartManager()
    @State private var selectedCategory: String = "الكل"
    @State private var searchText = ""
    @State private var selectedProduct: GlowFitAPI.RealProduct? = nil
    @State private var showCart = false
    @State private var isLoading = true
    @State private var products: [GlowFitAPI.RealProduct] = []
    @State private var matchScores: [String: Int] = [:]
    @Environment(\.dismiss) var dismiss

    var categories: [String] {
        var set = Set(products.compactMap { $0.category })
        set.insert("الكل")
        return ["الكل"] + set.subtracting(["الكل"]).sorted()
    }

    var filteredProducts: [GlowFitAPI.RealProduct] {
        let base = selectedCategory == "الكل" ? products : products.filter { $0.category == selectedCategory }
        if searchText.isEmpty { return base }
        return base.filter { ($0.name ?? "").contains(searchText) || ($0.brand ?? "").contains(searchText) }
    }

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 0) {
                StoreHeaderView(dismiss: dismiss, showCart: $showCart, cartCount: cart.totalCount)
                    .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 12)

                StoreSearchBar(text: $searchText)
                    .padding(.horizontal, 20).padding(.bottom, 14)

                if !isLoading {
                    StoreCategoryBar(categories: categories, selected: $selectedCategory)
                        .padding(.bottom, 14)
                }

                if isLoading {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                } else if products.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("🛍").font(.system(size: 44))
                        Text("ما في منتجات متاحة حالياً").font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            AIMatchBanner()
                                .padding(.horizontal, 20)

                            let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(filteredProducts) { product in
                                    ProductCard(product: product, matchPercent: matchScores[product.id] ?? 70, cart: cart)
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
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(item: $selectedProduct) { p in
            ProductDetailSheet(product: p, matchPercent: matchScores[p.id] ?? 70, cart: cart)
        }
        .fullScreenCover(isPresented: $showCart) {
            CartView(cart: cart)
        }
        .onAppear(perform: loadProducts)
    }

    private func loadProducts() {
        GlowFitAPI.getStoreProducts { fetched, matches in
            products = fetched
            matchScores = matches
            isLoading = false
        }
    }
}

// MARK: - Cart Manager (حالة مشتركة بين شاشات المتجر والسلة)
final class CartManager: ObservableObject {
    @Published var items: [CartItem] = []

    var totalCount: Int { items.reduce(0) { $0 + $1.quantity } }
    var subtotal: Double { items.reduce(0) { $0 + ($1.product.price ?? 0) * Double($1.quantity) } }

    func add(_ product: GlowFitAPI.RealProduct, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func clear() { items.removeAll() }
}

// MARK: - Header
struct StoreHeaderView: View {
    var dismiss: DismissAction
    @Binding var showCart: Bool
    let cartCount: Int

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
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.04))
                            .frame(width: 40, height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        Image(systemName: "bag")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    if cartCount > 0 {
                        Text("\(cartCount)")
                            .font(.custom("Tajawal-Bold", size: 10))
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(AuthColors.primaryPink)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                    }
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
    let categories: [String]
    @Binding var selected: String
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { cat in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = cat }
                    }) {
                        Text(cat)
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
                Text("نسبة التطابق محسوبة بناءً على نوع بشرتك ونتائج فحصك الأخير")
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
    let product: GlowFitAPI.RealProduct
    let matchPercent: Int
    @ObservedObject var cart: CartManager
    @State private var justAdded = false

    var matchColor: Color {
        matchPercent >= 95 ? Color(red: 0.29, green: 0.77, blue: 0.50)
        : matchPercent >= 85 ? AuthColors.primaryPurple
        : AuthColors.primaryPink
    }
    var priceText: String {
        guard let price = product.price else { return "—" }
        return "\(Int(price)) ر.س"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.1), AuthColors.primaryPink.opacity(0.08)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 110)
                Text(GlowFitAPI.iconFor(category: product.category)).font(.system(size: 48))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand ?? "")
                    .font(.custom("Tajawal-Regular", size: 11))
                    .foregroundColor(Color.white.opacity(0.35))
                Text(product.name ?? "")
                    .font(.custom("Tajawal-Bold", size: 13))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }

            HStack {
                HStack(spacing: 3) {
                    Circle().fill(matchColor).frame(width: 5, height: 5)
                    Text("\(matchPercent)% تطابق")
                        .font(.custom("Tajawal-Bold", size: 10))
                        .foregroundColor(matchColor)
                }
                Spacer()
                Text(priceText)
                    .font(.custom("Tajawal-Bold", size: 13))
                    .foregroundColor(.white)
            }

            Button(action: {
                cart.add(product)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { justAdded = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { withAnimation { justAdded = false } }
            }) {
                Text(justAdded ? "أُضيفت ✓" : "أضف للسلة")
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
    let product: GlowFitAPI.RealProduct
    let matchPercent: Int
    @ObservedObject var cart: CartManager
    @State private var quantity = 1
    @Environment(\.dismiss) var dismiss

    var priceText: String {
        guard let price = product.price else { return "—" }
        return "\(Int(price)) ر.س"
    }

    var body: some View {
        AccountSheet(title: product.name ?? "منتج") {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.15), AuthColors.primaryPink.opacity(0.1)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 160)
                    Text(GlowFitAPI.iconFor(category: product.category)).font(.system(size: 70))
                }

                VStack(spacing: 6) {
                    Text(product.brand ?? "")
                        .font(.custom("Tajawal-Regular", size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                    Text(product.name ?? "")
                        .font(.custom("Tajawal-Bold", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 16) {
                    if let ingredient = product.key_ingredient {
                        HStack(spacing: 4) {
                            Image(systemName: "leaf.fill").foregroundColor(Color(red: 0.29, green: 0.77, blue: 0.50)).font(.system(size: 12))
                            Text(ingredient).font(.custom("Tajawal-Bold", size: 12)).foregroundColor(.white)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.white.opacity(0.04)).cornerRadius(10)
                    }

                    HStack(spacing: 4) {
                        Circle().fill(AuthColors.primaryPurple).frame(width: 6, height: 6)
                        Text("\(matchPercent)% تطابق مع بشرتك")
                            .font(.custom("Tajawal-Bold", size: 13)).foregroundColor(AuthColors.primaryPurple)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(AuthColors.primaryPurple.opacity(0.08)).cornerRadius(10)
                }

                if let description = product.description {
                    Text(description)
                        .font(.custom("Tajawal-Regular", size: 14))
                        .foregroundColor(Color.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 4)
                }

                HStack {
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

                    Text(priceText)
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink],
                                                        startPoint: .leading, endPoint: .trailing))
                }

                Button(action: {
                    cart.add(product, quantity: quantity)
                    dismiss()
                }) {
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
