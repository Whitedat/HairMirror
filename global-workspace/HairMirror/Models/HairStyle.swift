import Foundation

/// 一款发型（数据来自内置 hairstyles.json，图片可后续替换）
struct HairStyle: Identifiable, Codable, Hashable {
    let id: String
    /// 中文名
    let name: String
    /// 英文名（用于搜索关键词）
    let nameEn: String
    /// 风格：甜美 / 清爽 / 优雅 / 自然 / 酷飒 / 复古 / 可爱
    let style: String
    /// 长度：超短 / 短发 / 中发 / 中长发 / 长发 / 刘海
    let length: String
    /// 性别：通用 / 女 / 男
    let gender: String
    /// 适合脸型
    let suitableShapes: [FaceShape]
    /// 推荐理由 / 说明
    let description: String
    /// 图片资源名（占位，放入 HairMirror/Resources/HairImages/ 后即可显示）
    var imageName: String?

    enum CodingKeys: String, CodingKey {
        case id, name, nameEn, style, length, gender, shapes, description, imageName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        nameEn = try c.decode(String.self, forKey: .nameEn)
        style = try c.decode(String.self, forKey: .style)
        length = try c.decode(String.self, forKey: .length)
        gender = try c.decode(String.self, forKey: .gender)
        suitableShapes = try c.decode([FaceShape].self, forKey: .shapes)
        description = try c.decode(String.self, forKey: .description)
        imageName = try c.decodeIfPresent(String.self, forKey: .imageName)
    }

    init(
        id: String, name: String, nameEn: String, style: String, length: String,
        gender: String, suitableShapes: [FaceShape], description: String, imageName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.style = style
        self.length = length
        self.gender = gender
        self.suitableShapes = suitableShapes
        self.description = description
        self.imageName = imageName
    }
}
