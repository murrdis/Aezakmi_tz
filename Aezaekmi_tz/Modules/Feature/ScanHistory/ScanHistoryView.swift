//
//  ScanHistoryView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 03.02.2025.
//


import SwiftUI
import CoreData

struct ScanHistoryView<ViewModel: ScanHistoryViewModel>: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ViewModel
    
    init(viewContext: NSManagedObjectContext, viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.filteredSessions(), id: \.scanDate) { session in
                    DisclosureGroup("Scan at \(viewModel.formattedDate(for: session.scanDate))") {
                        ForEach(viewModel.filteredDevices(session: session), id: \.id) { device in
                            DeviceCellView(
                                device: device,
                                onInfoTapped: { tappedDevice in
                                    viewModel.selectedDevice = tappedDevice
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Scan History")
            .searchable(text: $viewModel.deviceSearchFilter, prompt: viewModel.promptText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showDatePicker.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            DateIntervalPickerView(
                startDate: $viewModel.startDate,
                endDate: $viewModel.endDate,
                shouldBeFilteredByDate: $viewModel.shouldBeFilteredByDate,
                onClear: {
                    viewModel.clearDateFilter()
                }
            )
            .padding()
        }
        .background(
            NavigationLink(
                destination: viewModel.selectedDevice.map { DeviceDetailsView(device: $0) },
                isActive: Binding(
                    get: { viewModel.selectedDevice != nil },
                    set: { if !$0 { viewModel.selectedDevice = nil } }
                )
            ) { EmptyView() }
        )
        .onChange(of: viewModel.startDate) { _ in
            if viewModel.startDate != viewModel.endDate {
                viewModel.shouldBeFilteredByDate = true
            }
        }
        .onChange(of: viewModel.endDate) { newValue in
            if viewModel.startDate != viewModel.endDate {
                viewModel.shouldBeFilteredByDate = true
            }
        }
    }
}
