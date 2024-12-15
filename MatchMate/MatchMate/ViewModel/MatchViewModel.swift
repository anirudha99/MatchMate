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

    func fetchProfiles() {
        AF.request("https://randomuser.me/api/?results=10")
            .validate()
            .responseDecodable(of: APIResponse.self) { response in
                switch response.result {
                case .success(let data):
                    let fetchedProfiles = data.results.map {
                        UserProfile(name: "\($0.name.first) \($0.name.last)",
                                    age: $0.dob.age,
                                    location: $0.location.city,
                                    imageURL: $0.picture.large,
                                    status: .pending)
                    }
                    self.profiles = fetchedProfiles
                    self.saveProfilesToCache(fetchedProfiles)
                case .failure(let error):
                    print("API error: \(error.localizedDescription)")
                }
            }
    }

    func updateProfileStatus(_ profile: UserProfile, status: UserProfile.MatchStatus) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index].status = status
            saveProfilesToCache(profiles)
        }
    }

    private func loadCachedProfiles() {
        // Load profiles from Core Data (to be implemented)
    }

    private func saveProfilesToCache(_ profiles: [UserProfile]) {
        // Save profiles to Core Data (to be implemented)
    }
}
