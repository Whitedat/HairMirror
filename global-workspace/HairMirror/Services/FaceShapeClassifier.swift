import Foundation

/// 脸型分类器：基于归一化几何特征的比例规则进行分类（纯本地，无任何网络依赖）
struct FaceShapeClassifier {
    static let shared = FaceShapeClassifier()

    /// 分类结果：脸型 + 置信度（0.55 ~ 0.98）
    func classify(_ f: FaceFeatures) -> (shape: FaceShape, confidence: Double) {
        let ratio = f.aspectRatio                       // 宽/长
        let jawRatio = f.jawWidth / f.faceWidth         // 下颌 / 颧骨
        let foreheadRatio = f.foreheadWidth / f.faceWidth // 额头 / 颧骨

        switch ratio {
        case ..<0.70:
            // 脸长明显大于脸宽 → 长脸
            let d = distance(ratio, from: 0.70)
            return (.long, confidence(distance: d))

        case 0.70..<0.85:
            // 中等长宽比：区分方脸 / 菱形脸 / 鹅蛋脸
            if jawRatio > 0.92 {
                let d = distance(jawRatio, from: 0.92)
                return (.square, confidence(distance: d))
            }
            if foreheadRatio < 0.85 && jawRatio < 0.88 {
                // 颧骨最宽、额头与下颌都窄 → 菱形脸
                let d = min(distance(foreheadRatio, from: 0.85), distance(jawRatio, from: 0.88))
                return (.diamond, confidence(distance: d))
            }
            let d = min(
                distance(ratio, from: 0.70),
                distance(jawRatio, from: 0.92)
            )
            return (.oval, confidence(distance: d))

        case 0.85..<0.97:
            // 接近正方形：区分方脸 / 心形脸 / 菱形脸 / 圆脸
            if jawRatio > 0.92 {
                let d = distance(jawRatio, from: 0.92)
                return (.square, confidence(distance: d))
            }
            if foreheadRatio >= 0.90 && jawRatio < 0.80 {
                // 额头宽、下巴尖 → 心形脸
                let d = min(distance(foreheadRatio, from: 0.90), distance(jawRatio, from: 0.80))
                return (.heart, confidence(distance: d))
            }
            if foreheadRatio < 0.85 && jawRatio < 0.85 {
                let d = min(distance(foreheadRatio, from: 0.85), distance(jawRatio, from: 0.85))
                return (.diamond, confidence(distance: d))
            }
            let d = distance(ratio, from: 0.97)
            return (.round, confidence(distance: d))

        default:
            // 宽长比接近或超过 1 → 圆脸
            let d = distance(ratio, from: 0.97)
            return (.round, confidence(distance: d))
        }
    }

    // MARK: - 置信度辅助

    /// 特征值到判定边界的绝对距离（越远越确定）
    private func distance(_ value: Double, from boundary: Double) -> Double {
        abs(value - boundary)
    }

    /// 距离 → 置信度：边界处 0.55，远离边界 0.10 以上收敛到 0.98
    private func confidence(distance: Double, maxDistance: Double = 0.10) -> Double {
        let d = min(max(distance, 0), maxDistance) / maxDistance
        return 0.55 + 0.43 * d
    }
}
