import SwiftUI

// MARK: - Models

struct CartItem: Identifiable {
    let id = UUID()
    let product: StoreProduct
    var quantity: Int
}

struct Order: Identifiable {
    let id = UUID()
    let orderNumber: String
    let date: String
    let total: String
    let status: OrderStatus
    let items: [StoreProduct]
    
    enum OrderStatus: String {
        case pending = "قيد المعالجة ⏳"
        case shipped = "تم الشحن 📦"
        case delivered = "تم التوصيل ✅"
        case cancelled = "ملغي ❌"
        
        var color: Color {
            switch self {
            case .pending: return Color(red: 0.98, green: 0.75, blue: 0.14)
            case .shipped: return Color.blue
            case .delivered: return Color(red: 0.29, green: 0.77, blue: 0.50)
            case .cancelled: return Color(red: 0.97, green: 0.44, blue: 0.44)
            }
        }
    }
}

// MARK: - Cart View

struct CartView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cartItems: [CartItem] = [
        CartItem(product: StoreProduct.sampleProducts[0], quantity: 1),
        CartItem(product: StoreProduct.sampleProducts[2], quantity: 2)
    ]
    @State private var showCheckout = false
    
    var subtotal: Double {
        cartItems.reduce(0) { total, item in
            // Extracting numbers from the string e.g. "٨٥ ر.س" -> 85
            let priceString = item.product.price.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let price = Double(priceString) ?? 0.0
            return total + (price * Double(item.quantity))
        }
    }
    
    var tax: Double { subtotal * 0.15 }
    var total: Double { subtotal + tax }
    
    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        GlowHeaderButton(systemImage: "chevron.right")
                    }
                    Spacer()
                    Text("سلة المشتريات 🛒")
                        .font(.custom("Tajawal-Bold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    // Empty space to balance the header
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                if cartItems.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(Color.white.opacity(0.2))
                        Text("السلة فارغة")
                            .font(.custom("Tajawal-Bold", size: 20))
                            .foregroundColor(.white)
                        Text("تصفحي المتجر واختاري المنتجات المناسبة لبشرتك")
                            .font(.custom("Tajawal-Regular", size: 14))
                            .foregroundColor(Color.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { dismiss() }) {
                            Text("العودة للمتجر")
                                .font(.custom("Tajawal-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 14)
                                .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(14)
                        }
                        .padding(.top, 20)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach($cartItems) { $item in
                                CartItemRow(item: $item) {
                                    if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                                        withAnimation {
                                            cartItems.remove(at: index)
                                        }
                                    }
                                }
                            }
                            
                            // Summary Card
                            VStack(spacing: 14) {
                                Text("ملخص الطلب")
                                    .font(.custom("Tajawal-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 4)
                                
                                SummaryRow(title: "المجموع الفرعي", value: "\(Int(subtotal)) ر.س")
                                SummaryRow(title: "الضريبة (15%)", value: "\(Int(tax)) ر.س")
                                SummaryRow(title: "التوصيل", value: "مجاني")
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.vertical, 8)
                                
                                HStack {
                                    Text("الإجمالي")
                                        .font(.custom("Tajawal-Bold", size: 18))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(total)) ر.س")
                                        .font(.system(size: 22, weight: .black))
                                        .foregroundStyle(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
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
                    
                    // Checkout Button
                    VStack {
                        Button(action: { showCheckout = true }) {
                            Text("إتمام الطلب")
                                .font(.custom("Tajawal-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(16)
                                .shadow(color: AuthColors.primaryPurple.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .padding(.top, 10)
                    }
                    .background(
                        ZStack {
                            Rectangle().fill(.ultraThinMaterial)
                            Color(red: 10/255, green: 10/255, blue: 15/255).opacity(0.9)
                        }
                        .ignoresSafeArea()
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showCheckout) {
            CheckoutSuccessView()
        }
    }
}

// MARK: - Cart Item Row

struct CartItemRow: View {
    @Binding var item: CartItem
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.15), AuthColors.primaryPink.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                Text(item.product.icon).font(.system(size: 38))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.product.brand)
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(Color.red.opacity(0.7))
                    }
                }
                
                Text(item.product.name)
                    .font(.custom("Tajawal-Bold", size: 15))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text(item.product.price)
                        .font(.custom("Tajawal-Bold", size: 14))
                        .foregroundColor(AuthColors.primaryPink)
                    
                    Spacer()
                    
                    // Stepper
                    HStack(spacing: 12) {
                        Button(action: { if item.quantity > 1 { item.quantity -= 1 } }) {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        Text("\(item.quantity)")
                            .font(.custom("Tajawal-Bold", size: 14))
                            .foregroundColor(.white)
                        
                        Button(action: { item.quantity += 1 }) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(6)
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
            Text(title)
                .font(.custom("Tajawal-Regular", size: 14))
                .foregroundColor(Color.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.custom("Tajawal-Medium", size: 14))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Checkout Success View

struct CheckoutSuccessView: View {
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
                    Circle()
                        .fill(AuthColors.primaryPurple.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text("تم استلام طلبك بنجاح! 🎉")
                        .font(.custom("Tajawal-Bold", size: 24))
                        .foregroundColor(.white)
                    
                    Text("شكراً لتسوقك معنا. رقم طلبك هو #GLOW-8472. سنقوم بتجهيزه وشحنه في أقرب وقت ممكن.")
                        .font(.custom("Tajawal-Regular", size: 15))
                        .foregroundColor(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: { showOrders = true }) {
                        Text("تتبع الطلب")
                            .font(.custom("Tajawal-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("العودة للمتجر")
                            .font(.custom("Tajawal-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isAnimating = true
        }
        .fullScreenCover(isPresented: $showOrders) {
            OrdersView()
        }
    }
}

// MARK: - Orders View

struct OrdersView: View {
    @Environment(\.dismiss) var dismiss
    
    let orders = [
        Order(orderNumber: "#GLOW-8472", date: "اليوم، 10:30 ص", total: "٢٥٥ ر.س", status: .pending, items: [StoreProduct.sampleProducts[0], StoreProduct.sampleProducts[2]]),
        Order(orderNumber: "#GLOW-7391", date: "١٥ مايو ٢٠٢٦", total: "١١٠ ر.س", status: .delivered, items: [StoreProduct.sampleProducts[1]]),
        Order(orderNumber: "#GLOW-6284", date: "٠٢ أبريل ٢٠٢٦", total: "١٣٥ ر.س", status: .delivered, items: [StoreProduct.sampleProducts[3]])
    ]
    
    var body: some View {
        ZStack {
            AuthColors.background.ignoresSafeArea()
            AuthBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        GlowHeaderButton(systemImage: "chevron.right")
                    }
                    Spacer()
                    Text("طلباتي 📦")
                        .font(.custom("Tajawal-Bold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(orders) { order in
                            OrderCard(order: order)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Order Card

struct OrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("طلب \(order.orderNumber)")
                        .font(.custom("Tajawal-Bold", size: 16))
                        .foregroundColor(.white)
                    Text(order.date)
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                Spacer()
                Text(order.status.rawValue)
                    .font(.custom("Tajawal-Bold", size: 12))
                    .foregroundColor(order.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(order.status.color.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Items Preview
            HStack(spacing: 12) {
                ForEach(order.items.prefix(3)) { item in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [AuthColors.primaryPurple.opacity(0.1), AuthColors.primaryPink.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                        Text(item.icon).font(.system(size: 24))
                    }
                }
                
                if order.items.count > 3 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 50, height: 50)
                        Text("+\(order.items.count - 3)")
                            .font(.custom("Tajawal-Bold", size: 14))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("الإجمالي")
                        .font(.custom("Tajawal-Regular", size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                    Text(order.total)
                        .font(.custom("Tajawal-Bold", size: 15))
                        .foregroundColor(.white)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {}) {
                    Text("تفاصيل الطلب")
                        .font(.custom("Tajawal-Bold", size: 13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                
                if order.status == .delivered {
                    Button(action: {}) {
                        Text("إعادة الطلب")
                            .font(.custom("Tajawal-Bold", size: 13))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(LinearGradient(colors: [AuthColors.primaryPurple, AuthColors.primaryPink], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
