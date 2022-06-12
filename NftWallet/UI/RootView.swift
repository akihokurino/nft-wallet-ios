import ComposableArchitecture
import SwiftUI

struct RootView: View {
    let store: Store<RootVM.State, RootVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                NavigationView {}
                    .tabItem {
                        VStack {
                            Image(systemName: "folder")
                            Text("NFT")
                        }
                    }.tag(1)
            }
            TabView {
                NavigationView {}
                    .tabItem {
                        VStack {
                            Image(systemName: "wallet.pass")
                            Text("ウォレット")
                        }
                    }.tag(2)
            }
            .onAppear {
                viewStore.send(.initialize)
            }
        }
    }
}
