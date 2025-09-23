//
//  Item.swift
//  RecipeGenie
//
//  Created by Shana Russell on 9/23/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
