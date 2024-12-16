//
//  MatchViewModelTest.swift
//  MatchMateTests
//
//  Created by Anirudha SM on 16/12/24.
//

import XCTest
import CoreData
@testable import MatchMate

// MARK: - Mock Network Client
protocol MockNetworkClientProtocol {
    func fetchProfiles(completion: @escaping (Result<[APIResponse.APIUser], Error>) -> Void)
}

class MockNetworkClient: NetworkClientProtocol {
    var mockResponse: APIResponse = APIResponse(results: [])
    var shouldFail = false
    
    func fetchProfiles(completion: @escaping (Result<APIResponse, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "NetworkError", code: 500, userInfo: nil)))
        } else {
            completion(.success(mockResponse))
        }
    }
}

// MARK: - Unit Test
class MatchViewModelTests: XCTestCase {
    var viewModel: MatchViewModel!
    var mockNetworkClient: MockNetworkClient!
    var mockContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create an in-memory Core Data stack for each test to ensure isolation
        let container = NSPersistentContainer(name: "MatchMate")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        let expectation = XCTestExpectation(description: "Load persistent store")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Core Data stack failed to load: \(String(describing: error))")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        
        mockContext = container.viewContext
        mockNetworkClient = MockNetworkClient()
        viewModel = MatchViewModel(context: mockContext, networkClient: mockNetworkClient)
    }

    override func tearDown() {
        // Clear out the Core Data context to ensure test isolation
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserProfileEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try mockContext.execute(deleteRequest)
            try mockContext.save()
        } catch {
            print("Failed to clear Core Data context: \(error)")
        }

        viewModel = nil
        mockContext = nil
        mockNetworkClient = nil
        super.tearDown()
    }
    
    func testFetchProfiles_Success() {
        // Prepare mock API data
        let mockUser = APIResponse.APIUser(
            name: APIResponse.APIUser.APIName(first: "John", last: "Doe"),
            dob: APIResponse.APIUser.APIDob(age: 25),
            location: APIResponse.APIUser.APILocation(city: "New York"),
            picture: APIResponse.APIUser.APIPicture(large: "https://example.com/image.jpg")
        )
        let mockResponse = APIResponse(results: [mockUser])
        mockNetworkClient.mockResponse = mockResponse
        
        // Expectation for async API fetch
        let expectation = XCTestExpectation(description: "Fetch profiles from API")
        
        viewModel.fetchProfiles()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.viewModel.profiles.count, 1, "Profiles count should be 1")
            XCTAssertEqual(self.viewModel.profiles[0].name, "John Doe", "Name should match")
            XCTAssertEqual(self.viewModel.profiles[0].age, 25, "Age should match")
            XCTAssertEqual(self.viewModel.profiles[0].location, "New York", "Location should match")
            XCTAssertEqual(self.viewModel.profiles[0].imageURL, "https://example.com/image.jpg", "Image URL should match")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 4)
    }
    
    func testFetchProfiles_Failure() {
        mockNetworkClient.shouldFail = true
        
        let expectation = XCTestExpectation(description: "Handle API failure")
        
        viewModel.fetchProfiles()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.viewModel.profiles.count, 0, "Profiles count should be 0 on API failure")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testUpdateProfileStatus() {
        // Create a test profile
        let userProfile = UserProfile(
            id: UUID(),
            name: "Jane Doe",
            age: 30,
            location: "Los Angeles",
            imageURL: "https://example.com/image2.jpg",
            status: .pending
        )
        viewModel.profiles = [userProfile]
        
        viewModel.updateProfileStatus(userProfile, status: .accepted)
        
        XCTAssertEqual(viewModel.profiles[0].status, .accepted, "Profile status should be updated to accepted")
        
        // Verify Core Data updates
        let fetchRequest: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        let results = try? mockContext.fetch(fetchRequest)
        XCTAssertNotNil(results, "Core Data fetch should not be nil")
        XCTAssertEqual(results?.first?.status, "accepted", "Core Data status should be updated")
    }
    
    func testLoadCachedProfiles() {
        // Insert a profile into Core Data
        let newProfile = UserProfileEntity(context: mockContext)
        newProfile.uuid = UUID()
        newProfile.name = "Cached User"
        newProfile.age = 28
        newProfile.location = "Chicago"
        newProfile.imageURL = "https://example.com/cached.jpg"
        newProfile.status = "pending"
        
        try? mockContext.save()
        
        viewModel.loadCachedProfiles()
        
        XCTAssertEqual(viewModel.profiles.count, 1, "Loaded profiles count should match Core Data")
        XCTAssertEqual(viewModel.profiles[0].name, "Cached User", "Loaded profile name should match")
    }
}
