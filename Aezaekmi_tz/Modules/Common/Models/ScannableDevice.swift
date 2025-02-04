//
//  ScannableDevice.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 05.02.2025.
//

import Foundation

protocol ScannableDevice: Identifiable {
    var id: UUID { get }
    var name: String? { get }
    var details: [(String, String)] { get }
    var displayName: String { get }
}
