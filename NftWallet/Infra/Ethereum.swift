import BigInt
import Combine
import Foundation
import secp256k1
import web3swift

class EthereumManager {
    private var cli: web3?
    private var keystore: EthereumKeystoreV3!
    private let password = "web3swift"

    static let shared = EthereumManager()

    private init() {}

    var address: EthereumAddress {
        return keystore.addresses!.first!
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

    func web3Cli() -> web3 {
        if let cli = self.cli {
            return cli
        }
        
        let web3 = web3(provider: Web3HttpProvider(URL(string: "https://polygon-mumbai.infura.io/v3/\(Env.infuraKey)")!)!)
        let keystoreManager = KeystoreManager([keystore])
        web3.addKeystoreManager(keystoreManager)
        cli = web3
        return web3
    }

    func initialize() {
        var privateKey = DataStore.shared.getPrivateKey()
        if privateKey == nil {
            let privateKeyFromEnv = Env.walletSecret
            if privateKeyFromEnv.isEmpty {
                privateKey = SECP256K1.generatePrivateKey()
                DataStore.shared.savePrivateKey(val: privateKey!)
            } else {
                let formattedKey = privateKeyFromEnv.trimmingCharacters(in: .whitespacesAndNewlines)
                privateKey = Data.fromHex(formattedKey)
                DataStore.shared.savePrivateKey(val: privateKey!)
            }
        }

        keystore = try! EthereumKeystoreV3(privateKey: privateKey!, password: password)!
    }

    func balance() throws -> String {
        let balanceWei = try web3Cli().eth.getBalance(address: address)
        return Units.toEtherString(wei: balanceWei)
    }

    func mint(hash: String) -> Future<Void, AppError> {
        let erc721 = web3Cli().contract(erc721ABI, at: EthereumAddress(Env.nftWallet721Address)!, abiVersion: 2)!
        let erc1155 = web3Cli().contract(erc1155ABI, at: EthereumAddress(Env.nftWallet1155Address)!, abiVersion: 2)!
        var options = TransactionOptions.defaultOptions
        options.from = address
        options.gasLimit = .manual(BigUInt(5500000))
        options.gasPrice = .manual(BigUInt(35000000000))

        return Future<Void, AppError> { promise in
            do {
                _ = try erc721.write(
                    "mint",
                    parameters: [self.address.address, hash] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)!.send(password: self.password)

                _ = try erc1155.write(
                    "mint",
                    parameters: [self.address.address, hash, 10] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)!.send(password: self.password)

                promise(.success(()))
            } catch {
                print("mint error: \(error)")
                promise(.failure(AppError.plain(error.localizedDescription)))
            }
        }
    }

    func export() throws -> String {
        let keystoreManager = KeystoreManager([keystore])
        let pkData = try keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: address)
        return pkData.toHexString()
    }
}

enum Units {
    static let etherInWei = pow(Decimal(10), 18)

    static func toEther(wei: BigUInt) -> Decimal? {
        guard let decimalWei = Decimal(string: wei.description) else {
            return nil
        }
        return decimalWei / etherInWei
    }

    static func toEtherString(wei: BigUInt) -> String {
        guard let ether = toEther(wei: wei) else {
            return ""
        }

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        return formatter.string(for: ether) ?? ""
    }

    static func toWei(ether: Decimal) -> BigUInt? {
        guard let wei = BigUInt((ether * etherInWei).description) else {
            return nil
        }
        return wei
    }
}
