//
//  LanScanViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import SwiftUI
import Combine

class LanScanViewModel: ObservableObject, DeviceScanViewModel {
    let scanType: ScanType = .lan
    let title = "Wi-Fi"
    let description = "Scan for devices connected to the network."
    let deviceImage = Image(systemName: "wifi")
    
    @Published var foundDevices: [any ScannableDevice] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var alertTitle: String? = nil
    @Published var alertMessage: String? = nil

    private let lanService: LanService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.lanService = LanService()
        lanService.$foundDevices
            .map { $0.map { $0 as any ScannableDevice } }
            .receive(on: DispatchQueue.main)
            .assign(to: \.foundDevices, on: self)
            .store(in: &cancellables)
        
        lanService.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: \.isScanning, on: self)
            .store(in: &cancellables)
        
        lanService.$scanProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.scanProgress, on: self)
            .store(in: &cancellables)
        
        subscribeToScanEvents()
    }
    
    private func subscribeToScanEvents() {
        lanService.scanEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .networkUnavailable:
                    self?.alertTitle = "No Network"
                    self?.alertMessage = "Please connect to a Wi-Fi network to scan."
                case .scanCompleted(let count):
                    self?.alertTitle = "Scan Completed"
                    self?.alertMessage = "Devices found: \(count)."
                case .scanError(let message):
                    self?.alertTitle = "Error"
                    self?.alertMessage = message
                }
            }
            .store(in: &cancellables)
    }
    
    func scanButtonWasTapped() {
        isScanning ? lanService.stopScan() : lanService.startScan()
    }
    
    func deviceWasTapped(deviceID: UUID) { }
}
