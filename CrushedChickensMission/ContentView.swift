import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameLoaderModel(url: URL(string: "https://crushedchickens.top/play")!)
    
    var body: some View {
        GeometryReader { geo in
            PreloaderContainer(viewModel: viewModel)
                .onReceive(NotificationCenter.default.publisher(for: .networkStatusChanged)) { notification in
                    if let isConnected = notification.object as? Bool {
                        viewModel.updateNetworkStatus(isConnected)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(
            
            Color(hex: 0x1b3a68)
                .ignoresSafeArea()
        )
    }
}
