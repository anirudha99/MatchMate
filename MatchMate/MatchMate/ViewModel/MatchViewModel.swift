//
//  MatchViewModel.swift
//  MatchMate
//
//  Created by Anirudha SM on 15/12/24.
//

import Foundation
import SwiftUI
import CoreData
import Alamofire
import SDWebImageSwiftUI
import Combine

class MatchViewModel: ObservableObject {
    @Published var profiles: [UserProfile] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadCachedProfiles()
    }

    // Fetch profiles from the API
    func fetchProfiles() {
        AF.request("https://randomuser.me/api/?results=10")
            .validate()
            .responseDecodable(of: APIResponse.self) { response in
                switch response.result {
                case .success(let data):
                    let newProfiles = data.results.map {
                        UserProfile(
                            name: "\($0.name.first) \($0.name.last)",
                            age: $0.dob.age,
                            location: $0.location.city,
                            imageURL: $0.picture.large,
                            status: .pending
                        )
                    }
                    
                    // Save new profiles to Core Data
                    self.saveProfilesToCache(profiles: newProfiles)
                    // Update in-memory profiles
                    self.loadCachedProfiles()
                    
                case .failure(let error):
                    print("API error: \(error.localizedDescription)")
                }
            }
    }
    
    // Update a profile's status
    func updateProfileStatus(_ profile: UserProfile, status: UserProfile.MatchStatus) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index].status = status
            
            // Update Core Data
            let fetchRequest: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", profile.id.uuidString)
            
            do {
                if let entityToUpdate = try context.fetch(fetchRequest).first {
                    entityToUpdate.status = status.rawValue
                    try context.save()
                } else {
                    print("Error: No matching UserProfileEntity found.")
                }
            } catch {
                print("Error updating profile status in Core Data: \(error)")
            }
            objectWillChange.send()
        }
    }

    // Save profiles to Core Data
    private func saveProfilesToCache(profiles: [UserProfile]) {
        for profile in profiles {
            let fetchRequest: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", profile.id.uuidString)
            
            do {
                let existingProfiles = try context.fetch(fetchRequest)
                if let existingProfile = existingProfiles.first {
                    // Update existing profile
                    existingProfile.name = profile.name
                    existingProfile.age = Int16(profile.age)
                    existingProfile.location = profile.location
                    existingProfile.imageURL = profile.imageURL
                    existingProfile.status = profile.status.rawValue
                } else {
                    // Create a new profile
                    let newProfile = UserProfileEntity(context: context)
                    newProfile.uuid = profile.id
                    newProfile.name = profile.name
                    newProfile.age = Int16(profile.age)
                    newProfile.location = profile.location
                    newProfile.imageURL = profile.imageURL
                    newProfile.status = profile.status.rawValue
                }
            } catch {
                print("Error saving profiles to Core Data: \(error)")
            }
        }
        
        // Save changes
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    // Load cached profiles from Core Data
    private func loadCachedProfiles() {
        let fetchRequest: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        
        do {
            let cachedEntities = try context.fetch(fetchRequest)
            self.profiles = cachedEntities.map { convertToUserProfile(entity: $0) }
        } catch {
            print("Error loading cached profiles: \(error.localizedDescription)")
        }
    }

    // Convert UserProfileEntity to UserProfile
    private func convertToUserProfile(entity: UserProfileEntity) -> UserProfile {
        return UserProfile(
            id: entity.uuid ?? UUID(),
            name: entity.name ?? "",
            age: Int(entity.age),
            location: entity.location ?? "",
            imageURL: entity.imageURL ?? "",
            status: UserProfile.MatchStatus(rawValue: entity.status ?? "pending") ?? .pending
        )
    }
}

