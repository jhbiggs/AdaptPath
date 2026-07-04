//
//  SplashView.swift
//  AdaptPath-iOS
//
//  Created by Justin Biggs on 7/4/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.blue.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                    
                    VStack(spacing: 8) {
                        Text("AdaptPath")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Personalized Learning Accommodations")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    ProgressView()
                        .tint(.white)
                }
                .padding(40)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}


#Preview {
    SplashView()
}
