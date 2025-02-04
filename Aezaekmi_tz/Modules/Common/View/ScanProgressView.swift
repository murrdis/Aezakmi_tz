//
//  ScanProgressView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 03.02.2025.
//


import SwiftUI
import Lottie

struct ScanProgressView: View {
    @Binding var scanProgress: Double

    var body: some View {
        LottieView {
            try await DotLottieFile.named("progress").animationSource
        }
        .currentProgress(scanProgress)
        .frame(width: 200, height: 200)
        .cornerRadius(12)
    }
}
