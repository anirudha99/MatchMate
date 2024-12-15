//
//  MockAPIResponse.swift
//  MatchMate
//
//  Created by Anirudha SM on 15/12/24.
//


// MARK: - Mock API Response
struct APIResponse: Codable {
    let results: [APIUser]

    struct APIUser: Codable {
        let name: APIName
        let dob: APIDob
        let location: APILocation
        let picture: APIPicture

        struct APIName: Codable {
            let first: String
            let last: String
        }

        struct APIDob: Codable {
            let age: Int
        }

        struct APILocation: Codable {
            let city: String
        }

        struct APIPicture: Codable {
            let large: String
        }
    }
}
