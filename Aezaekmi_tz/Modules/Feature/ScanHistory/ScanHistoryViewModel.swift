//
//  ScanHistoryViewModel.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 05.02.2025.
//


import SwiftUI
import CoreData

protocol ScanHistoryViewModel: ObservableObject {
    associatedtype DeviceType: ScannableDevice
    var scanSessions: [ScanSession<DeviceType>] { get set }
    var selectedDevice: (any ScannableDevice)? { get set }
    var deviceSearchFilter: String { get set }
    var startDate: Date { get set }
    var endDate: Date { get set }
    var shouldBeFilteredByDate: Bool { get set }
    var showDatePicker: Bool { get set }
    var promptText: String { get }
    
    func fetchScanSessions()
    func filteredSessions() -> [ScanSession<DeviceType>]
    func filteredDevices(session: ScanSession<DeviceType>) -> [DeviceType]
    func formattedDate(for date: Date?) -> String
    func clearDateFilter()
}

extension ScanHistoryViewModel {
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    func formattedDate(for date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        return dateFormatter.string(from: date)
    }

    func clearDateFilter() {
        startDate = Date()
        endDate = startDate
        shouldBeFilteredByDate = false
        showDatePicker = false
    }
}
