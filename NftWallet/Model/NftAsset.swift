import Foundation

struct NftAsset: Equatable, Identifiable, Hashable {
    var id: String {
        return data.id
    }

    let data: NftAssetResponse
}
