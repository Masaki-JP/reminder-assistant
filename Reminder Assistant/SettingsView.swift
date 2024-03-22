import SwiftUI

struct SettingsView: View {
    @AppStorage("autoFocus") private var autoFocus = false
    @AppStorage("destinationListID") private var destinationListID = ""
    private let lists: [(name: String, id: String)]?
    @Environment(\.dismiss) private var dismiss

    private let defaultList: String?
    private let reminderCreateManager = ReminderCreateManager()

    init() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.defaultList = "リストC"
            self.lists = [("リストA", "list-a"), ("リストB", "list-b"), ("リストC", "list-c"), ("リストD", "list-d"), ("リストE", "list-e"),
            ]
        } else {
            self.defaultList = try? reminderCreateManager.getDefaultList().title
            self.lists = try? reminderCreateManager.getExistingLists().map { ($0.title, $0.calendarIdentifier) }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                reminderSection
                keyboardSection
            }
            .navigationTitle("Reminder Assistant Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "x.circle", action: dismiss.callAsFunction)
                }
            }
        }
    }

    @ViewBuilder
    var reminderSection: some View {
        if let defaultList, let lists {
            Section {
                Picker("作成先", selection: $destinationListID) {
                    Text("デフォルトリスト")
                        .tag("")
                    ForEach(lists, id: \.id) { list in
                        Text(list.name)
                            .tag(list.id)
                    }
                }
            } header: {
                Text("リマインダー")
            } footer: {
                Text("現在のデフォルトリストは\(Text(defaultList).bold())に設定されています。")
            }
            .onAppear {
                if lists.contains(where: { $0.id == destinationListID }) == false {
                    destinationListID.removeAll()
                }
            }
        } else {
            Section {
                Text("予期せぬエラーが発生しました。")
            } header: {
                Text("リマインダー")
            }
        }
    }

    var keyboardSection: some View {
        Section {
            Toggle("自動表示", isOn: $autoFocus)
        } header: {
            Text("キーボード")
        } footer: {
            Text("リマインダーの作成画面が表示されたときに、入力フォームに自動でフォーカスします。")
        }
    }
}

private struct SettingsViewWrapper: View {
    @State private var isShowSettingView = true

    var body: some View {
        Button("Show SettingsView") {
            isShowSettingView = true
        }
        .sheet(isPresented: $isShowSettingView) {
            SettingsView()
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    SettingsViewWrapper()
}
