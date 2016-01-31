//
//  FeedItem+CoreDataProperties.swift
//  ExchangeAGram
//
//  Created by Trevor Griffin on 1/27/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FeedItem {

    @NSManaged var caption: String?
    @NSManaged var image: NSData?

}
