import Foundation

/// 一条推荐结果
struct Recommendation: Identifiable, Hashable {
    let style: HairStyle
    let score: Int
    /// 推荐理由（面向用户展示）
    let reason: String

    var id: String { style.id }
}

/// 发型推荐引擎：脸型 + 性别 + 风格/长度偏好 → 打分排序（纯本地计算）
struct HairRecommendationEngine {
    static let shared = HairRecommendationEngine()

    /// 推荐偏好（可选）
    struct Preferences: Hashable {
        var gender: String? = nil      // "女" / "男"
        var style: String? = nil       // "甜美" / "酷飒" ...
        var length: String? = nil      // "短发" / "长发" ...
    }

    /// 返回按匹配度排序的推荐列表（默认前 12 款）
    func recommend(
        for shape: FaceShape,
        preferences: Preferences = Preferences(),
        limit: Int = 12
    ) -> [Recommendation] {
        HairStyleLibrary.shared.all
            .compactMap { style -> Recommendation? in
                let score = score(for: style, shape: shape, preferences: preferences)
                guard score > 0 else { return nil }
                return Recommendation(
                    style: style,
                    score: score,
                    reason: "适合\(shape.displayName)：\(style.description)"
                )
            }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - 打分规则

    private func score(for style: HairStyle, shape: FaceShape, preferences: Preferences) -> Int {
        var s = 0

        // 脸型匹配：直接适合 100 分；近似脸型 70 分；不相关直接淘汰
        if style.suitableShapes.contains(shape) {
            s += 100
        } else if style.suitableShapes.contains(where: { shape.neighbors.contains($0) }) {
            s += 70
        } else {
            return 0
        }

        // 性别匹配：不符性别扣分
        if let gender = preferences.gender, gender != "通用" {
            if style.gender == gender || style.gender == "通用" {
                s += 10
            } else {
                s -= 25
            }
        }

        // 风格 / 长度偏好加分
        if let stylePref = preferences.style, style.style == stylePref {
            s += 20
        }
        if let lengthPref = preferences.length, style.length == lengthPref {
            s += 15
        }

        return s
    }
}
