import ComposableArchitecture
import SDWebImage
import SDWebImageSwiftUI
import SwiftUI
import UIKit

struct MintNftView: View {
    let store: Store<MintNftVM.State, MintNftVM.Action>

    @State private var image: UIImage? = nil
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var scaleValue: CGFloat = 1.0
    @State private var lastValue: CGFloat = 1.0
    @State private var frameSize: CGSize = .zero
    @State private var framePath = Path()
    @State private var cropRect: CGRect = .zero
    @State private var shouldHideFrame: Bool = false

    var cropView: some View {
        WithViewStore(store) { _ in
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(lastValue * scaleValue)
                        .offset(x: self.currentPosition.width, y: self.currentPosition.height)

                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                        .mask(framePath.fill(style: FillStyle(eoFill: true)))

                    if !shouldHideFrame {
                        FrameForegroundView(frameSize: $frameSize)
                            .frame(width: frameSize.width, height: frameSize.height)
                    }
                }
            }
        }
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            let dragGesture = DragGesture()
                .onChanged { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                }
                .onEnded { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    self.newPosition = self.currentPosition
                }

            let magnificationGesture = MagnificationGesture()
                .onChanged { value in
                    self.scaleValue = value
                }
                .onEnded { _ in
                    self.lastValue *= self.scaleValue
                    self.scaleValue = 1
                }

            let simultaneous = SimultaneousGesture(dragGesture, magnificationGesture)

            VStack {
                cropView
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .clipped()
                    .gesture(simultaneous)
                    .background(FrameBackgroundView(rect: $cropRect, frameSize: $frameSize))
                    .onAppear {
                        frameSize = CGSize(width: 250, height: 250)
                        framePath = holeShapeMask()
                        self.image = viewStore.asset
                    }

                Spacer().frame(height: 20)

                Group {
                    HStack {
                        ActionButton(text: "NFTを発行する", buttonType: .primary) {
                            shouldHideFrame = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let paylaod = RegisterNftPayload(
                                    image: convertViewToImage()
                                )
                                viewStore.send(.mint(paylaod))
                            }
                        }

                        ActionButton(text: "キャンセル", buttonType: .caution) {
                            viewStore.send(.back)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: MintNftVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
        }
    }

    func convertViewToImage() -> UIImage {
        return UIApplication.shared.windows[0].rootViewController!.presentedViewController!.view.asImage(rect: cropRect)
    }

    func holeShapeMask() -> Path {
        let frameWidth = frameSize.width
        let frameHeight = frameSize.height
        let x = (UIScreen.main.bounds.width - frameWidth) / 2
        let y = (UIScreen.main.bounds.width - frameHeight) / 2

        var shape = Rectangle()
            .path(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        shape.addPath(RoundedRectangle(cornerRadius: 0).path(in: CGRect(x: x, y: y, width: frameWidth, height: frameHeight)))
        return shape
    }
}

struct FrameForegroundView: View {
    @Binding var frameSize: CGSize

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(style:
                StrokeStyle(
                    lineWidth: 5
                ))
            .fill(Color.white)
    }
}

struct FrameBackgroundView: View {
    @Binding var rect: CGRect
    @Binding var frameSize: CGSize

    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        let fixedWidth = frameSize.width
        let fixedHeight = frameSize.height

        let size = CGSize(width: fixedWidth, height: fixedHeight)

        DispatchQueue.main.async {
            let globalRect = proxy.frame(in: .global)
            let origin = CGPoint(x: globalRect.midX - size.width / 2, y: globalRect.midY - size.height / 2)
            self.rect = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        }
        return Rectangle().fill(Color.clear)
    }
}
