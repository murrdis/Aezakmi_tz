//
//  Aezaekmi_tzApp.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 01.02.2025.
//

import SwiftUI

@main
struct Aezaekmi_tzApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
