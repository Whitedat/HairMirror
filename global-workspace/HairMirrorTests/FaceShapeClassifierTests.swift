import XCTest
@testable import HairMirror

/// 分类器单元测试：使用合成特征数据验证六种脸型的分类准确性
final class FaceShapeClassifierTests: XCTestCase {

    private let classifier = FaceShapeClassifier.shared

    /// 构造归一化特征：faceWidth 固定为 1.0，其余按比例给出
    private func features(
        aspectRatio: Double,
        jawRatio: Double,
        foreheadRatio: Double
    ) -> FaceFeatures {
        FaceFeatures(
            faceWidth: 1.0,
            faceHeight: 1.0 / aspectRatio,
            jawWidth: jawRatio,
            foreheadWidth: foreheadRatio,
            aspectRatio: aspectRatio
        )
    }

    // MARK: - 六种脸型分类正确性

    func testClassifiesOvalFace() {
        let f = features(aspectRatio: 0.78, jawRatio: 0.85, foreheadRatio: 0.92)
        let result = classifier.classify(f)
        XCTAssertEqual(result.shape, .oval)
        XCTAssertGreaterThan(result.confidence, 0.55)
    }

    func testClassifiesRoundFace() {
        let f = features(aspectRatio: 0.92, jawRatio: 0.88, foreheadRatio: 0.95)
        let result = classifier.classify(f)
        XCTAssertEqual(result.shape, .round)
        XCTAssertGreaterThan(result.confidence, 0.55)
    }

    func testClassifiesSquareFace() {
        // 宽长比中等 + 下颌突出
        let f = features(aspectRatio: 0.80, jawRatio: 0.95, foreheadRatio: 0.95)
        let result = classifier.classify(f)
        XCTAssertEqual(result.shape, .square)
        XCTAssertGreaterThan(result.confidence, 0.55)
    }

    func testClassifiesLongFace() {
        let f = features(aspectRatio: 0.62, jawRatio: 0.88, foreheadRatio: 0.90)
        let result = classifier.classify(f)
        XCTAssertEqual(result.shape, .long)
        XCTAssertGreaterThan(result.confidence, 0.55)
    }

    func testClassifiesHeartFace() {
        // 额头宽 + 下巴尖
        let f = features(aspectRatio: 0.90, jawRatio: 0.75, foreheadRatio: 0.95)
        let result = classifier.classify(f)
        XCTAssertEqual(result.shape, .heart)
        XCTAssertGreaterThan(result.confidence, 0.55)
    }

    func testClassifiesDiamondFace() {
        // 颧骨最宽、额头与下颌都窄
        let f = features(aspectRatio: 0.80, jawRatio: 0.82, foreheadRatio: 0.80)
        let result = classifier.classify(f)
        XCTAssertEqual(result.shape, .diamond)
        XCTAssertGreaterThan(result.confidence, 0.55)
    }

    // MARK: - 置信度与边界

    func testConfidenceWithinRange() {
        let samples: [FaceFeatures] = [
            features(aspectRatio: 0.50, jawRatio: 0.85, foreheadRatio: 0.90), // 极端长脸
            features(aspectRatio: 1.10, jawRatio: 0.90, foreheadRatio: 0.95), // 极端圆脸
            features(aspectRatio: 0.75, jawRatio: 0.98, foreheadRatio: 0.95), // 极端方脸
            features(aspectRatio: 0.88, jawRatio: 0.70, foreheadRatio: 0.98), // 极端心形
            features(aspectRatio: 0.90, jawRatio: 0.90, foreheadRatio: 0.92), // 临界数据
        ]
        for f in samples {
            let result = classifier.classify(f)
            XCTAssertTrue(result.confidence >= 0.55 && result.confidence <= 0.98,
                          "置信度超出范围: \(result.confidence)")
        }
    }

    func testExtremeLongFaceGetsHighConfidence() {
        let f = features(aspectRatio: 0.45, jawRatio: 0.88, foreheadRatio: 0.90)
        let result = classifier.classify(f)
        XCTAssertEqual(result.shape, .long)
        XCTAssertGreaterThan(result.confidence, 0.85)
    }

    func testNeighborShapesAreReasonable() {
        // 近似脸型关系应当是对称的
        for shape in FaceShape.allCases {
            for neighbor in shape.neighbors {
                XCTAssertTrue(neighbor.neighbors.contains(shape),
                              "\(shape.displayName) ↔ \(neighbor.displayName) 邻接不对称")
            }
        }
    }
}
