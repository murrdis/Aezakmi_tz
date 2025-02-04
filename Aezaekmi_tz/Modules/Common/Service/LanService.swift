//
//  LanService.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import Foundation
import MMLanScan
import Combine
import Network
import CoreData

enum LanScanEvent {
    case networkUnavailable
    case scanCompleted(deviceCount: Int)
    case scanError(String)
}

class LanService: NSObject, ObservableObject {
    @Published var foundDevices: [LanDevice] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var isConnectedToWiFi: Bool = false

    let scanEventPublisher = PassthroughSubject<LanScanEvent, Never>()
    
    private var lanScanner: MMLANScanner?
    private var scanTimeoutTimer: Timer?
    private var scanStartTime: Date?
    private let scanTimeout: TimeInterval = 15.0
    private let networkMonitor = NWPathMonitor()
    
    override init() {
        super.init()
        self.lanScanner = MMLANScanner(delegate: self)
        checkWiFiConnection()
    }
    
    private func checkWiFiConnection() {
        let queue = DispatchQueue.global(qos: .background)
        networkMonitor.start(queue: queue)
        
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnectedToWiFi = path.status == .satisfied && path.usesInterfaceType(.wifi)
            }
        }
    }
    
    func startScan() {
        guard isConnectedToWiFi else {
            scanEventPublisher.send(.networkUnavailable)
            return
        }
        
        guard !isScanning else {
            scanEventPublisher.send(.scanError("Scanning is already in progress."))
            return
        }
        
        foundDevices.removeAll()
        isScanning = true
        scanProgress = 0.0
        scanStartTime = Date()
        
        lanScanner?.start()
        
        scanTimeoutTimer?.invalidate()
        scanTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.scanStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            self.scanProgress = min(elapsed / self.scanTimeout, 1.0)
            
            if elapsed >= self.scanTimeout {
                timer.invalidate()
                self.stopScan()
                self.scanEventPublisher.send(.scanCompleted(deviceCount: self.foundDevices.count))

                self.saveScanSession()
            }
        }
    }
    
    func stopScan() {
        lanScanner?.stop()
        DispatchQueue.main.async {
            self.isScanning = false
        }
        scanTimeoutTimer?.invalidate()
        scanTimeoutTimer = nil
    }
}


// MARK: - MMLANScannerDelegate

extension LanService: MMLANScannerDelegate {
    func lanScanDidFindNewDevice(_ device: MMDevice) {
        let lanDevice = LanDevice(
            name: device.hostname,
            ipAddress: device.ipAddress,
            macAddress: device.macAddress
        )
        
        DispatchQueue.main.async {
            if !self.foundDevices.contains(where: { $0.ipAddress == lanDevice.ipAddress }) {
                self.foundDevices.append(lanDevice)
            }
        }
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {}
    
    func lanScanDidFailedToScan() {
        DispatchQueue.main.async {
            self.isScanning = false
            self.scanEventPublisher.send(.scanError("Failed to scan network."))
        }
    }
}


// MARK: - CoreData function

extension LanService {
    private func saveScanSession() {
        let container = PersistenceController.shared.container
        container.performBackgroundTask { context in
            let session = LanScanSessionEntity(context: context)
            session.scanDate = Date()
            
            for device in self.foundDevices {
                let deviceEntity = LanDeviceEntity(context: context)
                deviceEntity.id = device.id
                deviceEntity.name = device.name
                deviceEntity.ipAddress = device.ipAddress
                deviceEntity.macAddress = device.macAddress
                
                deviceEntity.session = session
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to save LAN scan session: \(error)")
            }
        }
    }
}
