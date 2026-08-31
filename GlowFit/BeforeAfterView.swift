import SwiftUI

struct BeforeAfterView: View {
    @State private var sliderOffset: CGFloat = 0.5
    @State private var selectedWeek = 0
    @GestureState private var isDragging = false
    @Environment(\.dismiss) var dismiss

    let weeks = ["الأسبوع الحالي","أسبوع 5","أسبوع 4","أسبوع 3","أسبوع 2","أسبوع 1"]
    let improvements: [(icon:String,label:String,before:Int,after:Int,color:Color)] = [
        ("💧","الترطيب",       72, 92, Color(red:0.29,green:0.77,blue:0.50)),
        ("👁","الهالات السوداء",50, 34, Color(red:0.98,green:0.75,blue:0.14)),
        ("🔴","حب الشباب",     28, 12, Color(red:0.97,green:0.44,blue:0.44)),
        ("〰️","الخطوط الدقيقة",22, 18, Color(red:0.38,green:0.65,blue:0.98)),
    ]

    var body: some View {
        AccountSheet(title: "مقارنة قبل / بعد") {

            // Week picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(weeks.indices, id:\.self) { i in
                        Button(action:{ withAnimation { selectedWeek = i } }) {
                            Text(weeks[i])
                                .font(.custom("Tajawal-Medium",size:13))
                                .foregroundColor(selectedWeek==i ? .white : Color.white.opacity(0.4))
                                .padding(.horizontal,14).padding(.vertical,8)
                                .background(selectedWeek==i
                                    ? LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.leading,endPoint:.trailing)
                                    : LinearGradient(colors:[Color.white.opacity(0.06)],startPoint:.leading,endPoint:.trailing))
                                .cornerRadius(10)
                        }
                    }
                }
            }

            // Face comparison slider
            GeometryReader { geo in
                let w = geo.size.width
                let h = w * 1.2
                ZStack {
                    // BEFORE (right side - older scan)
                    ZStack {
                        LinearGradient(colors:[Color(red:0.15,green:0.1,blue:0.2), Color(red:0.2,green:0.1,blue:0.25)], startPoint:.topLeading, endPoint:.bottomTrailing)
                        VStack(spacing:12) {
                            Text("👩🏻").font(.system(size:80))
                            // Simulated "before" indicators
                            HStack(spacing:6) {
                                Circle().fill(Color.red.opacity(0.7)).frame(width:8,height:8)
                                Circle().fill(Color.red.opacity(0.5)).frame(width:6,height:6)
                                Circle().fill(Color.orange.opacity(0.6)).frame(width:7,height:7)
                            }
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Text("قبل")
                                    .font(.custom("Tajawal-Bold",size:14)).foregroundColor(.white)
                                    .padding(.horizontal,12).padding(.vertical,6)
                                    .background(Color.black.opacity(0.5)).cornerRadius(8)
                                    .padding(14)
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                Text("72 / 100")
                                    .font(.custom("Tajawal-Bold",size:16))
                                    .foregroundColor(Color(red:0.97,green:0.44,blue:0.44))
                                    .padding(.horizontal,12).padding(.vertical,6)
                                    .background(Color.black.opacity(0.5)).cornerRadius(8)
                                    .padding(14)
                            }
                        }
                    }
                    .frame(width: w, height: h)
                    .cornerRadius(20)
                    .clipped()

                    // AFTER (left side - current)
                    ZStack {
                        LinearGradient(colors:[Color(red:0.1,green:0.08,blue:0.18), Color(red:0.15,green:0.08,blue:0.22)], startPoint:.topLeading, endPoint:.bottomTrailing)
                        VStack(spacing:12) {
                            Text("👩🏻").font(.system(size:80))
                            // Simulated "after" glow
                            HStack(spacing:6) {
                                Circle().fill(Color.green.opacity(0.4)).frame(width:4,height:4)
                            }
                        }
                        // Glow effect
                        Circle().fill(AuthColors.primaryPurple.opacity(0.15)).frame(width:160,height:160).blur(radius:30)
                        VStack {
                            HStack {
                                Text("بعد")
                                    .font(.custom("Tajawal-Bold",size:14)).foregroundColor(.white)
                                    .padding(.horizontal,12).padding(.vertical,6)
                                    .background(Color.black.opacity(0.5)).cornerRadius(8)
                                    .padding(14)
                                Spacer()
                            }
                            Spacer()
                            HStack {
                                Text("87 / 100")
                                    .font(.custom("Tajawal-Bold",size:16))
                                    .foregroundColor(Color(red:0.29,green:0.77,blue:0.50))
                                    .padding(.horizontal,12).padding(.vertical,6)
                                    .background(Color.black.opacity(0.5)).cornerRadius(8)
                                    .padding(14)
                                Spacer()
                            }
                        }
                    }
                    .frame(width: w * sliderOffset, height: h)
                    .clipped()
                    .frame(width: w, alignment: .leading)

                    // Divider line
                    Rectangle().fill(.white).frame(width:2, height:h)
                        .offset(x: w * sliderOffset - w/2)
                    // Handle
                    ZStack {
                        Circle().fill(.white).frame(width:36,height:36)
                            .shadow(color:.black.opacity(0.3),radius:6)
                        HStack(spacing:3) {
                            Image(systemName:"chevron.left").font(.system(size:11,weight:.bold)).foregroundColor(AuthColors.primaryPurple)
                            Image(systemName:"chevron.right").font(.system(size:11,weight:.bold)).foregroundColor(AuthColors.primaryPurple)
                        }
                    }
                    .offset(x: w * sliderOffset - w/2)
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                let newX = (val.location.x) / w
                                sliderOffset = min(max(newX, 0.05), 0.95)
                            }
                    )
                }
                .frame(width: w, height: h)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius:20).stroke(Color.white.opacity(0.1),lineWidth:1))
            }
            .frame(height: UIScreen.main.bounds.width * 0.85)
            .padding(.horizontal, -4)

            Text("اسحبي المقبض يميناً أو يساراً للمقارنة")
                .font(.custom("Tajawal-Regular",size:12)).foregroundColor(Color.white.opacity(0.4))
                .frame(maxWidth:.infinity).multilineTextAlignment(.center)

            // Metrics comparison
            VStack(alignment:.leading,spacing:12) {
                Text("مقارنة المقاييس").font(.custom("Tajawal-Bold",size:15)).foregroundColor(.white)
                ForEach(improvements, id:\.label) { item in
                    ImprovementRow(icon:item.icon, label:item.label, before:item.before, after:item.after, color:item.color)
                }
            }
        }
    }
}

