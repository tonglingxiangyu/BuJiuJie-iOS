import SwiftUI
import UIKit

private struct DraftOption: Identifiable {
    let id = UUID()
    var text: String
}

struct QuickPickView: View {
    @EnvironmentObject private var store: DecisionStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var options = [DraftOption(text: ""), DraftOption(text: "")]
    @State private var displayedChoice: String?
    @State private var isChoosing = false
    @FocusState private var focusedOption: UUID?

    private var validOptions: [String] {
        options
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        Form {
            Section("这次要决定") {
                TextField("例如：今晚吃什么？", text: $title)
                    .submitLabel(.done)
            }

            Section {
                ForEach($options) { $option in
                    HStack(spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(AppPalette.primary)
                        TextField("候选项", text: $option.text)
                            .focused($focusedOption, equals: option.id)
                            .submitLabel(.done)
                    }
                }
                .onDelete(perform: deleteOptions)

                if options.count < 10 {
                    Button {
                        let newOption = DraftOption(text: "")
                        options.append(newOption)
                        focusedOption = newOption.id
                    } label: {
                        Label("添加候选项", systemImage: "plus.circle.fill")
                    }
                }
            } header: {
                Text("候选项")
            } footer: {
                Text("至少填写 2 项，最多 10 项。向左滑动可删除。")
            }

            Section {
                Button(action: choose) {
                    HStack {
                        Spacer()
                        if isChoosing {
                            ProgressView()
                                .tint(.white)
                            Text("正在听宇宙的……")
                        } else {
                            Image(systemName: "wand.and.stars")
                            Text("替我决定")
                        }
                        Spacer()
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 7)
                }
                .listRowBackground(AppPalette.primary)
                .disabled(validOptions.count < 2 || isChoosing)
                .opacity(validOptions.count < 2 ? 0.5 : 1)
            }

            if let displayedChoice {
                Section {
                    ResultCard(
                        eyebrow: isChoosing ? "候选中" : "就选这个",
                        result: displayedChoice,
                        symbol: isChoosing ? "shuffle" : "checkmark.seal.fill",
                        color: AppPalette.secondary
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                    if !isChoosing {
                        Button("好，就这么定了") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppPalette.background)
        .navigationTitle("快速替我选")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") { focusedOption = nil }
            }
        }
    }

    private func deleteOptions(at offsets: IndexSet) {
        guard options.count - offsets.count >= 2 else { return }
        options.remove(atOffsets: offsets)
    }

    private func choose() {
        let candidates = validOptions
        guard candidates.count >= 2 else { return }

        focusedOption = nil
        isChoosing = true
        displayedChoice = nil

        Task { @MainActor in
            for step in 0..<13 {
                displayedChoice = candidates.randomElement()
                let delay = UInt64(55_000_000 + step * 10_000_000)
                try? await Task.sleep(nanoseconds: delay)
            }

            let finalChoice = candidates.randomElement() ?? candidates[0]
            displayedChoice = finalChoice
            isChoosing = false

            UINotificationFeedbackGenerator().notificationOccurred(.success)
            store.add(
                DecisionRecord(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? "快速选择"
                        : title.trimmingCharacters(in: .whitespacesAndNewlines),
                    options: candidates,
                    result: finalChoice,
                    method: .quick
                )
            )
        }
    }
}

