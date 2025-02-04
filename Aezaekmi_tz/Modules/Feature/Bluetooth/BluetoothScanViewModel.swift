//
//  BluetoothScanViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 01.02.2025.
//

import SwiftUI
import CoreBluetooth
import Combine

class BluetoothScanViewModel: ObservableObject, DeviceScanViewModel {
    let title = "Bluetooth"
    let description = "Scan for available Bluetooth devices within range."
    let imageName: String = "bluetooth"
    
    @Published var foundDevices: [any ScannableDevice] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var connectedPeripheral: CBPeripheral?
    @Published var alertTitle: String? = nil {
        didSet {
            print("alertTitle: \(alertTitle)")
        }
        
    }
    @Published var alertMessage: String? = nil {
        didSet {
            print("alertMessage: \(alertMessage)")
        }
    }

    private let bluetoothService: BluetoothService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.bluetoothService = BluetoothService()
        bluetoothService.$foundDevices
            .map { $0.map { $0 as any ScannableDevice } }
            .receive(on: DispatchQueue.main)
            .assign(to: \.foundDevices, on: self)
            .store(in: &cancellables)
        
        bluetoothService.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: \.isScanning, on: self)
            .store(in: &cancellables)
        
        bluetoothService.$scanProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.scanProgress, on: self)
            .store(in: &cancellables)
        
        bluetoothService.$connectedPeripheral
            .receive(on: DispatchQueue.main)
            .assign(to: \.connectedPeripheral, on: self)
            .store(in: &cancellables)
        
        subcribeToPublishers()
    }
    
    private func subcribeToPublishers() {
        bluetoothService.connectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.alertTitle = "Connection error"
                
                switch event {
                case .connectionTimedOut(let peripheral):
                    self?.alertMessage = "Connection to \(peripheral.name ?? "device with UUID: \(peripheral.identifier)") timed out."
                case .failedToConnect(let peripheral, let error):
                    self?.alertMessage = "Failed to connect to \(peripheral.name ?? "device with UUID: \(peripheral.identifier)"): \(error?.localizedDescription ?? "Unknown error")"
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        bluetoothService.scanEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .bluetoothTurnedOff:
                    self?.alertTitle = "Bluetooth is Off"
                    self?.alertMessage = "Please enable Bluetooth in settings to continue scanning."
                case .bluetoothUnavailable:
                    self?.alertTitle = "Bluetooth Permission Denied"
                    self?.alertMessage = "This app does not have permission to use Bluetooth. Please enable Bluetooth access in Settings."
                case .scanCompleted(let count):
                    self?.alertTitle = "Scan is completed!"
                    self?.alertMessage = "Devices found: \(count)."
                case .scanError(let message):
                    self?.alertTitle = "Error"
                    self?.alertMessage = message
                }
            }
            .store(in: &cancellables)
    }
    
    func scanButtonWasTapped() {
        isScanning ? bluetoothService.stopScan() : bluetoothService.startScan()
    }
    
    func deviceWasTapped(deviceID: UUID) {
        if connectedPeripheral?.identifier == deviceID && connectedPeripheral?.state == .connected {
            bluetoothService.disconnectFromDevice()
        } else {
            bluetoothService.connect(to: deviceID)
        }
    }
}
