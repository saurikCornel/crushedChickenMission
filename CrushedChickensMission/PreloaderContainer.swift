import Foundation
import SwiftUI
import WebKit

struct PreloaderContainer: View {
    @StateObject var viewModel: GameLoaderModel
    
    init(viewModel: GameLoaderModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            GameHolder(viewModel: viewModel)
                .opacity(viewModel.loadingState == .loaded ? 1 : 0.5)
            
            if case .loading(let progress) = viewModel.loadingState {
                GeometryReader { geo in
                    PreloaderView(progress: progress)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .background(Color.black)
                }
            } else if case .failed(let error) = viewModel.loadingState {
                Text("Err: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else if case .noInternet = viewModel.loadingState {
                Text("")
            }
        }
    }
}
