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
    do {
      let decoder = JSONDecoder()
      let cache = try decoder.decode(Cache.self, from: data)
      completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    } catch {
      completion(.failure(error))
    }
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
    setupEmptyStoreState()
  }

  override func tearDown() {
    super.tearDown()
    undoStoreSideEffects()
  }
  
  func testRetrieveDeliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toRetrieve: .empty)
  }
  
  func testRetrieveHasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toRetrieveTwice: .empty)
  }
  
  func testRetrieveDeliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed: feed, timestamp: timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func testRetrieveHasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed: feed, timestamp: timestamp), to: sut)
    
    expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
  }
  
  func testRetrieveDeliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieve: .failure(anyNSError()))
  }
  
  func testRetrieveHasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieveTwice: .failure(anyNSError()))
  }
  
  func testInsertOverridesPreviouslyInsertedCacheValus() {
    let sut = makeSUT()
    let firstFeed = uniqueImageFeed().local
    let firstTimestamp = Date()
    
    let firstInsertionError = insert((feed: firstFeed, timestamp: firstTimestamp), to: sut)
    XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
    
    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    let latestInsertionError = insert((feed: latestFeed, timestamp: latestTimestamp), to: sut)
    
    XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
    expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
  }
  
  // - MARK: Helpers
  
  private func makeSUT(
    storeURL: URL? = nil,
    file: StaticString = #file,
    line: UInt = #line
  ) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  @discardableResult
  private func insert(
    _ cache: (feed: [LocalFeedImage], timestamp: Date),
    to sut: CodableFeedStore,
    file: StaticString = #file,
    line: UInt = #line
  ) -> Error? {
    let expectation = self.expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 0.1)
    return insertionError
  }
  
  private func expect(
    _ sut: CodableFeedStore,
    toRetrieve expectedResult: RetrieveCachedFeedResult,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let expectation = self.expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { retrievedResult in
      switch (retrievedResult, expectedResult) {
      case (.empty, .empty),
           (.failure, .failure):
        break
      case let (.found(retrievedFeed, retrievedTimestamp), .found(expectedFeed, expectedTimestamp)):
        XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
        XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
      default:
        XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 0.1)
  }
  
  private func expect(
    _ sut: CodableFeedStore,
    toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
  private func testSpecificStoreURL() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(Self.self).store")
  }
}
