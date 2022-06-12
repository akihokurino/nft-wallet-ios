import Foundation

struct NftAsset: Equatable, Identifiable, Hashable {
    var id: Int {
        return data.id
    }

    let data: NftAssetResponse
}
