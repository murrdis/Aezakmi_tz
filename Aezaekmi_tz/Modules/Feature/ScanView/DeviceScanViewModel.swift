//
//  DeviceScanViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import Foundation
import Combine
import SwiftUI

enum ScanType {
    case bluetooth
    case lan
}

protocol DeviceScanViewModel: ObservableObject {
    var scanType: ScanType { get }
    var title: String { get }
    var description: String { get }
    var deviceImage: Image { get }
    var foundDevices: [any ScannableDevice] { get }
    var isScanning: Bool { get }
    var scanProgress: Double { get set }
    var alertTitle: String? { get set }
    var alertMessage: String? { get set }
    
    func scanButtonWasTapped()
    func deviceWasTapped(deviceID: UUID)
}
