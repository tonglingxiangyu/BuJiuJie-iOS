import Foundation
import Combine

@MainActor
final class DecisionStore: ObservableObject {
    @Published private(set) var records: [DecisionRecord] = []

    private let defaultsKey = "bujiujie.decision.records.v1"

    init() {
        load()
    }

    func add(_ record: DecisionRecord) {
        records.insert(record, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            records.remove(at: index)
        }
        save()
    }

    func delete(id: UUID) {
        records.removeAll { $0.id == id }
        save()
    }

    func clear() {
        records.removeAll()
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let saved = try? JSONDecoder().decode([DecisionRecord].self, from: data)
        else { return }

        records = saved
    }
}
