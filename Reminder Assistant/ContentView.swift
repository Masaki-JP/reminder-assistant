import SwiftUI

struct ContentView: View {
    @State private var title = ""
    @State private var deadline = ""
    @State private var notes = ""
    @FocusState private var focus: Focus?
    @State private var floatingAlertInformation: FloatingAlert.Information?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerText
                    .padding(.top, 30)
                resizableImage
                    .frame(width: focus == nil ? 230 : 0, height: focus == nil ? 230 : 0)
                    .padding()
                titleTextField
                    .padding(.top, 3)
                deadlineTextField
                    .padding(.top, 25)
                noteTextField
                    .padding(.top, 25)
                reminderCreateButton
                    .padding(.top, 25)
            }
            .padding(.horizontal, 30)
        }
        .scrollDisabled(focus == nil)
        .scrollIndicators(.hidden)
        .background(backgroundColor)
        .safeAreaInset(edge: .bottom) {
            if focus == nil {
                Button("Show App Settings") {}
                    .foregroundColor(.secondary)
            }
        }
        .overlay {
            if let info = floatingAlertInformation {
                Color(colorScheme == .light ? .gray : .black).opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        title.removeAll()
                        deadline.removeAll()
                        notes.removeAll()
                        withAnimation(.easeIn(duration: 0.25)) {
                            floatingAlertInformation = nil
                        }
                    }
                FloatingAlert(info)
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea()
                    .transition(.move(edge: .bottom))
            }
        }
    }

    enum Focus {
        case title, deadline, notes
    }

    var foregroundColor: Color {
        colorScheme == .light ? .init(red: 64/255, green: 123/255, blue: 255/255) : .init(red: 64/255, green: 123/255, blue: 255/255)
    }

    var backgroundColor: Color {
        colorScheme == .light ? .white : .init(red: 0.05, green: 0.05, blue: 0.15)
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

    var titleTextField: some View {
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
    }

    var deadlineTextField: some View {
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
    }

    var noteTextField: some View {
        LabeledMultipleTextField(
            title: "備考",
            text: $notes,
            lineLimit: 5,
            focusState: $focus,
            focusCase: .notes
        )
        .foregroundStyle(foregroundColor)
    }

    var reminderCreateButton: some View {
        Button {
            focus = nil
            withAnimation(.easeOut(duration: 0.25)) {
                floatingAlertInformation = .init(
                    title: "Success!!",
                    description: "アプリ道場サロン勉強会\n(2024年3月15日 20:00)",
                    descriptionAlignment: .center,
                    imageName: "swift",
                    imageColor: foregroundColor
                )
            }
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
