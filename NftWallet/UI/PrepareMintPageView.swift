import ComposableArchitecture
import SwiftUI
import SwiftUIPager

struct PrepareMintPageView: View {
    let store: Store<PrepareMintPageVM.State, PrepareMintPageVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Picker("", selection: viewStore.binding(
                    get: \.currentSelection,
                    send: PrepareMintPageVM.Action.changePage
                )) {
                    Text("画像生成").tag(0)
                    Text("画像選択").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))

                Pager(
                    page: viewStore.currentPage,
                    data: viewStore.pageIndexes,
                    id: \.hashValue,
                    content: { index in
                        if index == 0 {
                            IfLetStore(
                                store.scope(
                                    state: { $0.textToImageView },
                                    action: PrepareMintPageVM.Action.textToImageView
                                ),
                                then: TextToImageView.init(store:)
                            )
                        } else {
                            IfLetStore(
                                store.scope(
                                    state: { $0.assetListView },
                                    action: PrepareMintPageVM.Action.assetListView
                                ),
                                then: AssetListView.init(store:)
                            )
                        }
                    }
                )
                .onPageChanged { index in
                    viewStore.send(.changePage(index))
                }
            }
            .fullScreenCover(isPresented: viewStore.binding(
                get: \.isPresentedMintNftView,
                send: PrepareMintPageVM.Action.isPresentedMintNftView
            )) {
                IfLetStore(
                    store.scope(
                        state: { $0.mintNftView },
                        action: PrepareMintPageVM.Action.mintNftView
                    ),
                    then: MintNftView.init(store:)
                )
            }
        }
    }
}
