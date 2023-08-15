import Alamofire
import BigInt
import Foundation
import web3swift

class GetNftAssetsRequest: OpenSeaRequestProtocol {
    typealias ResponseType = GetNftAssetsResponse
    
    let owner: EthereumAddress
    let limit: Int
    
    init(owner: EthereumAddress, limit: Int) {
        self.owner = owner
        self.limit = limit
    }
    
    var parameters: Parameters? {
        return [
            "limit": limit
        ]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/v2/chain/mumbai/account/\(owner.address)/nfts"
    }

    var allowsConstrainedNetworkAccess: Bool {
        return false
    }
}

struct GetNftAssetsResponse: Codable, Equatable {
    let nfts: [NftAssetResponse]
}

struct NftAssetResponse: Codable, Identifiable, Equatable, Hashable {
    var id: String {
        return "\(contract)#\(identifier)"
    }
    
    let identifier: String
    let contract: String
    let token_standard: String
    let name: String?
    let description: String?
    let image_url: String?
}
