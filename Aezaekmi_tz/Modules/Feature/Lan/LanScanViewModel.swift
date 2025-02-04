//
//  LanScanViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


//import Foundation
//import Combine
//
//class LanScanViewModel: DeviceScanViewModel {
//    @Published var foundDevices: [any ScannableDevice] = []
//    @Published var isScanning = false
//    @Published var scanProgress: Double = 0.0
//    @Published var alertTitle: String? = nil
//    @Published var alertMessage: String? = nil
//    
//    private var lanScanService = LanScanService()
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        lanScanService.$devices
//            .map { $0.map { $0 as any ScannableDevice } } // ✅ Fixed
//            .assign(to: \.foundDevices, on: self)
//            .store(in: &cancellables)
//        
//        lanScanService.$isScanning
//            .assign(to: \.isScanning, on: self)
//            .store(in: &cancellables)
//        
//        lanScanService.$scanProgress
//            .assign(to: \.scanProgress, on: self)
//            .store(in: &cancellables)
//    }
//    
//    func scanButtonWasTapped() {
//        isScanning ? lanScanService.stopScan() : lanScanService.startScan()
//    }
//    
//    func deviceWasTapped(deviceID: UUID) {
//        // No connection needed for LAN devices
//    }
//}
