//
//  NotesItem+CoreDataProperties.swift
//  NotesApp
//
//  Created by Анна Вертикова on 26.12.2022.
//
//

import Foundation
import CoreData


extension NotesItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotesItem> {
        return NSFetchRequest<NotesItem>(entityName: "NotesItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var noteBody: NSObject?
    @NSManaged public var noteTitle: String?
    @NSManaged public var noteImage: Data?

}

extension NotesItem : Identifiable {

}
