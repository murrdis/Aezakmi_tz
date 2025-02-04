//
//  BluetoothDeviceEntity+CoreDataProperties.swift
//  
//
//  Created by Диас Мурзагалиев on 03.02.2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BluetoothDeviceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BluetoothDeviceEntity> {
        return NSFetchRequest<BluetoothDeviceEntity>(entityName: "BluetoothDeviceEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var rssi: Int16
    @NSManaged public var status: String?
    @NSManaged public var session: BluetoothScanSession?

}

extension BluetoothDeviceEntity : Identifiable {

}
