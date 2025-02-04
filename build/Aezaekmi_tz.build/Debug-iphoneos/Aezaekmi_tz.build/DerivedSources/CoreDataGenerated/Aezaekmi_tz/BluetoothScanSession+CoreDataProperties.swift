//
//  BluetoothScanSession+CoreDataProperties.swift
//  
//
//  Created by Диас Мурзагалиев on 03.02.2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BluetoothScanSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BluetoothScanSession> {
        return NSFetchRequest<BluetoothScanSession>(entityName: "BluetoothScanSession")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var devices: NSSet?

}

// MARK: Generated accessors for devices
extension BluetoothScanSession {

    @objc(addDevicesObject:)
    @NSManaged public func addToDevices(_ value: BluetoothDeviceEntity)

    @objc(removeDevicesObject:)
    @NSManaged public func removeFromDevices(_ value: BluetoothDeviceEntity)

    @objc(addDevices:)
    @NSManaged public func addToDevices(_ values: NSSet)

    @objc(removeDevices:)
    @NSManaged public func removeFromDevices(_ values: NSSet)

}

extension BluetoothScanSession : Identifiable {

}
