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
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "完了", style: .done, target: context.coordinator, action: #selector(Coordinator.dismissKeyboard))
        ]
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
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
        let text: Binding<String>
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

        func textFieldDidEndEditing(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
        }
    }
}

extension RepresentedUITextField.Coordinator {
    @objc func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
