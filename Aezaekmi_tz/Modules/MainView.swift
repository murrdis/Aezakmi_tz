//
//  MainView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 01.02.2025.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var lanService: LanService? = LanService()

    var body: some View {
        List {
            NavigationLink(destination: DeviceScanView(viewModel: BluetoothScanViewModel())) {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Bluetooth")
                }
            }
            
            NavigationLink(destination: DeviceScanView(viewModel: LanScanViewModel())) {
                HStack {
                    Image(systemName: "wifi")
                    Text("LAN (Wi-Fi)")
                }
            }
            .onAppear {
                requestLocalNetworkPermission()
            }
        }
        .navigationTitle("BlueLan")
        .navigationBarBackButtonHidden(true)
    }
    
    private func requestLocalNetworkPermission() {
        lanService?.startScan()
        lanService?.stopScan()
        lanService = nil
    }
}
