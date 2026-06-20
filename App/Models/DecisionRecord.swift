import Foundation

enum DecisionMethod: String, Codable {
    case quick = "快速选择"
    case compare = "理性比较"

    var symbol: String {
        switch self {
        case .quick: return "sparkles"
        case .compare: return "chart.bar.fill"
        }
    }
}

struct DecisionRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let options: [String]
    let result: String
    let method: DecisionMethod
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        options: [String],
        result: String,
        method: DecisionMethod,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.options = options
        self.result = result
        self.method = method
        self.createdAt = createdAt
    }

    var shareText: String {
        "我用「不纠结」决定了：\(result)\n候选项：\(options.joined(separator: "、"))"
    }
}

