//
//  NetworkClient.swift
//  MatchMate
//
//  Created by Anirudha SM on 16/12/24.
//

import Foundation
import Alamofire

protocol NetworkClientProtocol {
    func fetchProfiles(completion: @escaping (Result<APIResponse, Error>) -> Void)
}

class NetworkClient: NetworkClientProtocol {
    func fetchProfiles(completion: @escaping (Result<APIResponse, Error>) -> Void) {
        let url = "https://randomuser.me/api/?results=10"
        AF.request(url)
            .validate()
            .responseDecodable(of: APIResponse.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
