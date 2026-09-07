import SwiftUI

struct ContactUsView: View {
    @State private var subject = ""
    @State private var message = ""
    @State private var selectedTopic = 0
    @State private var showSuccessAlert = false
    @State private var isSending = false
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) var dismiss

    let topics = ["استفسار عام", "مشكلة تقنية", "طلب استرداد", "اقتراح", "أخرى"]

    var body: some View {
        AccountSheet(title: "تواصل معنا") {

            // Contact channels
            HStack(spacing: 10) {
                ChannelCard(icon: "envelope.fill",    label: "البريد الإلكتروني", sub: "support@glowfit.ai", color: AuthColors.primaryPink) {
                    if let url = URL(string: "mailto:support@glowfit.ai") { UIApplication.shared.open(url) }
                }
                ChannelCard(icon: "message.fill",     label: "تواصل مباشر",      sub: "متاح 9ص–9م",       color: AuthColors.primaryPurple) { }
                ChannelCard(icon: "phone.fill",        label: "الدعم الهاتفي",    sub: "800-XXX-XXXX",      color: Color(red:0.23,green:0.65,blue:0.98)) {
                    if let url = URL(string: "tel:800XXXXXXX") { UIApplication.shared.open(url) }
                }
            }

            // Divider label
            HStack { Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1); Text("أو أرسلي رسالة").font(.custom("Tajawal-Regular",size:12)).foregroundColor(Color.white.opacity(0.3)).fixedSize(); Rectangle().fill(Color.white.opacity(0.06)).frame(height:1) }

            // Topic picker
            VStack(alignment: .leading, spacing: 8) {
                Text("موضوع الرسالة").font(.custom("Tajawal-Medium",size:13)).foregroundColor(Color.white.opacity(0.5))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(topics.indices, id:\.self) { i in
                            Button(action: { selectedTopic = i }) {
                                Text(topics[i])
                                    .font(.custom("Tajawal-Medium",size:13))
                                    .foregroundColor(selectedTopic==i ? .white : Color.white.opacity(0.5))
                                    .padding(.horizontal,14).padding(.vertical,8)
                                    .background(selectedTopic==i ? LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.leading,endPoint:.trailing) : LinearGradient(colors:[Color.white.opacity(0.05)],startPoint:.leading,endPoint:.trailing))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }

            // Subject
            EditField(label: "عنوان الرسالة", icon: "pencil", text: $subject)

            // Message
            VStack(alignment: .leading, spacing: 8) {
                Text("تفاصيل الرسالة").font(.custom("Tajawal-Medium",size:13)).foregroundColor(Color.white.opacity(0.5))
                ZStack(alignment:.topTrailing) {
                    TextEditor(text: $message)
                        .font(.custom("Tajawal-Regular",size:15))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120)
                        .padding(14)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius:14).stroke(Color.white.opacity(0.08),lineWidth:1))
                    if message.isEmpty {
                        Text("اكتبي رسالتك هنا...").font(.custom("Tajawal-Regular",size:15)).foregroundColor(Color.white.opacity(0.2)).padding(22)
                    }
                    Text("\(message.count)/500").font(.system(size:11)).foregroundColor(Color.white.opacity(0.3)).padding(10)
                }
            }

            // Send
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.custom("Tajawal-Medium", size: 13))
                    .foregroundColor(Color(red: 0.97, green: 0.44, blue: 0.44))
            }
            Button(action: sendMessage) {
                HStack(spacing:10) {
                    if isSending {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName:"paperplane.fill")
                        Text("إرسال الرسالة").font(.custom("Tajawal-Bold",size:17))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth:.infinity).padding(.vertical,16)
                .background(LinearGradient(colors:[AuthColors.primaryPurple,AuthColors.primaryPink],startPoint:.leading,endPoint:.trailing))
                .cornerRadius(14)
                .shadow(color:AuthColors.primaryPurple.opacity(0.3),radius:10,y:5)
            }
            .disabled(isSending || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            // Response time note
            HStack(spacing:6) {
                Image(systemName:"clock.fill").font(.system(size:12)).foregroundColor(AuthColors.primaryPurple)
                Text("سيتم الرد خلال 24 ساعة عمل").font(.custom("Tajawal-Regular",size:12)).foregroundColor(Color.white.opacity(0.4))
            }
            .frame(maxWidth:.infinity)
        }
        .alert("تم الإرسال ✅", isPresented: $showSuccessAlert) {
            Button("حسناً") { dismiss() }
        } message: {
            Text("تم إرسال رسالتك بنجاح. سيتواصل معك فريق الدعم خلال 24 ساعة.")
        }
    }

    private func sendMessage() {
        guard !isSending else { return }
        isSending = true
        errorMessage = nil
        let fullSubject = "\(topics[selectedTopic])\(subject.isEmpty ? "" : " — \(subject)")"
        GlowFitAPI.sendContactMessage(subject: fullSubject, message: message) { result in
            isSending = false
            switch result {
            case .success:
                showSuccessAlert = true
            case .failure(let msg):
                errorMessage = msg
            }
        }
    }
}

struct ChannelCard: View {
    let icon: String; let label: String; let sub: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(color.opacity(0.15)).frame(width:44,height:44)
                    Image(systemName:icon).font(.system(size:18)).foregroundColor(color)
                }
                Text(label).font(.custom("Tajawal-Bold",size:12)).foregroundColor(.white).multilineTextAlignment(.center)
                Text(sub).font(.custom("Tajawal-Regular",size:10)).foregroundColor(Color.white.opacity(0.4)).multilineTextAlignment(.center)
            }
            .frame(maxWidth:.infinity).padding(.vertical,16)
            .background(Color.white.opacity(0.03))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius:14).stroke(color.opacity(0.15),lineWidth:1))
        }
    }
}

#Preview { ContactUsView() }
