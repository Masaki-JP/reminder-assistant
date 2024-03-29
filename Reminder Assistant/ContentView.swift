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
    @State private var isShowSettingView = false
    
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
                    .toolbar {
                        completionButton
                    }
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
                Button("Show App Settings") {
                    isShowSettingView = true
                }
                .foregroundColor(.secondary)
            }
        }
        .overlay {
            floatingAlert
        }
        .sheet(isPresented: $isShowSettingView) {
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
            isShowSettingView = false
            floatingAlertInformation = nil
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            if autoFocus == true { focus = .title }
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
            onReturnAction: createReminder
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
                title.removeAll(); deadline.removeAll(); notes.removeAll();
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
            case .authorizationStatusIsNotFullAccess:
                    .init(
                        title: "Error!!",
                        description: "リマインダーアプリへのアクセスが許可されていません。",
                        descriptionAlignment: .leading,
                        imageName: "exclamationmark.triangle.fill",
                        imageColor: .yellow
                    )
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
            case .requestFullAccessFailed, .createFailed, .multipleListsWithSameIDFound:
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
