import SwiftUI
import JapaneseDateConverter

struct ContentView: View {
    @State private var title = ""
    @State private var deadline = ""
    @State private var notes = ""
    @FocusState private var focus: FocusedTextField?
    @State private var floatingAlertInformation: FloatingAlert.Information?
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("destinationListID") private var destinationListID = ""
    private let reminderCreateManager = ReminderCreateManager()
    private let japaneseDateConverter = JapaneseDateConverter()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("autoFocus") private var autoFocus = false
    @State private var isShowSettingsView = false
    @State private var isShowAccessFailureAlert = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    headerText
                        .padding(.top, focus == nil ? 30 : 0)
                    if focus == nil { Spacer() }
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        resizableImage
                            .frame(
                                width: focus == nil ? 230 : 0,
                                height: focus == nil ? 230 : 0
                            )
                    } else {
                        resizableImage
                            .frame(
                                width: focus == nil ? 280 : 0,
                                height: focus == nil ? 280 : 0
                            )
                    }
                    if focus == nil { Spacer() }
                    titleTextField
                        .padding(.top, focus == nil ? 3 : 15)
                    deadlineTextField
                        .padding(.top, 25)
                    noteTextField
                        .padding(.top, 25)
                    if focus == nil { Spacer() }
                    reminderCreateButton
                        .padding(.top, 25)
                    if focus == nil { Spacer(); Spacer(); }
                }
                .padding(.horizontal, 30)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .scrollDisabled(focus == nil)
        .scrollIndicators(.hidden)
        .background(backgroundColor)
        .safeAreaInset(edge: .bottom) {
            if focus == nil {
                Button("Show App Settings") {
                    isShowSettingsView = true
                }
                .foregroundColor(.secondary)
            }
        }
        .overlay {
            floatingAlert
        }
        .sheet(isPresented: $isShowSettingsView) {
            SettingsView()
                .presentationDetents([.medium])
        }
        .task {
            do {
                try await reminderCreateManager.requestFullAccessToReminders()
            } catch {
                print(error)
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue != .active else { return }
            isShowSettingsView = false
            floatingAlertInformation = nil
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            if autoFocus == true { focus = .title }
        }
        .animation(.easeInOut, value: focus)
        .alert("リマインダーへのアクセスが許可されていません。", isPresented: $isShowAccessFailureAlert) {
            Button("設定を開く") {
                guard let url = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url)
            }
        }
    }

    enum FocusedTextField {
        case title, deadline, notes
    }

    private enum JapaneseDateConverterError: Error { case failed }

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
        LabeledTextFieldWithUITextView(
            title: "名前",
            text: $title,
            lineLimit: 2,
            focusState: $focus,
            focusCase: .title,
            returnKeyType: .next,
            dismissKeyboardAfterCompletion: false,
            onReturnAction: { focus = .deadline },
            toolbarButtonActions: (
                title: { focus = .title },
                deadline: { focus = .deadline },
                notes: { focus = .notes }
            )
        )
        .foregroundStyle(foregroundColor)
    }

    var deadlineTextField: some View {
        LabeledTextFieldWithUITextView(
            title: "期限",
            text: $deadline,
            lineLimit: 2,
            focusState: $focus,
            focusCase: .deadline,
            returnKeyType: .done,
            dismissKeyboardAfterCompletion: true,
            onReturnAction: { createReminder() },
            toolbarButtonActions: (
                title: { focus = .title },
                deadline: { focus = .deadline },
                notes: { focus = .notes }
            )
        )
        .foregroundStyle(foregroundColor)
    }

    var noteTextField: some View {
        LabeledTextFieldWithUITextView(
            title: "備考",
            text: $notes,
            lineLimit: 5,
            focusState: $focus,
            focusCase: .notes,
            returnKeyType: .default,
            dismissKeyboardAfterCompletion: false,
            onReturnAction: nil,
            toolbarButtonActions: (
                title: { focus = .title },
                deadline: { focus = .deadline },
                notes: { focus = .notes }
            )
        )
        .foregroundStyle(foregroundColor)
    }

    var reminderCreateButton: some View {
        Button {
            createReminder()
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

    @ViewBuilder
    var floatingAlert: some View {
        if let info = floatingAlertInformation {
            Color(colorScheme == .light ? .gray : .black).opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    didTapFloatingAlertBackgroundAction()
                }
            FloatingAlert(info)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
        }
    }

    @ToolbarContentBuilder
    var completionButton: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            HStack(spacing: 0) {
                Spacer()
                Text("完了")
                    .bold()
                    .foregroundStyle(Color.accentColor)
                    .onTapGesture {
                        focus = nil
                    }

            }
            .padding(0)
        }
    }

    func createReminder() {
        withAnimation(.easeOut(duration: 0.25)) {
            do {
                focus = nil
                guard let deadlineDate = japaneseDateConverter.convert(from: deadline)
                else { throw JapaneseDateConverterError.failed }
                try reminderCreateManager.create(title: title, deadline: deadlineDate, notes: notes, destinationListID: destinationListID )
                floatingAlertInformation = .init(
                    title: "Success!!",
                    description: "\(title)\n(\(deadlineDate))",
                    descriptionAlignment: .center,
                    imageName: "hand.thumbsup.fill",
                    imageColor: foregroundColor
                )
                Task { @MainActor in // Issue #26
                    title.removeAll(); deadline.removeAll(); notes.removeAll();
                }
            } catch {
                handleError(error)
            }
        }
    }

    private let onUnexpectedErrorOccurredFloatingAlertInfomation = FloatingAlert.Information(
        title: "Error!!",
        description: "実行中に予期せぬエラーが発生しました。",
        descriptionAlignment: .leading,
        imageName: "exclamationmark.triangle.fill",
        imageColor: .yellow
    )

    func handleError(_ error: Error) {
        if case ReminderCreateManagerError.authorizationStatusIsNotFullAccess = error {
            isShowAccessFailureAlert = true; return;
        }

        floatingAlertInformation = if error is JapaneseDateConverterError {
            .init(
                title: "Error!!",
                description: "リマインダーの作成に失敗しました。期限の記述をご確認ください。",
                descriptionAlignment: .leading,
                imageName: "exclamationmark.triangle.fill",
                imageColor: .yellow
            )
        } else if let error = error as? ReminderCreateManagerError {
            switch error {
            case .specifiedListIsNotFound:
                    .init(
                        title: "Error!!",
                        description: "リマインダーの作成先に設定されているリストが見つかりませんでした。設定画面から再度設定してください。",
                        descriptionAlignment: .leading,
                        imageName: "exclamationmark.triangle.fill",
                        imageColor: .yellow
                    )
            case .getDefaultListFailed:
                    .init(
                        title: "Error!!",
                        description: "デフォルトリストの取得に失敗しました。",
                        descriptionAlignment: .leading,
                        imageName: "exclamationmark.triangle.fill",
                        imageColor: .yellow
                    )
            case .authorizationStatusIsNotFullAccess, .requestFullAccessFailed, .createFailed, .multipleListsWithSameIDFound:
                onUnexpectedErrorOccurredFloatingAlertInfomation
            }
        } else {
            onUnexpectedErrorOccurredFloatingAlertInfomation
        }
    }

    func didTapFloatingAlertBackgroundAction() {
        withAnimation(.easeIn(duration: 0.25)) {
            floatingAlertInformation = nil
        }
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
