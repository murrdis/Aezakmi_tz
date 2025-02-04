//
//  DeviceScanView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 01.02.2025.
//

import SwiftUI

struct DeviceScanView<ViewModel: DeviceScanViewModel>: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ViewModel
    @State private var selectedDevice: (any ScannableDevice)?
    @State private var showHistory = false
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScanHeader()
                List {
                    if viewModel.foundDevices.count > 0 {
                        Section(header: Text("DEVICES NEARBY (\(viewModel.foundDevices.count))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        ) {
                            ForEach(viewModel.foundDevices, id: \.id) { device in
                                DeviceCellView(
                                    device: device,
                                    onDeviceTapped: { viewModel.deviceWasTapped(deviceID: $0.id) },
                                    onInfoTapped: { selectedDevice = $0 }
                                )
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.alertMessage != nil },
                set: { _ in viewModel.alertMessage = nil }
            )) {
                if viewModel.alertTitle == "Bluetooth Permission Denied" {
                    return Alert(
                        title: Text(viewModel.alertTitle ?? "Unknown error."),
                        message: Text(viewModel.alertMessage ?? "Please try again"),
                        primaryButton: .default(Text("Settings"), action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                } else {
                    return Alert(
                        title: Text(viewModel.alertTitle ?? "Unknown error."),
                        message: Text(viewModel.alertMessage ?? "Please try again"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .background(
                NavigationLink(
                    destination: selectedDevice.map { DeviceDetailsView(device: $0) },
                    isActive: Binding(
                        get: { selectedDevice != nil },
                        set: { if !$0 { selectedDevice = nil } }
                    )
                ) { EmptyView() }
            )
            .disabled(viewModel.isScanning)
            if viewModel.isScanning {
                Color.black.opacity(1)
                    .edgesIgnoringSafeArea(.all)
                ScanProgressView(scanProgress: $viewModel.scanProgress)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isScanning)
            }
        }
    }
    
    @ViewBuilder func ScanHeader() -> some View {
        VStack(spacing: 15) {
            viewModel.deviceImage
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text(viewModel.title)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            
            Text(viewModel.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            HStack(spacing: 10) {
                Button(action: {
                    viewModel.scanButtonWasTapped()
                }) {
                    Text(viewModel.isScanning ? "Stop scanning" : "Scan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                        .padding(.horizontal, 20)
                }
                
                Button(action: {
                    showHistory = true
                }) {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(10)
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                }
                .background(
                    NavigationLink(
                        destination: Group {
                            switch viewModel.scanType {
                            case .bluetooth:
                                ScanHistoryView(viewContext: viewContext, viewModel: BluetoothScanHistoryViewModel(viewContext: viewContext))
                            case .lan:
                                ScanHistoryView(viewContext: viewContext, viewModel: LanScanHistoryViewModel(viewContext: viewContext))
                            }
                        },
                        isActive: $showHistory
                    ) { EmptyView() }
                    .hidden()
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
}
