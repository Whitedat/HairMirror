import SwiftUI
import UIKit

/// 发型卡片：占位图（可替换为图片资源）+ 名称 + 标签 + 描述/推荐理由
struct HairStyleCardView: View {
    let style: HairStyle
    /// 推荐场景下的理由（如"适合圆脸：…"）；为空时展示通用描述
    var reason: String?
    /// 收藏状态与切换（为空时不显示收藏按钮）
    var isFavorite: Bool = false
    var onToggleFavorite: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 图区：有图片资源则显示图片，否则显示占位
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.tint.opacity(0.28), .tint.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                if let imageName = style.imageName, let image = UIImage(named: imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "scissors")
                            .font(.system(size: 34))
                            .foregroundStyle(.tint.opacity(0.7))
                        Text("发型示意图")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                // 收藏按钮
                if let onToggleFavorite {
                    Button {
                        onToggleFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundStyle(isFavorite ? .pink : .white)
                            .padding(8)
                            .background(Circle().fill(.black.opacity(0.25)))
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack(alignment: .firstTextBaseline) {
                Text(style.name)
                    .font(.headline)
                Spacer()
                if let reason {
                    Text("推荐")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(.tint))
                        .foregroundStyle(.white)
                }
            }

            HStack(spacing: 8) {
                chip(style.style)
                chip(style.length)
                chip(style.gender)
            }

            Text(reason ?? style.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(.tint.opacity(0.12)))
            .foregroundStyle(.tint)
    }
}

#Preview {
    HairStyleCardView(
        style: HairStyle(
            id: "bob", name: "波波头", nameEn: "Bob", style: "甜美",
            length: "短发", gender: "通用",
            suitableShapes: [.oval, .round],
            description: "齐下巴长度的经典波波头，弧度柔和显脸小。"
        ),
        reason: "适合圆脸：齐下巴长度的经典波波头，弧度柔和显脸小。"
    )
    .padding()
}
