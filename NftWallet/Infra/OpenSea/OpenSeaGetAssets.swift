import Alamofire
import BigInt
import Foundation
import web3swift

class OpenSeaGetAssetsRequest: OpenSeaRequestProtocol {
    typealias ResponseType = OpenSeaGetAssetsResponse
    
    let owner: EthereumAddress
    let offset: Int
    let limit: Int
    
    init(owner: EthereumAddress, offset: Int, limit: Int) {
        self.owner = owner
        self.offset = offset
        self.limit = limit
    }
    
    var parameters: Parameters? {
        return [
            "offset": offset,
            "limit": limit,
            "owner": owner.address,
        ]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/v1/assets"
    }

    var allowsConstrainedNetworkAccess: Bool {
        return false
    }
}

struct OpenSeaGetAssetsResponse: Codable, Equatable {
    let assets: [NftAssetResponse]
}

struct NftAssetResponse: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let image_url: String
    let name: String
    let description: String
    let permalink: String
    let token_id: String
    let asset_contract: NftContractResponse
}

struct NftContractResponse: Codable, Equatable, Hashable {
    let address: String
    let name: String
    let schema_name: String
    let description: String
    let permalink: String
}
