import SwiftUI

struct LabeledTextFieldWithUITextView: View {
    let title: String
    let text: Binding<String>
    let lineLimit: Int
    let focusState: FocusState<ContentView.FocusedTextField?>.Binding
    let focusCase: ContentView.FocusedTextField
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: (@MainActor () -> Void)?
    let toolbarButtonActions: (
        title: @MainActor () -> Void,
        deadline: @MainActor () -> Void,
        notes: @MainActor ()-> Void
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .fontWeight(.semibold)
            RepresentedUITextViewWrapper(
                text: text,
                lineLimit: lineLimit,
                focusState: focusState,
                focusCase: focusCase,
                returnKeyType: returnKeyType,
                dismissKeyboardAfterCompletion: dismissKeyboardAfterCompletion,
                onReturnAction: onReturnAction,
                toolbarButtonActions: toolbarButtonActions
            )
            .padding(.top, 3)
            Rectangle()
                .frame(height: 1)
        }
        .onTapGesture {
            focusState.wrappedValue = focusCase
        }
    }
}

private struct RepresentedUITextViewWrapper: View {
    let text: Binding<String>
    let lineLimit: Int
    let focusState: FocusState<ContentView.FocusedTextField?>.Binding
    let focusCase: ContentView.FocusedTextField
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: (@MainActor () -> Void)?
    let toolbarButtonActions: (
        title: @MainActor () -> Void,
        deadline: @MainActor () -> Void,
        notes: @MainActor ()-> Void
    )

    var body: some View {
        TextField("", text: text, axis: .vertical)
            .lineLimit(lineLimit)
            .disabled(true)
            .foregroundStyle(.clear)
            .overlay {
                RepresentedUITextView(
                    text: text,
                    lineLimit: lineLimit,
                    returnKeyType: returnKeyType,
                    dismissKeyboardAfterCompletion: dismissKeyboardAfterCompletion,
                    onReturnAction: onReturnAction,
                    toolbarButtonActions: toolbarButtonActions
                )
                .focused(focusState, equals: focusCase)
            }
    }
}

private struct RepresentedUITextView: UIViewRepresentable {
    let text: Binding<String>
    let lineLimit: Int
    let returnKeyType: UIReturnKeyType
    let dismissKeyboardAfterCompletion: Bool
    let onReturnAction: (@MainActor () -> Void)?
    let toolbarButtonActions: (
        title: @MainActor () -> Void,
        deadline: @MainActor () -> Void,
        notes: @MainActor ()-> Void
    )

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.returnKeyType = returnKeyType
        textView.backgroundColor = .clear
        textView.enablesReturnKeyAutomatically = true
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
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
        textView.inputAccessoryView = toolbar
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text.wrappedValue {
            uiView.text = text.wrappedValue
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: text,
            lineLimit: lineLimit,
            dismissKeyboardAfterCompletion: dismissKeyboardAfterCompletion,
            onReturnAction: onReturnAction
        )
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let text: Binding<String>
        let lineLimit: Int
        let dismissKeyboardAfterCompletion: Bool
        let onReturnAction: (@MainActor () -> Void)?

        init(
            text: Binding<String>,
            lineLimit: Int,
            dismissKeyboardAfterCompletion: Bool,
            onReturnAction: (() -> Void)?
        ) {
            self.text = text
            self.lineLimit = lineLimit
            self.dismissKeyboardAfterCompletion = dismissKeyboardAfterCompletion
            self.onReturnAction = onReturnAction
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            self.text.wrappedValue = textView.text ?? "" // これ必要だっけ？
            if text == "\n" { // リターンキーが押されたかをチェック
                if let onReturnAction {
                    onReturnAction()
                    if dismissKeyboardAfterCompletion {
                        textView.resignFirstResponder()
                    }
                    return false // リターンキーの入力をテキストビューに反映させない
                } else {
                    return true
                }
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text ?? ""
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            self.text.wrappedValue = textView.text ?? ""
        }
    }
}

private extension RepresentedUITextView.Coordinator {
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

private let labeledTextFieldSample = LabeledTextFieldWithUITextView(
    title: "期限",
    text: Binding.constant("明日の夜"),
    lineLimit: 1,
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
