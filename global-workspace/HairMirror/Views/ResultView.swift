import SwiftUI

/// 分析结果页：脸型结论 + 偏好选择 + 发型推荐 + 在线搜更多
struct ResultView: View {
    let result: AnalysisResult

    @State private var recommendations: [Recommendation] = []
    @State private var gender: String? = nil
    @State private var stylePref: String? = nil
    @State private var lengthPref: String? = nil
    @State private var showSearch = false
    @State private var searchURL: URL?

    init(result: AnalysisResult) {
        self.result = result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                faceSummarySection

                preferenceSection

                if recommendations.isEmpty {
                    ContentUnavailableView(
                        "暂无推荐",
                        systemImage: "scissors",
                        description: Text("试试调整上面的偏好")
                    )
                } else {
                    VStack(spacing: 14) {
                        ForEach(recommendations) { rec in
                            HairStyleCardView(style: rec.style, reason: rec.reason)
                        }
                    }
                }

                searchMoreButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationTitle("分析结果")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: reload)
        .sheet(isPresented: $showSearch) {
            if let searchURL {
                SafariWebView(url: searchURL)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - 脸型结论

    private var faceSummarySection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.15))
                    .frame(width: 120, height: 120)
                VStack(spacing: 4) {
                    Image(systemName: faceIcon)
                        .font(.system(size: 40))
                        .foregroundStyle(.tint)
                    Text(result.faceShape.displayName)
                        .font(.title2.bold())
                }
            }

            Text("匹配度 \(Int(result.confidence * 100))%")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(result.faceShape.summary)
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    // MARK: - 偏好选择

    private var preferenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("调整推荐偏好")
                .font(.headline)

            // 性别
            Picker("性别", selection: $gender) {
                Text("不限制").tag(String?.none)
                Text("女生").tag(String?.some("女"))
                Text("男生").tag(String?.some("男"))
            }
            .pickerStyle(.segmented)
            .onChange(of: gender) { _, _ in reload() }

            // 风格
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    prefChip("全部风格", isSelected: stylePref == nil) { stylePref = nil }
                    ForEach(HairStyleLibrary.allStyles, id: \.self) { s in
                        prefChip(s, isSelected: stylePref == s) { stylePref = s }
                    }
                }
            }

            // 长度
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    prefChip("全部长度", isSelected: lengthPref == nil) { lengthPref = nil }
                    ForEach(HairStyleLibrary.allLengths, id: \.self) { l in
                        prefChip(l, isSelected: lengthPref == l) { lengthPref = l }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func prefChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(isSelected ? Color.accentColor : Color(.systemBackground)))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 在线搜更多

    private var searchMoreButton: some View {
        Button {
            openSearch()
        } label: {
            Label("在线搜更多 \(result.faceShape.displayName) 发型", systemImage: "safari.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
    }

    /// 只发送文字关键词（脸型+发型关键词），绝不发送照片
    private func openSearch() {
        let query = "\(result.faceShape.displayName) 发型 推荐"
        var comps = URLComponents(string: "https://www.baidu.com/s")
        comps?.queryItems = [URLQueryItem(name: "wd", value: query)]
        if let url = comps?.url {
            searchURL = url
            showSearch = true
            UsageStats.shared.recordSearch()
        }
    }

    // MARK: - 推荐加载

    private func reload() {
        let prefs = HairRecommendationEngine.Preferences(
            gender: gender,
            style: stylePref,
            length: lengthPref
        )
        recommendations = HairRecommendationEngine.shared.recommend(
            for: result.faceShape,
            preferences: prefs
        )
    }

    private var faceIcon: String {
        switch result.faceShape {
        case .oval: "circle.inset.filled"
        case .round: "circle.fill"
        case .square: "square.fill"
        case .long: "rectangle.fill"
        case .heart: "heart.fill"
        case .diamond: "diamond.fill"
        }
    }
}

#Preview {
    NavigationStack {
        ResultView(result: AnalysisResult(
            faceShape: .round,
            confidence: 0.86,
            features: FaceFeatures(
                faceWidth: 0.92, faceHeight: 1.0, jawWidth: 0.85,
                foreheadWidth: 0.95, aspectRatio: 0.92
            )
        ))
    }
}
