//
//  DateIntervalPickerView.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 04.02.2025.
//


import SwiftUI

struct DateIntervalPickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var shouldBeFilteredByDate: Bool
    var onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 40, height: 5)
                .foregroundColor(Color(.systemGray3))
            Spacer()
            HStack(alignment: .center) {
                Text("From")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                DatePicker(
                    "",
                    selection: $startDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            HStack(alignment: .center) {
                Text("To")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                DatePicker(
                    "",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Button(action: onClear) {
                Text("Clear")
                    .foregroundColor(.red)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}
