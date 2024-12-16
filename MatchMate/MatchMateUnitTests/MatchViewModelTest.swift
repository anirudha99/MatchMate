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
protocol NetworkClientProtocol {
    func fetchProfiles(completion: @escaping (Result<[APIUser], Error>) -> Void)
}

class MockNetworkClient: NetworkClientProtocol {
    var mockProfiles: [APIUser] = []
    var shouldFail = false
    
    func fetchProfiles(completion: @escaping (Result<[APIUser], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "NetworkError", code: 500, userInfo: nil)))
        } else {
            completion(.success(mockProfiles))
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
        
        // Create an in-memory Core Data stack
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
        viewModel = nil
        mockContext = nil
        mockNetworkClient = nil
        super.tearDown()
    }
    
    func testFetchProfiles_Success() {
        // Prepare mock API data
        let mockUser = APIUser(
            name: Name(first: "John", last: "Doe"),
            dob: DOB(age: 25),
            location: Location(city: "New York"),
            picture: Picture(large: "https://example.com/image.jpg")
        )
        mockNetworkClient.mockProfiles = [mockUser]
        
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
        
        wait(for: [expectation], timeout: 2)
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

