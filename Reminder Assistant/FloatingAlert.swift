import SwiftUI

struct FloatingAlert: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let description: String
    let descriptionAlignment: TextAlignment
    let imageName: String
    let imageColor: Color

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
                borderdCircleImage(size: 60)
                    .padding(.top, -30)
            }
            .shadow(color: .clear, radius: 0)
            .frame(maxWidth: .infinity)
        }
        .shadow(color: colorScheme == .light ? .gray : .clear, radius: 3)
        .frame(width: 240)
        .padding(.top, 35)
    }

    struct Information {
        let title: String
        let description: String
        let descriptionAlignment: TextAlignment
        let imageName: String
        let imageColor: Color
    }

    init(_ information: Information) {
        self.title = information.title
        self.description = information.description
        self.descriptionAlignment = information.descriptionAlignment
        self.imageName = information.imageName
        self.imageColor = information.imageColor
    }

    var backgroundColor: Color {
        colorScheme == .light ? .white : .init(red: 0.125, green: 0.125, blue: 0.125)
    }

    var titleText: some View {
        Text(title)
            .font(.custom("Rockwell-Regular", size: 25))
            .lineLimit(1)
    }

    var descriptionText: some View {
        Text(description)
            .font(.callout)
            .multilineTextAlignment(descriptionAlignment)
    }

    @ViewBuilder
    func borderdCircleImage(size: CGFloat) -> some View {
        Circle()
            .foregroundStyle(imageColor)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .padding()
                Circle()
                    .stroke(backgroundColor, lineWidth: 5)
                    .frame(width: 60, height: 60)
            }
    }
}

private let floatingAlertSample = FloatingAlert(
    .init(
        title: "Success",
        description: "美容院の予約\n(2024年3月10日 21:00)",
        descriptionAlignment: .center,
        imageName: "hand.thumbsup.fill",
        imageColor: .blue
    )

//    .init(
//        title: "Error!!",
//        description: "リマインダーの作成に失敗しました。期限の記述をご確認ください。",
//        descriptionAlignment: .leading,
//        imageName: "exclamationmark.triangle.fill",
//        imageColor: .yellow
//    )

//    .init(
//        title: "Error!!",
//        description: "リマインダーアプリへのアクセスが許可されていません。",
//        descriptionAlignment: .leading,
//        imageName: "exclamationmark.triangle.fill",
//        imageColor: .yellow
//    )

//    .init(
//        title: "Error!!",
//        description: "リマインダーの作成先に設定されているリストが見つかりませんでした。設定画面から再度設定してください。",
//        descriptionAlignment: .leading,
//        imageName: "exclamationmark.triangle.fill",
//        imageColor: .yellow
//    )

//    .init(
//        title: "Error!!",
//        description: "デフォルトリストの取得に失敗しました。",
//        descriptionAlignment: .leading,
//        imageName: "exclamationmark.triangle.fill",
//        imageColor: .yellow
//    )

//    .init(
//        title: "Error!!",
//        description: "実行中に予期せぬエラーが発生しました。",
//        descriptionAlignment: .leading,
//        imageName: "exclamationmark.triangle.fill",
//        imageColor: .yellow
//    )
)


#Preview("Light") {
    floatingAlertSample
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    floatingAlertSample
        .preferredColorScheme(.dark)
}
