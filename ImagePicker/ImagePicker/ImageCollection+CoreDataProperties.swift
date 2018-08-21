//
//  ImageCollection+CoreDataProperties.swift
//  ImagePicker
//
//  Created by Admin on 8/19/18.
//  Copyright © 2018 Marmeto. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageCollection> {
        return NSFetchRequest<ImageCollection>(entityName: "ImageCollection")
    }

    @NSManaged public var image: String?
    @NSManaged public var caption: String?

}
