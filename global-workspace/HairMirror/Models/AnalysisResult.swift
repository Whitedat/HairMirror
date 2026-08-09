import Foundation

/// 一次脸型分析的结果（照片本身不会被保存，仅保存几何特征）
struct AnalysisResult: Identifiable, Hashable, Codable {
    let id: UUID
    let faceShape: FaceShape
    let confidence: Double
    let features: FaceFeatures
    let analyzedAt: Date

    init(id: UUID = UUID(), faceShape: FaceShape, confidence: Double, features: FaceFeatures, analyzedAt: Date = Date()) {
        self.id = id
        self.faceShape = faceShape
        self.confidence = confidence
        self.features = features
        self.analyzedAt = analyzedAt
    }
}

/// 人脸几何特征（全部为归一化比例，不含任何身份信息）
struct FaceFeatures: Codable, Hashable {
    /// 颧骨宽度（相对脸框）
    let faceWidth: Double
    /// 脸长（相对脸框）
    let faceHeight: Double
    /// 下颌宽度（相对脸框）
    let jawWidth: Double
    /// 额头宽度（相对脸框）
    let foreheadWidth: Double
    /// 宽长比 = 颧骨宽 / 脸长（核心判型特征）
    let aspectRatio: Double
}
