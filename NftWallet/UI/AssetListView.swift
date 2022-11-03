import Combine
import ComposableArchitecture
import SwiftUI

struct AssetListView: View {
    let store: Store<AssetListVM.State, AssetListVM.Action>

    static let gridItemSize = UIScreen.main.bounds.size.width / 2
    private let gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                LazyVGrid(columns: gridItemLayout, alignment: HorizontalAlignment.leading, spacing: 2) {
                    ForEach(viewStore.assets, id: \.self) { asset in
                        AssetView(asset: asset)
                            .frame(maxWidth: AssetListView.gridItemSize)
                            .frame(height: AssetListView.gridItemSize)
                            .onTapGesture {
                                viewStore.send(.showUploadNftView(asset))
                            }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: AssetListVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
            .refreshable {
                await viewStore.send(.startRefresh, while: \.shouldPullToRefresh)
            }
            .fullScreenCover(isPresented: viewStore.binding(
                get: \.isPresentedUploadNftView,
                send: AssetListVM.Action.isPresentedUploadNftView
            )) {
                IfLetStore(
                    store.scope(
                        state: { $0.uploadNftView },
                        action: AssetListVM.Action.uploadNftView
                    ),
                    then: MintNftView.init(store:)
                )
            }
        }
    }
}

struct AssetView: View {
    @ObservedObject var asset: ImageAsset
    @State var image: UIImage? = nil

    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: AssetListView.gridItemSize)
                    .frame(height: AssetListView.gridItemSize)
                    .clipped()

            } else {
                Color
                    .gray
                    .frame(width: AssetListView.gridItemSize)
                    .frame(height: AssetListView.gridItemSize)
            }
        }
        .onAppear {
            asset.request(with: CGSize(width: AssetListView.gridItemSize * 3, height: AssetListView.gridItemSize * 3)) { image in
                self.image = image
            }
        }
    }
}
