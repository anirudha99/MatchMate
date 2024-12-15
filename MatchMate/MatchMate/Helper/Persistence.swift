//
//  Persistence.swift
//  MatchMate
//
//  Created by Anirudha SM on 15/12/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MatchMate")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error.localizedDescription)")
            }
        }
    }
}
