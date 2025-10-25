import EssentialFeed
import Foundation
import XCTest

class CodableFeedStore {
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var localFeed: [LocalFeedImage] {
      return feed.map { $0.local }
    }
  }
  
  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL
    
    init(from localFeedImage: LocalFeedImage) {
      id = localFeedImage.id
      description = localFeedImage.description
      location = localFeedImage.location
      url = localFeedImage.url
    }
    
    var local: LocalFeedImage {
      LocalFeedImage(
        id: id,
        description: description,
        location: location,
        url: url
      )
    }
  }
  
  private let storeURL: URL
  
  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }
    
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
    let encoded = try? encoder.encode(cache)
    try? encoded?.write(to: storeURL)
    completion(nil)
  }
}

final class CodableFeedStoreTests: XCTestCase {

  override func setUp() {
    super.setUp()
  
    let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    try? FileManager.default.removeItem(at: storeURL)
  }

  override func tearDown() {
    super.tearDown()
    
    let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    try? FileManager.default.removeItem(at: storeURL)
  }
  
  func testRetrieveDeliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    let expectation = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { result in
      switch result {
      case .empty:
        break
      default:
        XCTFail("Expected empty result, got \(result) instead")
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 0.1)
  }
  
  func testRetrieveHasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    let expectation = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
        case (.empty, .empty):
          break
        default:
          XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
        }
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 0.1)
  }
  
  func testRetrieveAfterInsertingToEmptyCacheDeliversInsertedValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    let expectation = expectation(description: "Wait for cache retrieval")
    
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
      
      sut.retrieve { retrieveResult in
        switch (retrieveResult) {
        case let .found(feed: retrievedFeed, timestamp: retrievedTimestamp):
          XCTAssertEqual(retrievedFeed, feed, "Expected to retrieve inserted feed")
          XCTAssertEqual(retrievedTimestamp, timestamp, "Expected to retrieve inserted timestamp")
        default:
          XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
        }
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 0.1)
  }
  
  // - MARK: Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
    let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    let sut = CodableFeedStore(storeURL: storeURL)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}
