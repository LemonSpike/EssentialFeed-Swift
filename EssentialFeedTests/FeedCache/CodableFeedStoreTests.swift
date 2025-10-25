import EssentialFeed
import Foundation
import XCTest

final class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
  
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
    
    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }
  
  func testRetrieveHasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }
  
  func testRetrieveDeliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }
  
  func testRetrieveHasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
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
  
  func testInsertDeliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
  }
  
  func testInsertDeliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
  }
  
  func testInsertOverridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    
    assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
  }
  
  func testInsertDeliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    let insertionError = insert((feed: feed, timestamp: timestamp), to: sut)
    
    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
  }
  
  func testInsertHasNoSideEffectsOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed: feed, timestamp: timestamp), to: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func testDeleteDeliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
  }
  
  func testDeleteHasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
  }
  
  func testDeleteDeliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
  }
  
  func testDeleteEmptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    
    assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
  }
  
  func testDeleteDeliversErrorOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
  }
  
  func testDeleteHasNoSideEffectsOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)
    
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func testStoreSideEffectsRunSerially() {
    let sut = makeSUT()
    assertThatSideEffectsRunSerially(on: sut)
  }
  
  // - MARK: Helpers
  
  private func makeSUT(
    storeURL: URL? = nil,
    file: StaticString = #file,
    line: UInt = #line
  ) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
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
    cachesDirectory().appendingPathComponent("\(Self.self).store")
  }
  
  private func cachesDirectory() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
}
