import SwiftUI

struct LabeledTextField: View {
    let title: String
    let text: Binding<String>
    let focusState: FocusState<ContentView.FocusedTextField?>.Binding
    let focusCase: ContentView.FocusedTextField
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: @MainActor () -> Void
    let myAction1: @MainActor () -> Void
    let myAction2: @MainActor () -> Void
    let myAction3: @MainActor () -> Void

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
                onReturnAction: onReturnAction,
                myAction1: myAction1,
                myAction2: myAction2,
                myAction3: myAction3
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
    let myAction1: @MainActor () -> Void
    let myAction2: @MainActor () -> Void
    let myAction3: @MainActor () -> Void

    var body: some View {
        TextField("", text: text)
            .disabled(true)
            .foregroundStyle(.clear)
            .overlay {
                RepresentedUITextField(
                    text: text,
                    returnKeyType: returnKeyType,
                    dismissKeyboardAfterCompletion: dismissKeyboardAfterCompletion,
                    onReturnAction: onReturnAction,
                    myAction1: myAction1,
                    myAction2: myAction2,
                    myAction3: myAction3
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
    let myAction1: @MainActor () -> Void
    let myAction2: @MainActor () -> Void
    let myAction3: @MainActor () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.returnKeyType = returnKeyType
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = context.coordinator
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.items = [
            UIBarButtonItem(title: "↓", style: .done, target: context.coordinator, action: #selector(Coordinator.dismissKeyboard)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "list.bullet.clipboard"), style: .plain, target: context.coordinator, action: #selector(Coordinator._myAction1)),
            UIBarButtonItem(title: "名前", style: .plain, target: context.coordinator, action: #selector(Coordinator._myAction1)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "clock"), style: .plain, target: context.coordinator, action: #selector(Coordinator._myAction2)),
            UIBarButtonItem(title: "期限", style: .plain, target: context.coordinator, action: #selector(Coordinator._myAction2)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "note.text"), style: .plain, target: context.coordinator, action: #selector(Coordinator._myAction3)),
            UIBarButtonItem(title: "備考", style: .plain, target: context.coordinator, action: #selector(Coordinator._myAction3)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "↓", style: .done, target: context.coordinator, action: #selector(Coordinator.dismissKeyboard))
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
            onReturnAction: onReturnAction,
            myAction1: myAction1,
            myAction2: myAction2,
            myAction3: myAction3
        )
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let text: Binding<String>
        let dismissKeyboardAfterCompletion: Bool
        let onReturnAction: @MainActor () -> Void
        let myAction1: @MainActor () -> Void
        let myAction2: @MainActor () -> Void
        let myAction3: @MainActor () -> Void

        init(
            text: Binding<String>,
            dismissKeyboardAfterCompletion: Bool,
            onReturnAction: @escaping () -> Void,
            myAction1: @escaping @MainActor () -> Void,
            myAction2: @escaping @MainActor () -> Void,
            myAction3: @escaping @MainActor () -> Void
        ) {
            self.text = text
            self.dismissKeyboardAfterCompletion = dismissKeyboardAfterCompletion
            self.onReturnAction = onReturnAction
            self.myAction1 = myAction1
            self.myAction2 = myAction2
            self.myAction3 = myAction3
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

private extension RepresentedUITextField.Coordinator {
    @objc func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @objc func _myAction1() {
        self.myAction1()
    }

    @objc func _myAction2() {
        self.myAction2()
    }

    @objc func _myAction3() {
        self.myAction3()
    }
}


private let labeledTextFieldSample = LabeledTextField(
    title: "期限",
    text: Binding.constant("明日の夜"),
    focusState: FocusState<ContentView.FocusedTextField?>().projectedValue,
    focusCase: .title,
    returnKeyType: .default,
    dismissKeyboardAfterCompletion: false,
    onReturnAction: { print("onReturnAction") },
    myAction1: { print("myAction1") },
    myAction2: { print("myAction2") },
    myAction3: { print("myAction3") }
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
