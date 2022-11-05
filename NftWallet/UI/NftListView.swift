import ComposableArchitecture
import SwiftUI

struct NftListView: View {
    let store: Store<NftListVM.State, NftListVM.Action>

    static let gridItemSize = UIScreen.main.bounds.size.width / 2
    private let gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                LazyVGrid(columns: gridItemLayout, alignment: HorizontalAlignment.leading, spacing: 2) {
                    ForEach(viewStore.state.assets.filter { $0.data.image_url != nil }, id: \.id) { asset in
                        NftView(asset: asset)
                            .onTapGesture {
                                if let link = asset.data.permalink {
                                    UIApplication.shared.open(URL(string: link)!)
                                }
                            }
                            .padding(.vertical, 10)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 10)
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
                            send: NftListVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
            .refreshable {
                await viewStore.send(.startRefresh, while: \.shouldPullToRefresh)
            }
        }
    }
}

struct NftView: View {
    let asset: NftAsset

    var body: some View {
        AsyncImage(url: URL(string: asset.data.image_url!)) { phase in
            if let image = phase.image {
                VStack(alignment: .leading) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                    Spacer()
                    Text(asset.data.name ?? "").font(.headline)
                    Spacer().frame(height: 5)
                    Text("\(asset.data.asset_contract.schema_name)").font(.caption)
                }
            } else {
                ProgressView()
                    .frame(height: 60, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
