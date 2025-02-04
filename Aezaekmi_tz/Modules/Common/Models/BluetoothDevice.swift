//
//  BluetoothDevice.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 01.02.2025.
//


import Foundation
import CoreBluetooth
import SwiftUI

struct BluetoothDevice: ScannableDevice {
    var id: UUID
    var name: String?
    var rssi: Int
    var status: CBPeripheralState?
    
    var details: [(String, String)] {
        [
            ("UUID", id.uuidString),
            ("RSSI", "\(rssi) dBm"),
            ("Status", statusText)
        ]
    }
    
    var statusText: String {
        switch status {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnected: return "Not Connected"
        case .disconnecting: return "Disconnecting..."
        case .none:
            return ""
        @unknown default: return ""
        }
    }
}



extension BluetoothDevice {
    var statusColor: Color {
        switch status {
        case .connected: return .green
        case .connecting: return .green.opacity(0.5)
        case .disconnected: return .gray
        case .disconnecting: return .red.opacity(0.5)
        case .none:
            return .gray
        @unknown default: return .gray
        }
    }
}

extension BluetoothDevice {
    init(from entity: BluetoothDeviceEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name
        self.rssi = Int(entity.rssi)
    }
}
