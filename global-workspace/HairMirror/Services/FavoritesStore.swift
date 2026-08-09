import Foundation

/// 收藏管理：仅存发型 ID 到本机 UserDefaults，绝不上传
@MainActor
final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    @Published private(set) var favoriteIDs: Set<String>

    private let defaults = UserDefaults.standard

    private enum Key {
        static let favorites = "favorites.ids"
    }

    private init() {
        let saved = defaults.stringArray(forKey: Key.favorites) ?? []
        favoriteIDs = Set(saved)
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggle(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        defaults.set(Array(favoriteIDs), forKey: Key.favorites)
        UsageStats.shared.recordFavorite()
    }

    /// 清空全部收藏（隐私：一键删除本地数据）
    func resetAll() {
        favoriteIDs = []
        defaults.removeObject(forKey: Key.favorites)
    }

    /// 收藏的发型（顺序以当前收藏集为准，可能变化）
    func favoriteStyles(from library: [HairStyle]) -> [HairStyle] {
        let byID = Dictionary(uniqueKeysWithValues: library.map { ($0.id, $0) })
        return favoriteIDs.compactMap { byID[$0] }
    }
}
