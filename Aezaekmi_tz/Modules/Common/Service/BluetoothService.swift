//
//  BluetoothService.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 01.02.2025.
//


import Foundation
import CoreBluetooth
import Combine

enum BluetoothScanEvent {
    case bluetoothTurnedOff
    case bluetoothUnavailable
    case scanCompleted(deviceCount: Int)
    case scanError(String)
}

enum BluetoothConnectionEvent {
    case connected(CBPeripheral)
    case disconnected(CBPeripheral)
    case failedToConnect(CBPeripheral, Error?)
    case connectionTimedOut(CBPeripheral)
}

class BluetoothService: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var scanTimeoutTimer: Timer?
    private var connectionTimeoutTimer: Timer?
    private var scanStartTime: Date?
    private var dontCheckStateAtTheBeggining = true
    
    @Published var foundDevices: [BluetoothDevice] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    
    let connectionEventPublisher = PassthroughSubject<BluetoothConnectionEvent, Never>()
    let scanEventPublisher = PassthroughSubject<BluetoothScanEvent, Never>()
    
    private let scanTimeout: TimeInterval = 15.0
    private let connectionTimeout: TimeInterval = 10.0
    private let rssiThreshold = -80
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func startScan() {
        guard !isScanning else {
            scanEventPublisher.send(.scanError("Scanning is already in progress. Please wait."))
            return
        }
        guard centralManager.state == .poweredOn else {
            checkCentralManagerState(central: centralManager)
            return
        }
        
        foundDevices.removeAll()
        isScanning = true
        scanProgress = 0.0
        scanStartTime = Date()
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        scanTimeoutTimer?.invalidate()
        scanTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.scanStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let duration = self.scanTimeout
            self.scanProgress = min(elapsed / duration, 1.0)
            
            if elapsed >= duration {
                timer.invalidate()
                self.stopScan()
                let count = self.foundDevices.count
                self.scanEventPublisher.send(.scanCompleted(deviceCount: count))
                
                self.saveScanSession()
            }
        }
        
    }
    
    private func checkCentralManagerState(central: CBCentralManager) {
        if central.state != .poweredOn {
            stopScan()
            foundDevices.removeAll()
        }
        
        switch central.state {
        case .unauthorized:
            scanEventPublisher.send(.bluetoothUnavailable)
        case .poweredOff:
            scanEventPublisher.send(.bluetoothTurnedOff)
        case .resetting:
            scanEventPublisher.send(.scanError("Bluetooth is resetting. Please try again later."))
        case .unsupported:
            scanEventPublisher.send(.scanError("This device does not support Bluetooth Low Energy."))
        case .unknown:
            scanEventPublisher.send(.scanError("Unknown Bluetooth error. Please restart the app."))
        case .poweredOn:
            break
        @unknown default:
            scanEventPublisher.send(.scanError("An unexpected Bluetooth error occurred."))
        }
    }
    
    func stopScan() {
        centralManager.stopScan()
        isScanning = false
        scanTimeoutTimer?.invalidate()
        scanTimeoutTimer = nil
    }
}


// MARK: - CBCentralManagerDelegate

extension BluetoothService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if !dontCheckStateAtTheBeggining {
            checkCentralManagerState(central: central)
            dontCheckStateAtTheBeggining = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name
        
        let device = BluetoothDevice(
            id: peripheral.identifier,
            name: deviceName,
            rssi: rssi.intValue,
            status: peripheral.state
        )
        
        if foundDevices.contains(where: { $0.id == device.id }) {
            return
        }
        
        if foundDevices.firstIndex(where: { $0.id == device.id }) == nil && rssi.intValue > rssiThreshold {
            foundDevices.append(device)
        }
    }
    
    func connect(to deviceID: UUID) {
        guard let cbPeripheral = centralManager.retrievePeripherals(withIdentifiers: [deviceID]).first, cbPeripheral.state != .connected else {
            print("Device not found for connection")
            return
        }
        
        if let currentPeripheral = connectedPeripheral {
            disconnectFromDevice()
            updateDeviceStatus(for: currentPeripheral, status: .disconnected)
        }
        
        updateDeviceStatus(for: cbPeripheral, status: .connecting)
        cbPeripheral.delegate = self
        centralManager.connect(cbPeripheral, options: nil)
        
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: connectionTimeout, repeats: false) { [weak self] _ in
            if cbPeripheral.state != .connected {
                self?.centralManager.cancelPeripheralConnection(cbPeripheral)
                self?.updateDeviceStatus(for: cbPeripheral, status: .disconnected)
                self?.connectionEventPublisher.send(.connectionTimedOut(cbPeripheral))
            }
        }
        
    }
    
    func disconnectFromDevice() {
        guard let peripheral = connectedPeripheral else {
            print("Device not found for disconnection")
            return
        }
        print("Disconnecting from \(peripheral.identifier.uuidString)")
        updateDeviceStatus(for: peripheral, status: .disconnecting)
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func updateDeviceStatus(for peripheral: CBPeripheral, status: CBPeripheralState) {
        DispatchQueue.main.async { [ self ] in
            if let index = foundDevices.firstIndex(where: { $0.id == peripheral.identifier }) {
                foundDevices[index].status = status
                if status == .connected || status == .connecting {
                    connectedPeripheral = peripheral
                } else if connectedPeripheral?.identifier == peripheral.identifier {
                    connectedPeripheral = nil
                }
            }
        }
    }
}


// MARK: - CBPeripheralDelegate

extension BluetoothService: CBPeripheralDelegate {
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.identifier.uuidString)")
        updateDeviceStatus(for: peripheral, status: .connected)
        connectionEventPublisher.send(.connected(peripheral))
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = nil
        
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.identifier.uuidString)")
        updateDeviceStatus(for: peripheral, status: .disconnected)
        connectionEventPublisher.send(.failedToConnect(peripheral, error))
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Disconnected from \(peripheral.identifier.uuidString)")
        updateDeviceStatus(for: peripheral, status: .disconnected)
        connectionEventPublisher.send(.disconnected(peripheral))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Found characteristic: \(characteristic.uuid)")
            }
        }
    }
}

// MARK: - CoreData function

import CoreData

extension BluetoothService {
    private func saveScanSession() {
        let context = PersistenceController.shared.container.viewContext
        let session = BluetoothScanSessionEntity(context: context)
        session.scanDate = Date()
        
        for device in foundDevices {
            let deviceEntity = BluetoothDeviceEntity(context: context)
            deviceEntity.id = device.id
            deviceEntity.name = device.name
            deviceEntity.rssi = Int16(device.rssi)
            deviceEntity.status = device.statusText
            
            deviceEntity.session = session
        }
        
        do {
            try context.save()
            print("Scan session saved successfully with \(foundDevices.count) devices.")
        } catch {
            print("Failed to save scan session: \(error)")
        }
    }
}
