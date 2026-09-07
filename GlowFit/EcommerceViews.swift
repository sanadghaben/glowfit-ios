import SwiftUI
import Combine

// MARK: - Models

struct CartItem: Identifiable {
    let id = UUID()
    let product: GlowFitAPI.RealProduct
    var quantity: Int
}

enum OrderStatus: String {
    case pending   = "pending"
    case shipped   = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"

    var label: String {
        switch self {
        case .pending:   return "قيد المعالجة ⏳"
        case .shipped:   return "تم الشحن 📦"
        case .delivered: return "تم التوصيل ✅"
        case .cancelled: return "ملغي ❌"
        }
    }
    var color: Color {
        switch self {
        case .pending:   return Color(red: 0.98, green: 0.75, blue: 0.14)
        case .shipped:   return Color.blue
        case .delivered: return Color(red: 0.29, green: 0.77, blue: 0.50)
        case .cancelled: return Color(red: 0.97, green: 0.44, blue: 0.44)
        }
    }
}

// MARK: - Cart View

struct CartView: View {
    @ObservedObject var cart: CartManager
    @Environment(\.dismiss) var dismiss
    @State private var showCheckout = false
    @State private var isPlacingOrder = false
    @State private var errorMessage: String? = nil
    @State private var lastOrderId: String? = nil

    var tax: Double { cart.subtotal * 0.15 }
    var total: Double { cart.subtotal + tax }

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) { GlowHeaderButton(systemImage: "chevron.right") }
                    Spacer()
                    Text("سلة المشتريات 🛒")
                        .font(.custom("Tajawal-Bold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 20)

                if cart.items.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cart").font(.system(size: 60)).foregroundColor(Color.white.opacity(0.2))
                        Text("السلة فارغة").font(.custom("Tajawal-Bold", size: 20)).foregroundColor(.white)
                        Text("تصفحي المتجر واختاري المنتجات المناسبة لبشرتك")
                            .font(.custom("Tajawal-Regular", size: 14)).foregroundColor(Color.white.opacity(0.4))
                            .multilineTextAlignment(.center).padding(.horizontal, 40)
                        Button(action: { dismiss() }) {
                            Text("العودة للمتجر")
                                .font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                                .padding(.horizontal, 30).padding(.vertical, 14)
                                .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(14)
                        }
                        .padding(.top, 20)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(cart.items) { item in
                                CartItemRow(item: item, cart: cart)
                            }

                            VStack(spacing: 14) {
                                Text("ملخص الطلب")
                                    .font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 4)

                                SummaryRow(title: "المجموع الفرعي", value: "\(Int(cart.subtotal)) ر.س")
                                SummaryRow(title: "الضريبة (15%)", value: "\(Int(tax)) ر.س")
                                SummaryRow(title: "التوصيل", value: "مجاني")

                                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1).padding(.vertical, 8)

                                HStack {
                                    Text("الإجمالي").font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(total)) ر.س")
                                        .font(.system(size: 22, weight: .black))
                                        .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                                }

                                if let errorMessage = errorMessage {
                                    Text(errorMessage)
                                        .font(.custom("Tajawal-Medium", size: 13))
                                        .foregroundColor(Color(red: 0.97, green: 0.44, blue: 0.44))
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
                            .padding(.top, 10)

                            Color.clear.frame(height: 100)
                        }
                        .padding(.horizontal, 20)
                    }

                    VStack {
                        Button(action: placeOrder) {
                            if isPlacingOrder {
                                ProgressView().tint(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                            } else {
                                Text("إتمام الطلب")
                                    .font(.custom("Tajawal-Bold", size: 18)).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                            }
                        }
                        .disabled(isPlacingOrder)
                        .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                        .shadow(color: AuthColors.primaryPurple.opacity(0.3), radius: 10, y: 5)
                        .padding(.horizontal, 20).padding(.bottom, 30).padding(.top, 10)
                    }
                    .background(
                        ZStack {
                            Rectangle().fill(.ultraThinMaterial)
                            Color(red: 10/255, green: 10/255, blue: 15/255).opacity(0.9)
                        }.ignoresSafeArea()
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .fullScreenCover(isPresented: $showCheckout) {
            CheckoutSuccessView(orderId: lastOrderId, onDismissAll: { dismiss() })
        }
    }

    private func placeOrder() {
        guard !isPlacingOrder else { return }
        isPlacingOrder = true
        errorMessage = nil
        let orderItems = cart.items.map {
            GlowFitAPI.OrderItemInput(productId: $0.product.id, quantity: $0.quantity, unitPrice: $0.product.price ?? 0)
        }
        GlowFitAPI.createOrder(items: orderItems, totalPrice: total) { result in
            isPlacingOrder = false
            switch result {
            case .success(let orderId):
                lastOrderId = orderId
                cart.clear()
                showCheckout = true
            case .failure(let message):
                errorMessage = message
            }
        }
    }
}

// MARK: - Cart Item Row

struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var cart: CartManager

    var priceText: String {
        guard let price = item.product.price else { return "—" }
        return "\(Int(price)) ر.س"
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.15), AuthColors.primaryPink.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                Text(GlowFitAPI.iconFor(category: item.product.category)).font(.system(size: 38))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.product.brand ?? "")
                        .font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
                    Spacer()
                    Button(action: { cart.remove(item) }) {
                        Image(systemName: "trash").font(.system(size: 14)).foregroundColor(Color.red.opacity(0.7))
                    }
                }

                Text(item.product.name ?? "")
                    .font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white).lineLimit(1)

                HStack {
                    Text(priceText).font(.custom("Tajawal-Bold", size: 14)).foregroundColor(AuthColors.primaryPink)
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: {
                            if let index = cart.items.firstIndex(where: { $0.id == item.id }), cart.items[index].quantity > 1 {
                                cart.items[index].quantity -= 1
                            }
                        }) {
                            Image(systemName: "minus").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                                .frame(width: 24, height: 24).background(Color.white.opacity(0.1)).cornerRadius(6)
                        }
                        Text("\(item.quantity)").font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                        Button(action: {
                            if let index = cart.items.firstIndex(where: { $0.id == item.id }) {
                                cart.items[index].quantity += 1
                            }
                        }) {
                            Image(systemName: "plus").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                                .frame(width: 24, height: 24).background(Color.white.opacity(0.1)).cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}

// MARK: - Summary Row

struct SummaryRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title).font(.custom("Tajawal-Regular", size: 14)).foregroundColor(Color.white.opacity(0.6))
            Spacer()
            Text(value).font(.custom("Tajawal-Medium", size: 14)).foregroundColor(.white)
        }
    }
}

// MARK: - Checkout Success View

struct CheckoutSuccessView: View {
    let orderId: String?
    let onDismissAll: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isAnimating = false
    @State private var showOrders = false

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle().fill(AuthColors.primaryPurple.opacity(0.2)).frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 1.0).opacity(isAnimating ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    Circle().fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark").font(.system(size: 40, weight: .bold)).foregroundColor(.white)
                }

                VStack(spacing: 12) {
                    Text("تم استلام طلبك بنجاح! 🎉")
                        .font(.custom("Tajawal-Bold", size: 24)).foregroundColor(.white)
                    Text(orderId != nil
                         ? "شكراً لتسوقك معنا. رقم طلبك #\(orderId!.prefix(8)). سنقوم بتجهيزه وشحنه في أقرب وقت ممكن."
                         : "شكراً لتسوقك معنا. سنقوم بتجهيز طلبك وشحنه في أقرب وقت ممكن.")
                        .font(.custom("Tajawal-Regular", size: 15))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center).lineSpacing(6).padding(.horizontal, 30)
                }

                Spacer()

                VStack(spacing: 16) {
                    Button(action: { showOrders = true }) {
                        Text("تتبع الطلب")
                            .font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                    }
                    Button(action: onDismissAll) {
                        Text("العودة للمتجر")
                            .font(.custom("Tajawal-Bold", size: 17)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 40)
            }
        }
        .onAppear { isAnimating = true }
        .fullScreenCover(isPresented: $showOrders) { OrdersView() }
    }
}

// MARK: - Orders View

struct OrdersView: View {
    @Environment(\.dismiss) var dismiss
    @State private var orders: [GlowFitAPI.OrderData] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) { GlowHeaderButton(systemImage: "chevron.right") }
                    Spacer()
                    Text("طلباتي 📦").font(.custom("Tajawal-Bold", size: 20)).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 20)

                if isLoading {
                    Spacer(); ProgressView().tint(.white); Spacer()
                } else if orders.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("📦").font(.system(size: 44))
                        Text("لسا ما عندك طلبات").font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(orders) { order in OrderCard(order: order) }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 40)
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            GlowFitAPI.getMyOrders { fetched in
                orders = fetched
                isLoading = false
            }
        }
    }
}

// MARK: - Order Card

struct OrderCard: View {
    let order: GlowFitAPI.OrderData
    var status: OrderStatus { OrderStatus(rawValue: order.status ?? "pending") ?? .pending }
    var items: [GlowFitAPI.OrderItemData] { order.order_items ?? [] }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("طلب #\(order.id.prefix(8))")
                        .font(.custom("Tajawal-Bold", size: 16)).foregroundColor(.white)
                    Text(GlowFitAPI.humanRelativeDate(order.created_at))
                        .font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
                }
                Spacer()
                Text(status.label)
                    .font(.custom("Tajawal-Bold", size: 12)).foregroundColor(status.color)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(status.color.opacity(0.1)).cornerRadius(8)
            }

            Divider().background(Color.white.opacity(0.1))

            HStack(spacing: 12) {
                ForEach(Array(items.prefix(3).enumerated()), id: \.offset) { _, item in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.1), AuthColors.primaryPink.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                        Text(GlowFitAPI.iconFor(category: item.products?.category)).font(.system(size: 24))
                    }
                }
                if items.count > 3 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)).frame(width: 50, height: 50)
                        Text("+\(items.count - 3)").font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("الإجمالي").font(.custom("Tajawal-Regular", size: 12)).foregroundColor(Color.white.opacity(0.4))
                    Text("\(Int(order.total_price ?? 0)) ر.س").font(.custom("Tajawal-Bold", size: 15)).foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
