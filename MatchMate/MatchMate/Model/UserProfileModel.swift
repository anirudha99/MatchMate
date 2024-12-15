//
//  UserProfileModel.swift
//  MatchMate
//
//  Created by Anirudha SM on 15/12/24.
//
import Foundation

struct UserProfile: Identifiable, Codable {
    var id = UUID()
    let name: String
    let age: Int
    let location: String
    let imageURL: String
    var status: MatchStatus

    enum MatchStatus: String, Codable {
        case accepted = "Accepted"
        case declined = "Declined"
        case pending = "Pending"
    }
}
