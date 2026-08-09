import SwiftUI
import PhotosUI
import UIKit

/// 测脸型主页：拍照 / 相册选择 → 预览 → 本地分析 → 结果页
struct AnalyzeView: View {
    @State private var pickedImage: UIImage?
    @State private var showCamera = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var result: AnalysisResult?
    @State private var path = NavigationPath()
    @State private var showPrivacyNotice = false

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let pickedImage {
                    previewFlow(image: pickedImage)
                } else {
                    landingView
                }
            }
            .navigationTitle("发型魔镜")
            .navigationDestination(for: AnalysisResult.self) { result in
                ResultView(result: result)
            }
            .sheet(isPresented: $showPrivacyNotice) {
                PrivacyNoticeSheet {
                    PrivacyPreferences.shared.didShowFirstTimeNotice = true
                    showPrivacyNotice = false
                }
            }
            .onAppear {
                // 首次使用弹出隐私说明
                if !PrivacyPreferences.shared.didShowFirstTimeNotice {
                    showPrivacyNotice = true
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    pickedImage = image
                }
                .ignoresSafeArea()
            }
            .alert("无法分析", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("好", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - 未选图：首页

    private var landingView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 品牌区
            VStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                Text("拍一张正面照")
                    .font(.title2.bold())
                Text("AI 分析你的脸型，推荐最适合你的发型")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // 两个主按钮
            VStack(spacing: 16) {
                Button {
                    // 模拟器等无相机设备上避免崩溃，引导使用相册
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showCamera = true
                    } else {
                        errorMessage = "当前设备不支持相机，请使用相册选择照片。"
                    }
                } label: {
                    Label("拍照", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    Label("从相册选择", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 32)

            // 隐私承诺横幅
            Label("照片仅在本机分析，绝不上传", systemImage: "lock.shield.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
        }
        .onChange(of: photosPickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    pickedImage = image
                }
                photosPickerItem = nil
            }
        }
    }

    // MARK: - 已选图：预览 + 分析

    private func previewFlow(image: UIImage) -> some View {
        VStack(spacing: 20) {
            // 照片预览
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 24)

            // 拍摄建议
            Label("建议使用正脸、光线明亮、不遮挡脸部的照片", systemImage: "lightbulb")
                .font(.footnote)
                .foregroundStyle(.secondary)

            // 开始分析
            Button {
                startAnalysis(image: image)
            } label: {
                if isAnalyzing {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Label("开始分析", systemImage: "wand.and.stars")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAnalyzing)
            .padding(.horizontal, 32)

            // 本地临时图片管理：照片仅存内存、从不写盘，可一键删除
            HStack(spacing: 24) {
                Button("重新选择", systemImage: "arrow.counterclockwise") {
                    pickedImage = nil
                }
                .font(.subheadline)

                Button(role: .destructive) {
                    pickedImage = nil
                } label: {
                    Label("删除照片", systemImage: "trash")
                        .font(.subheadline)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.top, 16)
    }

    // MARK: - 分析

    private func startAnalysis(image: UIImage) {
        isAnalyzing = true
        Task {
            do {
                let analysis = try await FaceAnalyzer.shared.analyze(image)
                result = analysis
                path.append(analysis)
                UsageStats.shared.recordAnalysis(shape: analysis.faceShape)
                // 隐私优先：分析完成后自动删除本地照片（默认开启，可在"我的"页关闭）
                if PrivacyPreferences.shared.autoDeletePhoto {
                    pickedImage = nil
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isAnalyzing = false
        }
    }
}

#Preview {
    AnalyzeView()
}
