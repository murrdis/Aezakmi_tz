//
//  LanScanHistoryViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 05.02.2025.
//

import SwiftUI
import CoreData

class LanScanHistoryViewModel: ObservableObject, ScanHistoryViewModel {
    @Published var scanSessions: [ScanSession<LanDevice>] = []
    @Published var selectedDevice: (any ScannableDevice)?
    @Published var deviceSearchFilter: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var shouldBeFilteredByDate = false
    @Published var showDatePicker = false
    var promptText = "Search by device name or IP adress"
    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.fetchScanSessions()
    }

    func fetchScanSessions() {
        let fetchRequest: NSFetchRequest<LanScanSessionEntity> = LanScanSessionEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \LanScanSessionEntity.scanDate, ascending: false)]

        do {
            let result = try viewContext.fetch(fetchRequest)
            self.scanSessions = result.map { session in
                ScanSession(scanDate: session.scanDate ?? Date(), devices: session.devicesArray)
            }
        } catch {
            print("Failed to fetch scan sessions: \(error.localizedDescription)")
        }
    }

    func filteredSessions() -> [ScanSession<LanDevice>] {
        return scanSessions.filter { session in
            let isWithinDateRange = !shouldBeFilteredByDate || (session.scanDate >= startDate && session.scanDate <= endDate)
            let filteredDevices = filteredDevices(session: session)
            return isWithinDateRange && !filteredDevices.isEmpty
        }
    }

    func filteredDevices(session: ScanSession<LanDevice>) -> [LanDevice] {
        var devices = session.devices
        if !deviceSearchFilter.isEmpty {
            let searchQuery = deviceSearchFilter.lowercased()

            devices = session.devices.filter { device in
                let nameMatches = device.name?.lowercased().contains(searchQuery) ?? false
                let ipMatches = device.ipAddress.lowercased().contains(searchQuery)
                return nameMatches || ipMatches
            }
        }
        return devices
    }
}

extension LanScanSessionEntity {
    var devicesArray: [LanDevice] {
        guard let devicesSet = devices as? Set<LanDeviceEntity> else { return [] }
        return devicesSet.compactMap { LanDevice(from: $0) }
    }
}
