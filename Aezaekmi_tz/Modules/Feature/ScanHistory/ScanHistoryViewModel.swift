//
//  ScanHistoryViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import SwiftUI
import CoreData

class ScanHistoryViewModel: ObservableObject {
    @Published var scanSessions: [BluetoothScanSession] = []
    @Published var selectedDevice: (any ScannableDevice)?
    @Published var deviceNameFilter: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var shouldBeFilteredByDate: Bool = false
    @Published var showDatePicker = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
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
                BluetoothScanSession(scanDate: session.scanDate ?? Date(), devices: session.devicesArray)
            }
        } catch {
            print("Failed to fetch scan sessions: \(error.localizedDescription)")
        }
    }
    
    func filteredSessions() -> [BluetoothScanSession] {
        return scanSessions.filter { session in
            let isWithinDateRange = !shouldBeFilteredByDate || (session.scanDate >= startDate && session.scanDate <= endDate)
            
            let filteredDevices = filteredDevices(session: session)
            
            return isWithinDateRange && !filteredDevices.isEmpty
        }
    }
    
    func filteredDevices(session: BluetoothScanSession) -> [BluetoothDevice] {
        var devices = session.devices
        if !deviceNameFilter.isEmpty {
            devices = session.devices.filter { device in
                let nameMatches = device.name?.lowercased().contains(deviceNameFilter.lowercased()) ?? false
                let idMatches = device.id.uuidString.lowercased().contains(deviceNameFilter.lowercased())
                return nameMatches || idMatches
            }
        }
        return devices
    }

    
    func formattedDate(for date: Date?) -> String {
        guard let date = date else {
            return "Unknown Date"
        }
        return dateFormatter.string(from: date)
    }
    
    func clearDateFilter() {
        startDate = Date()
        endDate = startDate
        shouldBeFilteredByDate = false
        showDatePicker = false
    }
}


extension BluetoothScanSessionEntity {
    var devicesArray: [BluetoothDevice] {
        guard let devicesSet = devices as? Set<BluetoothDeviceEntity> else { return [] }
        return devicesSet.compactMap { BluetoothDevice(from: $0) }
    }
}

