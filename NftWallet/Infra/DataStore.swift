import Foundation

private enum UserDefaultsKey {
    static let suiteName = "group.app.akiho.nft-wallet"
    static let privateKey = "private-key"
}

struct DataStore {
    let store = UserDefaults.standard

    static let shared = DataStore()
    private init() {}


    func getPrivateKey() -> Data? {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        return userDefaults.data(forKey: UserDefaultsKey.privateKey)
    }

    func savePrivateKey(val: Data) {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        userDefaults.set(val, forKey: UserDefaultsKey.privateKey)
    }
}
