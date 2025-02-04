//
//  BluetoothScanHistoryViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import SwiftUI
import CoreData

class BluetoothScanHistoryViewModel: ObservableObject, ScanHistoryViewModel {
    @Published var scanSessions: [ScanSession<BluetoothDevice>] = []
    @Published var selectedDevice: (any ScannableDevice)?
    @Published var deviceSearchFilter: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var shouldBeFilteredByDate = false
    @Published var showDatePicker = false
    var promptText = "Search by device name or UUID"
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.fetchScanSessions()
    }
    
    func fetchScanSessions() {
        let fetchRequest: NSFetchRequest<BluetoothScanSessionEntity> = BluetoothScanSessionEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BluetoothScanSessionEntity.scanDate, ascending: false)]
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            self.scanSessions = result.map { session in
                ScanSession(scanDate: session.scanDate ?? Date(), devices: session.devicesArray)
            }
        } catch {
            print("Failed to fetch scan sessions: \(error.localizedDescription)")
        }
    }
    
    func filteredSessions() -> [ScanSession<BluetoothDevice>] {
        return scanSessions.filter { session in
            let isWithinDateRange = !shouldBeFilteredByDate || (session.scanDate >= startDate && session.scanDate <= endDate)
            
            let filteredDevices = filteredDevices(session: session)
            
            return isWithinDateRange && !filteredDevices.isEmpty
        }
    }
    
    func filteredDevices(session: ScanSession<BluetoothDevice>) -> [BluetoothDevice] {
        var devices = session.devices
        if !deviceSearchFilter.isEmpty {
            devices = session.devices.filter { device in
                let nameMatches = device.name?.lowercased().contains(deviceSearchFilter.lowercased()) ?? false
                let idMatches = device.id.uuidString.lowercased().contains(deviceSearchFilter.lowercased())
                return nameMatches || idMatches
            }
        }
        return devices
    }
}


extension BluetoothScanSessionEntity {
    var devicesArray: [BluetoothDevice] {
        guard let devicesSet = devices as? Set<BluetoothDeviceEntity> else { return [] }
        return devicesSet.compactMap { BluetoothDevice(from: $0) }
    }
}
