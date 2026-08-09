import Vision
import UIKit

/// 本地人脸分析服务：使用 Apple Vision 框架在设备端检测人脸与关键点。
/// 照片不离开本机，不上传任何服务器。
struct FaceAnalyzer {
    static let shared = FaceAnalyzer()

    enum AnalysisError: LocalizedError {
        case noFace
        case multipleFaces
        case lowQuality

        var errorDescription: String? {
            switch self {
            case .noFace: "没有检测到人脸，请上传一张清晰的正面照试试。"
            case .multipleFaces: "检测到多张人脸，请使用只有你自己的单人照片。"
            case .lowQuality: "照片质量不足，请使用光线明亮、正脸、不遮挡的照片。"
            }
        }
    }

    /// 分析一张照片，返回脸型结果（async，运行在后台）
    func analyze(_ image: UIImage) async throws -> AnalysisResult {
        guard let cgImage = image.cgImage else { throw AnalysisError.lowQuality }
        let orientation = image.cgOrientation

        // 检测在后台线程执行；闭包内创建 request/handler 并直接提取特征，
        // 返回值全部为 Sendable 值，不跨隔离区传递 Vision 对象
        let detection = try await Task.detached(priority: .userInitiated) { () -> DetectionResult in
            let request = VNDetectFaceLandmarksRequest()
            request.revision = VNDetectFaceLandmarksRequestRevision3
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: orientation,
                options: [:]
            )
            try handler.perform([request])

            let observations = request.results ?? []
            guard observations.count == 1,
                  let observation = observations.first,
                  let features = Self.extractFeatures(from: observation) else {
                return DetectionResult(faceCount: observations.count, features: nil)
            }
            return DetectionResult(faceCount: 1, features: features)
        }.value

        guard detection.faceCount > 0 else { throw AnalysisError.noFace }
        guard detection.faceCount == 1 else { throw AnalysisError.multipleFaces }
        guard let features = detection.features else { throw AnalysisError.lowQuality }

        let (shape, confidence) = FaceShapeClassifier.shared.classify(features)
        return AnalysisResult(faceShape: shape, confidence: confidence, features: features)
    }

    /// 检测结果（纯值类型，可安全跨隔离区传递）
    private struct DetectionResult: Sendable {
        let faceCount: Int
        let features: FaceFeatures?
    }

    // MARK: - 特征提取

    /// 从人脸观察结果提取归一化几何特征。
    /// 注意：VNFaceLandmarkRegion2D.normalizedPoints 已是相对人脸框的 0~1 归一化坐标，
    /// 直接使用即可，不要再用人脸框坐标二次归一化。
    private static func extractFeatures(from observation: VNFaceObservation) -> FaceFeatures? {
        guard let contour = observation.landmarks?.faceContour?.normalizedPoints,
              contour.count > 10 else { return nil }

        // 轮廓点：x、y 均为 0~1（相对人脸框，y 向上）
        let pts = contour.map { p -> (x: Double, y: Double) in
            (x: Double(p.x), y: Double(p.y))
        }

        // 下巴尖：y 最小的点
        guard let chin = pts.min(by: { $0.y < $1.y }) else { return nil }

        // 下颌宽度：下巴尖向上 28% 脸长范围内的轮廓宽度
        let jawPoints = pts.filter { $0.y <= chin.y + 0.28 }
        // 颧骨宽度：脸中部 35%~65% 高度范围内的轮廓宽度
        let cheekPoints = pts.filter { $0.y >= 0.35 && $0.y <= 0.65 }
        // 额头宽度：脸高 75% 以上的轮廓宽度（缺失时用脸框全宽近似）
        let foreheadPoints = pts.filter { $0.y >= 0.75 }

        guard !jawPoints.isEmpty, !cheekPoints.isEmpty else { return nil }

        let faceWidth = xRange(cheekPoints)
        let jawWidth = xRange(jawPoints)
        let foreheadWidth = foreheadPoints.isEmpty ? 1.0 : xRange(foreheadPoints)
        let faceHeight = 1.0 // 人脸框高度已归一化为 1

        return FaceFeatures(
            faceWidth: faceWidth,
            faceHeight: faceHeight,
            jawWidth: jawWidth,
            foreheadWidth: foreheadWidth,
            aspectRatio: faceWidth / faceHeight
        )
    }

    private static func xRange(_ points: [(x: Double, y: Double)]) -> Double {
        let xs = points.map(\.x)
        guard let maxX = xs.max(), let minX = xs.min() else { return 0 }
        return maxX - minX
    }
}

// MARK: - UIImage 方向转换

extension UIImage {
    /// UIImage 方向 → Vision 所需的 CGImagePropertyOrientation
    var cgOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: .up
        case .down: .down
        case .left: .left
        case .right: .right
        case .upMirrored: .upMirrored
        case .downMirrored: .downMirrored
        case .leftMirrored: .leftMirrored
        case .rightMirrored: .rightMirrored
        @unknown default: .up
        }
    }
}
