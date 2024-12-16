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
import Combine

class MatchViewModel: ObservableObject {
    @Published var profiles: [UserProfile] = []
    private let context: NSManagedObjectContext
    private let networkClient: NetworkClientProtocol

    init(context: NSManagedObjectContext, networkClient: NetworkClientProtocol = NetworkClient()) {
        self.context = context
        self.networkClient = networkClient
        loadCachedProfiles()
    }

    /// Fetch profiles from the API. If offline or the request fails, use cached profiles.
    func fetchProfiles() {
        networkClient.fetchProfiles { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    // Clear existing profiles and use API response
                    self.profiles = data.results.map { apiUser in
                        UserProfile(
                            id: UUID(),
                            name: "\(apiUser.name.first) \(apiUser.name.last)",
                            age: apiUser.dob.age,
                            location: apiUser.location.city,
                            imageURL: apiUser.picture.large,
                            status: .pending
                        )
                    }
                    // Cache the fetched profiles to Core Data
                    self.saveProfilesToCache(profiles: self.profiles)

                case .failure(let error):
                    print("API fetch failed with error: \(error.localizedDescription). Falling back to cached data.")
                    self.loadCachedProfiles() // Load from Core Data when API request fails
                }
            }
        }
    }

    /// Update the status of a user profile and sync with Core Data.
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
                    print("Error: No matching UserProfileEntity found to update.")
                }
            } catch {
                print("Error updating profile status in Core Data: \(error)")
            }

            objectWillChange.send() // Notify UI of changes
        }
    }

    /// Load cached profiles from Core Data.
    func loadCachedProfiles() {
        let fetchRequest: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        
        do {
            let cachedProfiles = try context.fetch(fetchRequest)
            self.profiles = cachedProfiles.map { convertToUserProfile(entity: $0) }
        } catch {
            print("Error loading cached profiles: \(error.localizedDescription)")
        }
    }

    /// Save profiles to Core Data.
    private func saveProfilesToCache(profiles: [UserProfile]) {
        // Remove existing Core Data entries
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserProfileEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest) // Clear old profiles
            try context.save()
        } catch {
            print("Error clearing old cached profiles: \(error)")
        }

        // Add new profiles
        for profile in profiles {
            let entity = UserProfileEntity(context: context)
            entity.uuid = profile.id
            entity.name = profile.name
            entity.age = Int16(profile.age)
            entity.location = profile.location
            entity.imageURL = profile.imageURL
            entity.status = profile.status.rawValue
        }

        // Save the context
        do {
            try context.save()
        } catch {
            print("Error saving new profiles to Core Data: \(error)")
        }
    }

    /// Convert `UserProfileEntity` (Core Data) to `UserProfile` (App Model)
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
