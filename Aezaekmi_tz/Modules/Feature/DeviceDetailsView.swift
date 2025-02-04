//
//  DeviceDetailsView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 02.02.2025.
//


import SwiftUI
import CoreBluetooth

struct DeviceDetailsView: View {
    let device: any ScannableDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(device.name ?? "Unknown device")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)
            
            List {
                Section(header: Text("About device").font(.caption).foregroundColor(.gray)) {
                    ForEach(device.details, id: \.0) { key, value in
                        HStack {
                            Text(key)
                            Spacer()
                            Text(value)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}



//struct DeviceDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleDevice = BluetoothDevice(id: UUID(), name: "Beats Studio3", rssi: -55, status: .connected)
//        let sampleServices: [CBService] = []
//        
//        DeviceDetailsView(device: sampleDevice)
//            .preferredColorScheme(.dark)
//    }
//}
