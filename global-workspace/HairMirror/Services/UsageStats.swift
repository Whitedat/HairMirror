import Foundation
import UIKit

/// 本地匿名使用统计：仅存本机 UserDefaults。
/// 默认关闭，用户自愿开启；只记录计数与脸型分布，不含照片、不含任何身份信息。
@MainActor
final class UsageStats: ObservableObject {
    static let shared = UsageStats()

    @Published private(set) var isEnabled: Bool

    private let defaults = UserDefaults.standard

    private enum Key {
        static let enabled = "stats.enabled"
        static let analysisCount = "stats.analysisCount"
        static let shapeCounts = "stats.shapeCounts"
        static let favoriteCount = "stats.favoriteCount"
        static let feedbackCount = "stats.feedbackCount"
        static let searchCount = "stats.searchCount"
    }

    private init() {
        isEnabled = defaults.bool(forKey: Key.enabled)
    }

    /// 用户开关（默认关闭）
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        defaults.set(enabled, forKey: Key.enabled)
    }

    // MARK: - 记录（仅在开启时生效）

    func recordAnalysis(shape: FaceShape) {
        guard isEnabled else { return }
        let count = defaults.integer(forKey: Key.analysisCount) + 1
        defaults.set(count, forKey: Key.analysisCount)

        var counts = defaults.dictionary(forKey: Key.shapeCounts) as? [String: Int] ?? [:]
        counts[shape.rawValue, default: 0] += 1
        defaults.set(counts, forKey: Key.shapeCounts)
    }

    func recordFavorite() {
        guard isEnabled else { return }
        defaults.set(defaults.integer(forKey: Key.favoriteCount) + 1, forKey: Key.favoriteCount)
    }

    func recordFeedback() {
        guard isEnabled else { return }
        defaults.set(defaults.integer(forKey: Key.feedbackCount) + 1, forKey: Key.feedbackCount)
    }

    func recordSearch() {
        guard isEnabled else { return }
        defaults.set(defaults.integer(forKey: Key.searchCount) + 1, forKey: Key.searchCount)
    }

    // MARK: - 导出（不含照片）

    /// 生成匿名统计 JSON 文本（供"导出我的数据"与反馈附带）
    func exportSummary() -> String {
        let counts = defaults.dictionary(forKey: Key.shapeCounts) as? [String: Int] ?? [:]
        let shapeBreakdown = FaceShape.allCases.reduce(into: [String: Int]()) { partial, shape in
            partial[shape.displayName] = counts[shape.rawValue] ?? 0
        }
        let summary: [String: Any] = [
            "appVersion": AppInfo.version,
            "deviceModel": AppInfo.deviceModel,
            "statsEnabled": isEnabled,
            "analysisCount": defaults.integer(forKey: Key.analysisCount),
            "shapeBreakdown": shapeBreakdown,
            "favoriteCount": defaults.integer(forKey: Key.favoriteCount),
            "feedbackCount": defaults.integer(forKey: Key.feedbackCount),
            "searchCount": defaults.integer(forKey: Key.searchCount),
            "exportedAt": ISO8601DateFormatter().string(from: Date()),
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: summary, options: [.prettyPrinted, .sortedKeys]),
              let text = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return text
    }

    /// 清空全部统计（隐私：一键删除本地数据）
    func resetAll() {
        for key in [Key.enabled, Key.analysisCount, Key.shapeCounts, Key.favoriteCount,
                    Key.feedbackCount, Key.searchCount] {
            defaults.removeObject(forKey: key)
        }
        isEnabled = false
    }
}

/// App 基础信息（版本号、机型，随反馈附带，不含敏感信息）
enum AppInfo {
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    static var deviceModel: String {
        UIDevice.current.model + " " + (UIDevice.current.systemName + " " + UIDevice.current.systemVersion)
    }
}
