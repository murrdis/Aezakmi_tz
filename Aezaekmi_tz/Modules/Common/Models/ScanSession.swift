//
//  ScanSession.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//

import Foundation

struct ScanSession<DeviceType: ScannableDevice> {
    var scanDate: Date
    var devices: [DeviceType]
}
