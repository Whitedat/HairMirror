import Foundation

/// 六种脸型分类
enum FaceShape: String, Codable, CaseIterable, Identifiable {
    case oval      // 鹅蛋脸
    case round     // 圆脸
    case square    // 方脸
    case long      // 长脸
    case heart     // 心形脸
    case diamond   // 菱形脸

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oval: "鹅蛋脸"
        case .round: "圆脸"
        case .square: "方脸"
        case .long: "长脸"
        case .heart: "心形脸"
        case .diamond: "菱形脸"
        }
    }

    /// 一句话脸型特征说明（展示在结果页）
    var summary: String {
        switch self {
        case .oval: "脸部长度约为宽度的 1.3~1.5 倍，下颌线条柔和，是公认的百搭脸型。"
        case .round: "脸部长度与宽度接近，脸颊饱满圆润，适合用发型拉长脸部线条。"
        case .square: "下颌骨较为突出，轮廓分明，适合用柔和线条弱化棱角。"
        case .long: "脸部明显偏长，适合用刘海或蓬松度在视觉上缩短脸长。"
        case .heart: "额头较宽、下巴较尖，适合用两侧发量平衡额头宽度。"
        case .diamond: "颧骨较宽、额头与下巴较窄，适合用发量修饰颧骨区域。"
        }
    }

    /// 近似脸型（用于推荐引擎的邻接加分）
    var neighbors: [FaceShape] {
        switch self {
        case .oval: [.round, .long]
        case .round: [.oval, .square]
        case .square: [.round, .diamond]
        case .long: [.oval, .diamond]
        case .heart: [.oval, .diamond]
        case .diamond: [.heart, .long, .square]
        }
    }
}
