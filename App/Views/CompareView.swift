import SwiftUI
import UIKit

private struct ComparisonOption: Identifiable {
    let id = UUID()
    var name: String
    var scores: [UUID: Int] = [:]
}

private struct Criterion: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var weight: Int

    init(id: UUID = UUID(), name: String, weight: Int) {
        self.id = id
        self.name = name
        self.weight = weight
    }

    static var defaults: [Criterion] {
        [
            Criterion(name: "心动程度", weight: 4),
            Criterion(name: "现实可行", weight: 5),
            Criterion(name: "长期价值", weight: 3),
            Criterion(name: "安心程度", weight: 3)
        ]
    }
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
    @State private var criteria = Criterion.defaults
    @State private var newCriterionName = ""
    @State private var showingAddCriterion = false
    @State private var showingResetCriteriaConfirmation = false
    @State private var didLoadCriteria = false
    @State private var ranking: [RankedOption] = []
    @State private var winner: String?

    private let criteriaDefaultsKey = "bujiujie.comparison.criteria.v1"

    private var validOptionCount: Int {
        options.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }

    private var criteriaAreValid: Bool {
        !criteria.isEmpty && criteria.allSatisfy {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private var canCalculate: Bool {
        validOptionCount >= 2 && criteriaAreValid
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
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            TextField("比较维度名称", text: criterionNameBinding(for: criterion.id))
                                .font(.body.weight(.semibold))

                            Button(role: .destructive) {
                                deleteCriterion(id: criterion.id)
                            } label: {
                                Image(systemName: "trash")
                                    .accessibilityLabel("删除比较维度")
                            }
                            .buttonStyle(.borderless)
                            .disabled(criteria.count == 1)
                        }

                        Stepper(value: criterionWeightBinding(for: criterion.id), in: 1...5) {
                            HStack {
                                Text("重要程度")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(criterion.weight)")
                                    .font(.body.monospacedDigit().bold())
                                    .foregroundStyle(AppPalette.primary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteCriteria)

                Button {
                    newCriterionName = ""
                    showingAddCriterion = true
                } label: {
                    Label("添加比较维度", systemImage: "plus.circle.fill")
                }

                Button {
                    showingResetCriteriaConfirmation = true
                } label: {
                    Label("恢复默认四项", systemImage: "arrow.counterclockwise")
                }
                .foregroundStyle(.secondary)
            } header: {
                Text("先调重要程度")
            } footer: {
                Text("名称和重要程度会自动保存。至少保留 1 项，1 表示不太重要，5 表示非常重要。")
            }

            Section("再给每项打分") {
                ForEach(options) { option in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(option.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "未命名候选项" : option.name)
                            .font(.headline)

                        ForEach(criteria) { criterion in
                            HStack(spacing: 12) {
                                Text(criterion.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "未命名维度" : criterion.name)
                                    .font(.subheadline)
                                    .frame(width: 88, alignment: .leading)

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
                .disabled(!canCalculate)
                .opacity(canCalculate ? 1 : 0.5)
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
        .onAppear(perform: loadCriteriaIfNeeded)
        .onChange(of: criteria) { newCriteria in
            guard didLoadCriteria else { return }
            saveCriteria(newCriteria)
        }
        .alert("添加比较维度", isPresented: $showingAddCriterion) {
            TextField("例如：预算、距离、成长空间", text: $newCriterionName)
            Button("取消", role: .cancel) {
                newCriterionName = ""
            }
            Button("添加", action: addCriterion)
                .disabled(newCriterionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("新增维度的重要程度默认为 3，添加后可以继续修改。")
        }
        .confirmationDialog(
            "恢复默认四项？",
            isPresented: $showingResetCriteriaConfirmation,
            titleVisibility: .visible
        ) {
            Button("恢复默认", role: .destructive, action: resetCriteria)
            Button("取消", role: .cancel) {}
        } message: {
            Text("当前自定义维度会被心动程度、现实可行、长期价值和安心程度替换。")
        }
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

    private func criterionNameBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { criteria.first(where: { $0.id == id })?.name ?? "" },
            set: { newValue in
                guard let index = criteria.firstIndex(where: { $0.id == id }) else { return }
                criteria[index].name = newValue
                invalidateResult()
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

    private func addCriterion() {
        let trimmedName = newCriterionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        criteria.append(Criterion(name: trimmedName, weight: 3))
        newCriterionName = ""
        invalidateResult()
    }

    private func deleteCriteria(at offsets: IndexSet) {
        guard criteria.count - offsets.count >= 1 else { return }
        let removedIDs = offsets.map { criteria[$0].id }
        criteria.remove(atOffsets: offsets)
        removeScores(for: removedIDs)
        invalidateResult()
    }

    private func deleteCriterion(id: UUID) {
        guard criteria.count > 1 else { return }
        criteria.removeAll { $0.id == id }
        removeScores(for: [id])
        invalidateResult()
    }

    private func removeScores(for criterionIDs: [UUID]) {
        for optionIndex in options.indices {
            for id in criterionIDs {
                options[optionIndex].scores.removeValue(forKey: id)
            }
        }
    }

    private func resetCriteria() {
        criteria = Criterion.defaults
        for optionIndex in options.indices {
            options[optionIndex].scores.removeAll()
        }
        invalidateResult()
    }

    private func invalidateResult() {
        winner = nil
        ranking = []
    }

    private func loadCriteriaIfNeeded() {
        guard !didLoadCriteria else { return }
        didLoadCriteria = true

        guard
            let data = UserDefaults.standard.data(forKey: criteriaDefaultsKey),
            let saved = try? JSONDecoder().decode([Criterion].self, from: data),
            !saved.isEmpty
        else {
            criteria = Criterion.defaults
            return
        }

        criteria = saved.map {
            Criterion(id: $0.id, name: $0.name, weight: min(max($0.weight, 1), 5))
        }
    }

    private func saveCriteria(_ criteria: [Criterion]) {
        guard let data = try? JSONEncoder().encode(criteria) else { return }
        UserDefaults.standard.set(data, forKey: criteriaDefaultsKey)
    }

    private func calculate() {
        let validOptions = options.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        guard validOptions.count >= 2, criteriaAreValid else { return }

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
