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
                LabeledTextField(labelText: "名前", text: $title, foregroundColor: foregroundColor, backgroundColor: backgroundColor, focus: $focus, focusStateValue: .title)
                    .padding(.top)
                LabeledTextField(labelText: "期限", text: $deadline, foregroundColor: foregroundColor, backgroundColor: backgroundColor, focus: $focus, focusStateValue: .deadline)
                    .padding(.top, 25)
                LabeledTextField(labelText: "注釈", axix: .vertical, lineLimit: 4, text: $notes, foregroundColor: foregroundColor, backgroundColor: backgroundColor, focus: $focus, focusStateValue: .notes)
                    .padding(.top, 25)
                ReminderCreateButton(text: "リマインダー作成", color: foregroundColor) {
                    focus = nil
                }
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
}

enum Focus {
    case title
    case deadline
    case notes
}

struct LabeledTextField: View {
    let labelText: String
    var axix = Axis.horizontal
    var lineLimit = 1

    @Binding var text: String

    var foregroundColor: Color
    var backgroundColor: Color

    var focus: FocusState<Focus?>.Binding
    var focusStateValue: Focus

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(labelText)
                .frame(alignment: .leading)
                .background(backgroundColor)
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor)
                .padding(.leading, 1)
                .padding(.bottom, 4)
                .onTapGesture {
                    guard focus.wrappedValue != focusStateValue else { return }
                    focus.wrappedValue = focusStateValue
                }
            TextField("", text: $text, axis: axix)
                .lineLimit(lineLimit)
                .frame(alignment: .leading)
                .padding(.leading, 2)
                .focused(focus, equals: focusStateValue)
            RoundedRectangle(cornerRadius: 1)
                .foregroundStyle(foregroundColor)
                .frame(height: 1)
                .padding(.top, 3)
                .onTapGesture {
                    guard focus.wrappedValue != focusStateValue else { return }
                    focus.wrappedValue = focusStateValue
                }
        }
    }
}

struct ReminderCreateButton: View {
    let text: String
    let color: Color
    let action: @MainActor () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
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
