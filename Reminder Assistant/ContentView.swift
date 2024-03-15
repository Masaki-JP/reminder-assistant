import SwiftUI

struct ContentView: View {
    @State private var title = ""
    @State private var deadline = ""
    @State private var notes = ""
    @FocusState private var focus: Focus?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerText
                    .padding(.top, 30)
                resizableImage
                    .frame(
                        width: focus == nil ? 230 : 0,
                        height: focus == nil ? 230 : 0
                    )
                    .padding()
                LabeledTextField(
                    title: "名前",
                    text: $title,
                    focusState: $focus,
                    focusCase: .title,
                    returnKeyType: .next,
                    dismissKeyboardAfterCompletion: false,
                    onReturnAction: { focus = .deadline }
                )
                .foregroundStyle(foregroundColor)
                LabeledTextField(
                    title: "期限",
                    text: $deadline,
                    focusState: $focus,
                    focusCase: .deadline,
                    returnKeyType: .done,
                    dismissKeyboardAfterCompletion: true,
                    onReturnAction: { print("リマインダー作成") }
                )
                .foregroundStyle(foregroundColor)
                .padding(.top, 25)
                LabeledMultipleTextField(
                    title: "注釈",
                    text: $notes,
                    lineLimit: 5,
                    focusState: $focus,
                    focusCase: .notes
                )
                .foregroundStyle(foregroundColor)
                .padding(.top, 25)
                reminderCreateButton
                    .padding(.top, 25)
            }
            .padding(.horizontal, 30)
        }
        .scrollDisabled(focus == nil)
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .safeAreaInset(edge: .bottom) {
            if focus == nil {
                Button("Show App Settings") {}
                    .foregroundColor(.secondary)
            }
        }
    }

    enum Focus {
        case title, deadline, notes
    }

    var headerText: some View {
        ViewThatFits(in: .horizontal) {
            ForEach(0..<15) { i in
                let size = 55 - CGFloat(i)
                Text("Let's Create Reminders.")
                    .foregroundColor(foregroundColor)
                    .font(.custom("SignPainter-HouseScript", size: size))
            }
        }
    }

    var resizableImage: some View {
        Image("ApplicationUsers")
            .resizable()
            .scaledToFit()
    }

    var foregroundColor: Color {
        colorScheme == .light ? .init(red: 64/255, green: 123/255, blue: 255/255) : .init(red: 64/255, green: 123/255, blue: 255/255)
    }

    var backgroundColor: Color {
        colorScheme == .light ? .white : .init(red: 0.05, green: 0.05, blue: 0.15)
    }

    var reminderCreateButton: some View {
        Button {
            focus = nil
        } label: {
            Text("リマインダー作成")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(foregroundColor)
    }
}

#Preview("Light") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
