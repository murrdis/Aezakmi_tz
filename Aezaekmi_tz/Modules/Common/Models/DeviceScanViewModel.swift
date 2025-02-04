//
//  DeviceScanViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import Foundation
import Combine

protocol DeviceScanViewModel: ObservableObject {
    var title: String { get }
    var description: String { get }
    var imageName: String { get }
    var foundDevices: [any ScannableDevice] { get }
    var isScanning: Bool { get }
    var scanProgress: Double { get set }
    var alertTitle: String? { get set }
    var alertMessage: String? { get set }
    
    func scanButtonWasTapped()
    func deviceWasTapped(deviceID: UUID)
}

protocol ScannableDevice: Identifiable {
    var id: UUID { get }
    var name: String? { get }
    var details: [(String, String)] { get }
}
