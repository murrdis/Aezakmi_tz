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
    
    var body: some View {
        List {
            NavigationLink(destination: DeviceScanView(viewModel: BluetoothScanViewModel())) {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Bluetooth")
                }
            }
            
            NavigationLink(destination: EmptyView()) {
                HStack {
                    Image(systemName: "wifi")
                    Text("LAN (Wi-Fi)")
                }
            }
        }
        .navigationTitle("BlueLan")
        .navigationBarBackButtonHidden(true)
    }
}
