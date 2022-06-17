import BigInt
import Combine
import Foundation
import web3swift

class EthereumManager {
    static let shared = EthereumManager()

    private init() {}

    private var cli: web3 {
        let web3 = web3(provider: Web3HttpProvider(URL(string: Env["CHAIN_URL"]!)!)!)
        let privateKey = DataStore.shared.getPrivateKey()!
        let keystore = try! EthereumKeystoreV3(privateKey: privateKey)!
        let keystoreManager = KeystoreManager([keystore])
        web3.addKeystoreManager(keystoreManager)
        return web3
    }

    private var erc721ABI: String {
        let url = Bundle.main.url(forResource: "NftWallet721.abi", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return String(data: data, encoding: .utf8)!
    }

    private var erc1155ABI: String {
        let url = Bundle.main.url(forResource: "NftWallet1155.abi", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return String(data: data, encoding: .utf8)!
    }

    func mint(address: EthereumAddress, file: IPFS) -> Future<Void, AppError> {
        let erc721 = cli.contract(erc721ABI, at: EthereumAddress(Env["NFT_WALLET_721_ADDRESS"]!)!, abiVersion: 2)!
        let erc1155 = cli.contract(erc1155ABI, at: EthereumAddress(Env["NFT_WALLET_1155_ADDRESS"]!)!, abiVersion: 2)!
        var options = TransactionOptions.defaultOptions
        options.from = address
        options.gasLimit = .manual(BigUInt(5500000))
        options.gasPrice = .manual(BigUInt(35000000000))

        return Future<Void, AppError> { promise in
            do {
                _ = try erc721.write(
                    "mint",
                    parameters: [address.address, file.hash] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)!.send()

                _ = try erc1155.write(
                    "mint",
                    parameters: [address.address, file.hash, 10] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)!.send()

                promise(.success(()))
            } catch {
                print("mint error: \(error)")
                promise(.failure(AppError.plain(error.localizedDescription)))
            }
        }
    }
}
