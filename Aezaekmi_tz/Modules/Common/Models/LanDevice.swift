//
//  LanDevice.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import Foundation

struct LanDevice: ScannableDevice {
    var id: UUID = UUID()
    var name: String?
    var ipAddress: String
    var macAddress: String?

    var details: [(String, String)] {
        [
            ("IP Address", ipAddress),
            ("MAC Address", formattedMacAddress)
        ]
    }
    
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        } else {
            return ipAddress
        }
    }
    
    private var formattedMacAddress: String {
        return (macAddress == "02:00:00:00:00:00" || macAddress?.isEmpty == true || macAddress == nil) ? "Private MAC" : macAddress!
    }
}

extension LanDevice {
    init(from entity: LanDeviceEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name
        self.ipAddress = entity.ipAddress ?? "Unknown IP"
        self.macAddress = entity.macAddress
    }
}
