//
//  CoreDataManager.swift
//  Aezaekmi_tz
//
//  Created by Диас Мурзагалиев on 03.02.2025.
//


import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Aezaekmi_tz")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error.localizedDescription)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
