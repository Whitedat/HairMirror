import SwiftUI

/// 发型库浏览页：搜索 + 风格/长度筛选 + 收藏
struct HairLibraryView: View {
    @StateObject private var favorites = FavoritesStore.shared
    @State private var searchText = ""
    @State private var styleFilter: String?
    @State private var lengthFilter: String?
    @State private var showFavoritesOnly = false

    private var filteredStyles: [HairStyle] {
        var list = HairStyleLibrary.shared.search(keyword: searchText)
        if let styleFilter {
            list = list.filter { $0.style == styleFilter }
        }
        if let lengthFilter {
            list = list.filter { $0.length == lengthFilter }
        }
        if showFavoritesOnly {
            list = list.filter { favorites.isFavorite($0.id) }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    filterSection

                    if filteredStyles.isEmpty {
                        ContentUnavailableView(
                            showFavoritesOnly ? "还没有收藏" : "没有找到相关发型",
                            systemImage: showFavoritesOnly ? "heart" : "magnifyingglass",
                            description: Text(showFavoritesOnly ? "去推荐页或发型库点❤️收藏吧" : "换个关键词或筛选条件试试")
                        )
                    } else {
                        ForEach(filteredStyles) { style in
                            HairStyleCardView(
                                style: style,
                                isFavorite: favorites.isFavorite(style.id),
                                onToggleFavorite: { favorites.toggle(style.id) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationTitle("发型库")
            .searchable(text: $searchText, prompt: "搜索发型，如：波浪 / 短发 / Bob")
        }
    }

    // MARK: - 筛选区

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 收藏开关
            Toggle(isOn: $showFavoritesOnly) {
                Label("只看收藏", systemImage: "heart.fill")
                    .font(.subheadline)
            }
            .tint(.pink)

            // 风格
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("全部风格", isSelected: styleFilter == nil) { styleFilter = nil }
                    ForEach(HairStyleLibrary.allStyles, id: \.self) { s in
                        filterChip(s, isSelected: styleFilter == s) { styleFilter = s }
                    }
                }
            }

            // 长度
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("全部长度", isSelected: lengthFilter == nil) { lengthFilter = nil }
                    ForEach(HairStyleLibrary.allLengths, id: \.self) { l in
                        filterChip(l, isSelected: lengthFilter == l) { lengthFilter = l }
                    }
                }
            }

            Text("共 \(filteredStyles.count) 款发型")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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
}

#Preview {
    HairLibraryView()
}
