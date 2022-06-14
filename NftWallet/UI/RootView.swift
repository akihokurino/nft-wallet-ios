import ComposableArchitecture
import SwiftUI

struct RootView: View {
    let store: Store<RootVM.State, RootVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                NavigationView {
                    IfLetStore(
                        store.scope(
                            state: { $0.nftListView },
                            action: RootVM.Action.nftListView
                        ),
                        then: NftListView.init(store:)
                    )
                }
                .tabItem {
                    VStack {
                        Image(systemName: "folder")
                        Text("NFT")
                    }
                }.tag(1)

                NavigationView {
                    IfLetStore(
                        store.scope(
                            state: { $0.photoListView },
                            action: RootVM.Action.photoListView
                        ),
                        then: ImageListView.init(store:)
                    )
                }
                .tabItem {
                    VStack {
                        Image(systemName: "camera.fill")
                        Text("カメラロール")
                    }
                }.tag(2)

                NavigationView {
                    IfLetStore(
                        store.scope(
                            state: { $0.walletView },
                            action: RootVM.Action.walletView
                        ),
                        then: WalletView.init(store:)
                    )
                }
                .tabItem {
                    VStack {
                        Image(systemName: "wallet.pass")
                        Text("ウォレット")
                    }
                }.tag(3)
            }
            .onAppear {
                viewStore.send(.startInitialize)
            }
        }
    }
}
