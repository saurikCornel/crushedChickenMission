import Foundation
import SwiftUI

struct PreloaderView: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Image(.dashLine)
                        .resizable()
                        .frame(height: geometry.size.height)
                    Spacer()
                    Image(.dashLine)
                        .resizable()
                        .frame(height: geometry.size.height)
                }
                VStack(spacing: 20) {
                    
                    
                    Image(.andrew)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.8)
                    
                    Image(.logoText)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.8)
                    
                    
                    
                    
                    Spacer()
                    
                    ZStack {
                        
                        Rectangle()
                            .frame(height: 50)
                            .foregroundColor(.clear)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.3), .gray.opacity(0.2)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red, .orange]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        // Зеленый прогресс с анимацией
                        ZStack {
                            Rectangle()
                                .frame(height: 50)
                                .foregroundColor(.clear)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.red, .orange, .red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(progress), alignment: .leading)
                                .cornerRadius(12)
                                .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 0)
                            Text("Loading: \(Int(progress * 100))%")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .orange.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    }
                    .frame(width: geometry.size.width - 40) // Отступы по 20 с каждой стороны
                    
                    // Текст с улучшенным стилем
                    
                    
                    Spacer()
                }
            }
            .frame(width: geometry.size.width)
            .background(
                Image(.back)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    PreloaderView(progress: 0.75)
}
