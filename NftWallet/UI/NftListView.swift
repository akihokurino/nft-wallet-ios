import ComposableArchitecture
import SwiftUI

struct NftListView: View {
    let store: Store<NftListVM.State, NftListVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {}
                .listStyle(PlainListStyle())
                .navigationBarTitle("NFT", displayMode: .inline)
                .onAppear {
                    viewStore.send(.startInitialize)
                }
                .overlay(
                    Group {
                        if viewStore.state.shouldShowHUD {
                            HUD(isLoading: viewStore.binding(
                                get: \.shouldShowHUD,
                                send: NftListVM.Action.shouldShowHUD
                            ))
                        }
                    }, alignment: .center
                )
                .refreshable {
                    viewStore.send(.startRefresh)
                }
        }
    }
}
