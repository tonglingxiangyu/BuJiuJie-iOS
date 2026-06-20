import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: DecisionStore
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if store.records.isEmpty {
                    EmptyStateView(
                        symbol: "tray",
                        title: "还没有决定记录",
                        message: "完成一次快速选择或理性比较后，结果会保存在这里。"
                    )
                } else {
                    List {
                        ForEach(store.records) { record in
                            recordRow(record)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.delete(id: record.id)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                        .onDelete(perform: store.delete)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppPalette.background)
            .navigationTitle("我的决定")
            .toolbar {
                if !store.records.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showClearConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .accessibilityLabel("清空全部记录")
                    }
                }
            }
            .confirmationDialog(
                "确定清空全部记录吗？",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("清空全部记录", role: .destructive) {
                    store.clear()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("这项操作无法撤销。")
            }
        }
    }

    private func recordRow(_ record: DecisionRecord) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(record.method.rawValue, systemImage: record.method.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppPalette.primary)

                Spacer()

                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(record.title)
                .font(.headline)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("决定：")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(record.result)
                    .font(.title3.bold())
                    .foregroundStyle(AppPalette.secondary)
            }

            Text("候选：\(record.options.joined(separator: " · "))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            ShareLink(item: record.shareText) {
                Label("分享结果", systemImage: "square.and.arrow.up")
                    .font(.caption.weight(.medium))
            }
        }
        .padding(.vertical, 8)
    }
}