struct ImprovementRow: View {
    let icon: String; let label: String; let before: Int; let after: Int; let color: Color
    var diff: Int { after - before }
    var isImproved: Bool { label == "الترطيب" ? diff > 0 : diff < 0 }

    var body: some View {
        VStack(spacing:8) {
            HStack {
                Text(icon).font(.system(size:16))
                Text(label).font(.custom("Tajawal-Medium",size:14)).foregroundColor(.white)
                Spacer()
                HStack(spacing:4) {
                    Image(systemName: isImproved ? "arrow.up.right" : "arrow.down.right").font(.system(size:11))
                    Text(isImproved ? "تحسن \(abs(diff))%" : "ارتفع \(abs(diff))%").font(.custom("Tajawal-Bold",size:12))
                }
                .foregroundColor(isImproved ? Color(red:0.29,green:0.77,blue:0.50) : Color(red:0.97,green:0.44,blue:0.44))
                .padding(.horizontal,8).padding(.vertical,4).background((isImproved ? Color(red:0.29,green:0.77,blue:0.50) : Color(red:0.97,green:0.44,blue:0.44)).opacity(0.1)).cornerRadius(6)
            }
            GeometryReader { geo in
                ZStack(alignment:.leading) {
                    // Before bar
                    RoundedRectangle(cornerRadius:4).fill(Color.white.opacity(0.06)).frame(height:6)
                    // After bar
                    RoundedRectangle(cornerRadius:4).fill(color)
                        .frame(width: geo.size.width * CGFloat(after)/100, height:6)
                    // Before marker
                    RoundedRectangle(cornerRadius:2).fill(Color.white.opacity(0.3))
                        .frame(width:2, height:12)
                        .offset(x: geo.size.width * CGFloat(before)/100 - 1)
                }
            }
            .frame(height:12)
            HStack {
                Text("قبل: \(before)%").font(.custom("Tajawal-Regular",size:11)).foregroundColor(Color.white.opacity(0.35))
                Spacer()
                Text("بعد: \(after)%").font(.custom("Tajawal-Bold",size:11)).foregroundColor(color)
            }
        }
        .padding(14).background(Color.white.opacity(0.03)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius:14).stroke(Color.white.opacity(0.06),lineWidth:1))
    }
}

#Preview { BeforeAfterView() }
