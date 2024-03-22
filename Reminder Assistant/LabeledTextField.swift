import SwiftUI

struct LabeledTextField: View {
    let title: String
    let text: Binding<String>
    let focusState: FocusState<ContentView.FocusedTextField?>.Binding
    let focusCase: ContentView.FocusedTextField
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .fontWeight(.semibold)
            RepresentedUITextFieldWrapper(
                text: text,
                focusState: focusState,
                focusCase: focusCase,
                returnKeyType: returnKeyType,
                dismissKeyboardAfterCompletion: dismissKeyboardAfterCompletion,
                onReturnAction: onReturnAction
            )
            .padding(.top, 3)
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
        }
        .onTapGesture {
            focusState.wrappedValue = focusCase
        }
    }
}

private struct RepresentedUITextFieldWrapper: View {
    let text: Binding<String>
    let focusState: FocusState<ContentView.FocusedTextField?>.Binding
    let focusCase: ContentView.FocusedTextField
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: @MainActor () -> Void

    var body: some View {
        TextField("", text: text)
            .disabled(true)
            .foregroundStyle(.clear)
            .overlay {
                RepresentedUITextField(
                    text: text,
                    returnKeyType: returnKeyType,
                    dismissKeyboardAfterCompletion: dismissKeyboardAfterCompletion,
                    onReturnAction: onReturnAction
                )
                .focused(focusState, equals: focusCase)
            }
    }
}

private struct RepresentedUITextField: UIViewRepresentable {
    let text: Binding<String>
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: @MainActor () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.returnKeyType = returnKeyType
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = context.coordinator
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text.wrappedValue
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: text,
            dismissKeyboardAfterCompletion: dismissKeyboardAfterCompletion,
            onReturnAction: onReturnAction
        )
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        let dismissKeyboardAfterCompletion: Bool
        let onReturnAction: @MainActor () -> Void

        init(
            text: Binding<String>,
            dismissKeyboardAfterCompletion: Bool,
            onReturnAction: @escaping () -> Void
        ) {
            self.text = text
            self.dismissKeyboardAfterCompletion = dismissKeyboardAfterCompletion
            self.onReturnAction = onReturnAction
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.text.wrappedValue = textField.text ?? ""
            onReturnAction()
            if dismissKeyboardAfterCompletion == true {
                textField.resignFirstResponder()
                return true
            } else {
                return false
            }
        }
    }
}

private let labeledTextFieldSample = LabeledTextField(
    title: "期限",
    text: Binding.constant("明日の夜"),
    focusState: FocusState<ContentView.FocusedTextField?>().projectedValue,
    focusCase: .title,
    returnKeyType: .default,
    dismissKeyboardAfterCompletion: false,
    onReturnAction: {}
)

#Preview("Light") {
    labeledTextFieldSample
        .preferredColorScheme(.light)
        .padding(.horizontal)
}

#Preview("Dark") {
    labeledTextFieldSample
        .preferredColorScheme(.dark)
        .padding(.horizontal)
}
