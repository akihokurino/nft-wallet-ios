import Foundation

enum Env {
    static let walletSecret = Bundle.main.object(forInfoDictionaryKey: "Wallet Secret") as! String
    static let nftWallet721Address = Bundle.main.object(forInfoDictionaryKey: "Nft Wallet 721 Address") as! String
    static let nftWallet1155Address = Bundle.main.object(forInfoDictionaryKey: "Nft Wallet 1155 Address") as! String
    static let infuraKey = Bundle.main.object(forInfoDictionaryKey: "Infura Key") as! String
    static let ipfsKey = Bundle.main.object(forInfoDictionaryKey: "Ipfs Key") as! String
    static let ipfsSecret = Bundle.main.object(forInfoDictionaryKey: "Ipfs Secret") as! String
    static let openAIApiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI ApiKey") as! String
}
