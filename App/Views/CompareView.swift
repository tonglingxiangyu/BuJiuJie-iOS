import SwiftUI
import UIKit

private struct ComparisonOption: Identifiable {
    let id = UUID()
    var name: String
    var scores: [UUID: Int] = [:]
}

private struct Criterion: Identifiable {
    let id = UUID()
    let name: String
    var weight: Int
}

private struct RankedOption: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
}

struct CompareView: View {
    @EnvironmentObject private var store: DecisionStore

    @State private var title = ""
    @State private var options = [ComparisonOption(name: ""), ComparisonOption(name: "")]
    @State private var criteria = [
        Criterion(name: "心动程度", weight: 4),
        Criterion(name: "现实可行", weight: 5),
        Criterion(name: "长期价值", weight: 3),
        Criterion(name: "安心程度", weight: 3)
    ]
    @State private var ranking: [RankedOption] = []
    @State private var winner: String?

    private var validOptionCount: Int {
        options.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }

    var body: some View {
        Form {
            Section("这次要决定") {
                TextField("例如：选择哪份工作？", text: $title)
            }

            Section {
                ForEach(options) { option in
                    TextField("候选项", text: optionNameBinding(for: option.id))
                }
                .onDelete(perform: deleteOptions)

                if options.count < 4 {
                    Button {
                        options.append(ComparisonOption(name: ""))
                    } label: {
                        Label("添加候选项", systemImage: "plus.circle.fill")
                    }
                }
            } header: {
                Text("候选项")
            } footer: {
                Text("至少填写 2 项，最多 4 项。")
            }

            Section {
                ForEach(criteria) { criterion in
                    Stepper(value: criterionWeightBinding(for: criterion.id), in: 1...5) {
                        HStack {
                            Text(criterion.name)
                            Spacer()
                            Text("重要度 \(criterion.weight)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppPalette.primary)
                        }
                    }
                }
            } header: {
                Text("先调重要程度")
            } footer: {
                Text("1 表示不太重要，5 表示非常重要。")
            }

            Section("再给每项打分") {
                ForEach(options) { option in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(option.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "未命名候选项" : option.name)
                            .font(.headline)

                        ForEach(criteria) { criterion in
                            HStack(spacing: 12) {
                                Text(criterion.name)
                                    .font(.subheadline)
                                    .frame(width: 76, alignment: .leading)

                                Slider(
                                    value: scoreBinding(optionID: option.id, criterionID: criterion.id),
                                    in: 1...5,
                                    step: 1
                                )
                                .tint(AppPalette.primary)

                                Text("\(score(optionID: option.id, criterionID: criterion.id))")
                                    .font(.body.monospacedDigit().bold())
                                    .frame(width: 20)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            Section {
                Button(action: calculate) {
                    HStack {
                        Spacer()
                        Image(systemName: "chart.bar.fill")
                        Text("算出更适合我的")
                        Spacer()
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 7)
                }
                .listRowBackground(AppPalette.primary)
                .disabled(validOptionCount < 2)
                .opacity(validOptionCount < 2 ? 0.5 : 1)
            }

            if let winner {
                Section("比较结果") {
                    ResultCard(
                        eyebrow: "综合分更高的是",
                        result: winner,
                        symbol: "trophy.fill",
                        color: AppPalette.mint
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                    ForEach(ranking) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.score) 分")
                                .font(.body.monospacedDigit().bold())
                                .foregroundStyle(item.name == winner ? AppPalette.primary : .secondary)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppPalette.background)
        .navigationTitle("认真比一比")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func optionNameBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { options.first(where: { $0.id == id })?.name ?? "" },
            set: { newValue in
                guard let index = options.firstIndex(where: { $0.id == id }) else { return }
                options[index].name = newValue
                winner = nil
                ranking = []
            }
        )
    }

    private func criterionWeightBinding(for id: UUID) -> Binding<Int> {
        Binding(
            get: { criteria.first(where: { $0.id == id })?.weight ?? 1 },
            set: { newValue in
                guard let index = criteria.firstIndex(where: { $0.id == id }) else { return }
                criteria[index].weight = newValue
                winner = nil
                ranking = []
            }
        )
    }

    private func scoreBinding(optionID: UUID, criterionID: UUID) -> Binding<Double> {
        Binding(
            get: { Double(score(optionID: optionID, criterionID: criterionID)) },
            set: { newValue in
                guard let index = options.firstIndex(where: { $0.id == optionID }) else { return }
                options[index].scores[criterionID] = Int(newValue)
                winner = nil
                ranking = []
            }
        )
    }

    private func score(optionID: UUID, criterionID: UUID) -> Int {
        options.first(where: { $0.id == optionID })?.scores[criterionID] ?? 3
    }

    private func deleteOptions(at offsets: IndexSet) {
        guard options.count - offsets.count >= 2 else { return }
        options.remove(atOffsets: offsets)
        winner = nil
        ranking = []
    }

    private func calculate() {
        let validOptions = options.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        guard validOptions.count >= 2 else { return }

        let ranked = validOptions.map { option in
            let total = criteria.reduce(0) { partial, criterion in
                partial + (option.scores[criterion.id] ?? 3) * criterion.weight
            }
            return RankedOption(
                name: option.name.trimmingCharacters(in: .whitespacesAndNewlines),
                score: total
            )
        }
        .sorted {
            if $0.score == $1.score { return $0.name < $1.name }
            return $0.score > $1.score
        }

        guard let topScore = ranked.first?.score else { return }
        let tiedWinners = ranked.filter { $0.score == topScore }
        let selectedWinner = tiedWinners.randomElement()?.name ?? ranked[0].name

        ranking = ranked
        winner = selectedWinner
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        store.add(
            DecisionRecord(
                title: trimmedTitle.isEmpty ? "理性比较" : trimmedTitle,
                options: validOptions.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) },
                result: selectedWinner,
                method: .compare
            )
        )
    }
}

