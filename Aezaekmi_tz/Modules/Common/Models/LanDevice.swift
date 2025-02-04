//
//  LanDevice.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import Foundation

struct LanDevice: ScannableDevice {
    var id: UUID
    var name: String?
    var ipAddress: String
    var macAddress: String?

    var details: [(String, String)] {
        [
            ("IP Address", ipAddress),
            ("MAC Address", macAddress ?? "")
        ]
    }
}
