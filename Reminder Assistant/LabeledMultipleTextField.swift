import SwiftUI

struct LabeledMultipleTextField: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let text: Binding<String>
    let lineLimit: Int
    let focusState: FocusState<ContentView.Focus?>.Binding
    let focusCase: ContentView.Focus

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
            TextField("", text: text, axis: .vertical)
                .focused(focusState, equals: focusCase)
                .lineLimit(lineLimit)
                .foregroundStyle(colorScheme == .light ? .black : .white)
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
        }
        .onTapGesture {
            focusState.wrappedValue = focusCase
        }
    }
}

private let labeledMultipleTextFieldSample = LabeledMultipleTextField(
    title: "期限",
    text: Binding.constant("明日の夜"),
    lineLimit: 5,
    focusState: FocusState<ContentView.Focus?>().projectedValue,
    focusCase: .title
)

#Preview("Light") {
    labeledMultipleTextFieldSample
        .preferredColorScheme(.light)
        .padding(.horizontal)
}

#Preview("Dark") {
    labeledMultipleTextFieldSample
        .preferredColorScheme(.dark)
        .padding(.horizontal)
}
