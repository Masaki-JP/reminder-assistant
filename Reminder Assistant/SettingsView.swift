import SwiftUI

struct SettingsView: View {
    @AppStorage("autoFocus") private var autoFocus = false
    @AppStorage("selectedList") private var selectedList = ""
    private let lists: [String] = ["リストA", "リストB", "リストC"]
    @Environment(\.dismiss) private var dismiss

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

    var reminderSection: some View {
        Section {
            Picker("作成先", selection: $selectedList) {
                ForEach(lists, id: \.self) { list in
                    Text(list)
                        .tag(list)
                }
            }
        } header: {
            Text("リマインダー")
        } footer: {
            Text("未設定の場合はデフォルトに設定されているリストに作成します。")
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
