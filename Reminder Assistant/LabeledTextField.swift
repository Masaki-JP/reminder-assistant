import SwiftUI

struct LabeledTextField: View {
    let title: String
    let text: Binding<String>
    let focusState: FocusState<ContentView.FocusedTextField?>.Binding
    let focusCase: ContentView.FocusedTextField
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: @MainActor () -> Void
    let toolbarButtonActions: (
        title: @MainActor () -> Void,
        deadline: @MainActor () -> Void,
        notes: @MainActor ()-> Void
    )

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
                toolbarButtonActions: (
                    title: toolbarButtonActions.title,
                    deadline: toolbarButtonActions.deadline,
                    notes: toolbarButtonActions.notes
                )
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
    let toolbarButtonActions: (
        title: @MainActor () -> Void,
        deadline: @MainActor () -> Void,
        notes: @MainActor ()-> Void
    )

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
                    toolbarButtonActions: (
                        title: toolbarButtonActions.title,
                        deadline: toolbarButtonActions.deadline,
                        notes: toolbarButtonActions.notes
                    )
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
    let toolbarButtonActions: (
        title: @MainActor () -> Void,
        deadline: @MainActor () -> Void,
        notes: @MainActor ()-> Void
    )

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
            UIBarButtonItem(customView: KeyboardToolbarButton(icon: UIImage(systemName: "list.bullet.clipboard"), title: "名前", action: toolbarButtonActions.title)),
            UIBarButtonItem(title: "  -  ", style: .plain, target: nil, action: nil),
            UIBarButtonItem(customView: KeyboardToolbarButton(icon: UIImage(systemName: "clock"), title: "期限", action: toolbarButtonActions.deadline)),
            UIBarButtonItem(title: "  -  ", style: .plain, target: nil, action: nil),
            UIBarButtonItem(customView: KeyboardToolbarButton(icon: UIImage(systemName: "note.text"), title: "備考", action: toolbarButtonActions.notes)),
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
            toolbarButtonActions: (
                title: toolbarButtonActions.title,
                deadline: toolbarButtonActions.deadline,
                notes: toolbarButtonActions.notes
            )
        )
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let text: Binding<String>
        let dismissKeyboardAfterCompletion: Bool
        let onReturnAction: @MainActor () -> Void
        let toolbarButtonActions: (
            title: @MainActor () -> Void,
            deadline: @MainActor () -> Void,
            notes: @MainActor ()-> Void
        )

        init(
            text: Binding<String>,
            dismissKeyboardAfterCompletion: Bool,
            onReturnAction: @escaping () -> Void,
            toolbarButtonActions: (
                title: @MainActor () -> Void,
                deadline: @MainActor () -> Void,
                notes: @MainActor ()-> Void
            )
        ) {
            self.text = text
            self.dismissKeyboardAfterCompletion = dismissKeyboardAfterCompletion
            self.onReturnAction = onReturnAction
            self.toolbarButtonActions =  (
                title: toolbarButtonActions.title,
                deadline: toolbarButtonActions.deadline,
                notes: toolbarButtonActions.notes
            )
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
}

private class KeyboardToolbarButton: UIView {
    let iconImageView: UIImageView
    let titleLabel: UILabel
    let action: () -> Void

    init(icon: UIImage?, title: String, action: @escaping () -> Void) {
        self.iconImageView = UIImageView(image: icon)
        self.titleLabel = UILabel()
        self.action = action
        super.init(frame: .zero)

        setupView(icon: icon, title: title)
    }

    required init?(coder: NSCoder) { return nil }

    private func setupView(icon: UIImage?, title: String) {
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(.accentColor)

        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
        addGestureRecognizer(tapGesture)
    }

    @objc private func didTapButton() {
        action()
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
    toolbarButtonActions: (
        title: { print("toolbarButtonActions.title") },
        deadline: { print("toolbarButtonActions.deadline") },
        notes: { print("toolbarButtonActions.notes") }
    )
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
