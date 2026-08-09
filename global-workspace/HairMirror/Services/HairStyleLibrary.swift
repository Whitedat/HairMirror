import Foundation

/// 内置发型库：从 bundled hairstyles.json 加载（离线可用）
struct HairStyleLibrary {
    static let shared = HairStyleLibrary()

    private let styles: [HairStyle]

    /// 全部风格标签（用于筛选 UI）
    static let allStyles = ["甜美", "清爽", "优雅", "自然", "酷飒", "复古", "可爱"]
    /// 全部长度标签（用于筛选 UI）
    static let allLengths = ["超短", "短发", "中发", "中长发", "长发", "刘海"]

    init() {
        guard let url = Bundle.main.url(forResource: "hairstyles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            styles = []
            return
        }
        styles = payload.styles
    }

    var all: [HairStyle] { styles }

    /// 按脸型筛选（含近似脸型）
    func suitable(for shape: FaceShape) -> [HairStyle] {
        styles.filter { $0.suitableShapes.contains(shape) }
    }

    /// 关键词搜索（中文名 / 英文名 / 风格 / 长度）
    func search(keyword: String) -> [HairStyle] {
        let kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !kw.isEmpty else { return styles }
        return styles.filter {
            $0.name.localizedCaseInsensitiveContains(kw)
                || $0.nameEn.localizedCaseInsensitiveContains(kw)
                || $0.style.contains(kw)
                || $0.length.contains(kw)
        }
    }

    private struct Payload: Codable {
        let version: Int
        let styles: [HairStyle]
    }
}
