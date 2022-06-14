import Combine
import ComposableArchitecture
import SwiftUI

struct ImageListView: View {
    let store: Store<ImageListVM.State, ImageListVM.Action>

    private let gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    static let thumbnailSize = UIScreen.main.bounds.size.width / 2

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVGrid(columns: gridItemLayout, alignment: HorizontalAlignment.leading, spacing: 2) {
                    ForEach(viewStore.assets, id: \.self) { asset in
                        Button(action: {
                            viewStore.send(.showUploadNftView(asset))
                        }) {
                            PhotoAssetView(asset: asset)
                                .frame(maxWidth: ImageListView.thumbnailSize)
                                .frame(height: ImageListView.thumbnailSize)
                        }
                    }
                }
            }
            .navigationBarTitle("カメラロール", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: ImageListVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
            .refreshable {
                viewStore.send(.startRefresh)
            }
            .fullScreenCover(isPresented: viewStore.binding(
                get: \.isPresentedUploadNftView,
                send: ImageListVM.Action.isPresentedUploadNftView
            )) {
                IfLetStore(
                    store.scope(
                        state: { $0.uploadNftView },
                        action: ImageListVM.Action.uploadNftView
                    ),
                    then: UploadNftView.init(store:)
                )
            }
        }
    }
}

struct PhotoAssetView: View {
    @ObservedObject var asset: ImageAsset
    @State var image: UIImage? = nil

    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: ImageListView.thumbnailSize)
                    .frame(height: ImageListView.thumbnailSize)
                    .clipped()

            } else {
                Color
                    .gray
                    .frame(width: ImageListView.thumbnailSize)
                    .frame(height: ImageListView.thumbnailSize)
            }
        }
        .onAppear {
            asset.request(with: CGSize(width: ImageListView.thumbnailSize * 3, height: ImageListView.thumbnailSize * 3)) { image in
                self.image = image
            }
        }
    }
}
