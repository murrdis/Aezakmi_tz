//
//  LaunchScreenView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//

import SwiftUI
import Lottie

struct LaunchScreenView: View {
    @State private var navigateToMainView = false
    @State private var currentProgress: CGFloat = 0.0
    @State private var isLoaded = false

    var body: some View {
        NavigationView {
            ZStack {
                if isLoaded {
                    VStack {
                        Text("BlueLan")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .transition(.opacity)
                        
                        Text("Seamlessly Scan, Effortlessly Connect.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                            .transition(.opacity)

                        LottieView {
                            try await DotLottieFile.named("launch").animationSource
                        }
                        .currentProgress(currentProgress)
                        .frame(width: 300, height: 300)
                        .transition(.opacity)
                    }
                    .onAppear {
                        startAnimationProgress()
                    }
                }
            }
            .background(
                NavigationLink("", destination: MainView(), isActive: $navigateToMainView)
                    .hidden()
            )
            .onAppear {
                loadAnimation()
            }
        }
    }

    private func loadAnimation() {
        Task {
            do {
                _ = try await DotLottieFile.named("launch").animationSource
                
                DispatchQueue.main.async {
                    withAnimation {
                        isLoaded = true
                    }
                }
            } catch {
                print("Error loading animation: \(error)")
            }
        }
    }

    private func startAnimationProgress() {
        var timer: Timer?
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if currentProgress < 1.0 {
                currentProgress += 0.003
            } else {
                timer?.invalidate()
                transitionToMainView()
            }
        }
    }

    private func transitionToMainView() {
        DispatchQueue.main.async {
            withAnimation {
                navigateToMainView = true
            }
        }
    }
}
