//
//  DeviceCellView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 03.02.2025.
//

import SwiftUI

struct DeviceCellView: View {
    var device: any ScannableDevice
    var onDeviceTapped: ((any ScannableDevice) -> Void)?
    var onInfoTapped: (any ScannableDevice) -> Void
    var shouldShowStatus: Bool = true
    
    var body: some View {
        Button(action: {
            onDeviceTapped?(device)
        }) {
            HStack {
                Text(device.name ?? device.id.uuidString)
                Spacer()
                
                if shouldShowStatus, let bluetoothDevice = device as? BluetoothDevice {
                    Text(bluetoothDevice.statusText)
                        .foregroundColor(bluetoothDevice.statusColor)
                }
                
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        onInfoTapped(device)
                    }
                    .padding(.leading, 8)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
