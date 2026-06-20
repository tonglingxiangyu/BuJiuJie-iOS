import SwiftUI

struct HomeView: View {
    private let reminders = [
        "没有完美答案，只有此刻更适合你的答案。",
        "如果两个选项都不错，选哪个都不是失败。",
        "先决定，再把这个决定变成好决定。",
        "允许自己用一个小选择，换回一点行动力。"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    VStack(spacing: 15) {
                        NavigationLink {
                            QuickPickView()
                        } label: {
                            ModeCard(
                                title: "快速替我选",
                                subtitle: "输入候选项，把最后一下交给概率",
                                symbol: "sparkles",
                                colors: [AppPalette.primary, AppPalette.secondary]
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            CompareView()
                        } label: {
                            ModeCard(
                                title: "认真比一比",
                                subtitle: "按心动、可行性和长期价值打分",
                                symbol: "chart.bar.xaxis",
                                colors: [AppPalette.mint, AppPalette.primary]
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    reminderCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(AppPalette.background)
            .navigationTitle("不纠结")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("现在卡在哪个选择里？")
                .font(.title2.bold())
            Text("先选一种方式，我们一起把决定变小。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var reminderCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppPalette.secondary)

            Text(reminders[Calendar.current.component(.day, from: Date()) % reminders.count])
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

