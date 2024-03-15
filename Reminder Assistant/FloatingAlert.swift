import SwiftUI

struct FloatingAlert: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let description: String
    let descriptionAlignment: TextAlignment

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    titleText
                    descriptionText
                        .padding(.top, 5)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
                .padding(.top, 30) // Radius of borderdCircleImage
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .top) {
                borderdCircleImage(size: 60, borderColor: backgroundColor)
                    .padding(.top, -30)
            }
            .shadow(color: .clear, radius: 0)
            .frame(maxWidth: .infinity)
        }
        .shadow(color: colorScheme == .light ? .gray : .clear, radius: 3)
        .frame(width: 240)
        .padding(.top, 35)
    }

    struct Information: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let descriptionAlignment: TextAlignment
        let imageName: String
        let imageColor: Color
    }

    var titleText: some View {
        ViewThatFits(in: .horizontal) {
            ForEach(0..<10) { i in
                Text(title)
                    .font(.custom("Rockwell-Regular", size: 25 - CGFloat(i)))
                    .lineLimit(1)
            }
        }
    }

    init(title: String, description: String, descriptionAlignment: TextAlignment = .center) {
        self.title = title
        self.description = description
        self.descriptionAlignment = descriptionAlignment
    }

    var descriptionText: some View {
        Text(description)
            .multilineTextAlignment(descriptionAlignment)
    }

    var backgroundColor: Color {
        colorScheme == .light ? .white : .init(red: 0.125, green: 0.125, blue: 0.125)
    }

    @ViewBuilder
    func borderdCircleImage(size: CGFloat, borderColor: Color) -> some View {
        Circle()
            .foregroundStyle(.blue)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "hand.thumbsup.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .padding()
                Circle()
                    .stroke(borderColor, lineWidth: 5)
                    .frame(width: 60, height: 60)
            }
    }
}

#Preview("Light") {
    FloatingAlert(
        title: "Success!!",
        description: "美容院の予約\n(2024年3月10日 21:00)"
    )
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    FloatingAlert(
        title: "Success!!",
        description: "美容院の予約\n(2024年3月10日 21:00)"
    )
    .preferredColorScheme(.dark)
}
