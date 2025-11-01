import EssentialFeed
import Foundation
import XCTest

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStore {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
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
    
  }
  
  func testRetrieveHasNoSideEffectsOnNonEmptyCache() {
    
  }
  
  func testRetrieveDeliversFailureOnRetrievalError() {
    
  }
  
  func testRetrieveHasNoSideEffectsOnFailure() {
    
  }
  
  func testInsertDeliversNoErrorOnEmptyCache() {
    
  }
  
  func testInsertDeliversNoErrorOnNonEmptyCache() {
    
  }
  
  func testInsertOverridesPreviouslyInsertedCacheValues() {
    
  }
  
  func testInsertDeliversErrorOnInsertionError() {
    
  }
  
  func testInsertHasNoSideEffectsOnInsertionError() {
    
  }
  
  func testDeleteDeliversNoErrorOnEmptyCache() {
    
  }
  
  func testDeleteHasNoSideEffectsOnEmptyCache() {
    
  }
  
  func testDeleteDeliversNoErrorOnNonEmptyCache() {
    
  }
  
  func testDeleteEmptiesPreviouslyInsertedCache() {
    
  }
  
  func testDeleteDeliversErrorOnDeletionError() {
    
  }
  
  func testDeleteHasNoSideEffectsOnDeletionError() {
    
  }
  
  func testStoreSideEffectsRunSerially() {
    
  }
  
  // - MARK: Helpers
  
  private func makeSUT(
    storeURL: URL? = nil,
    file: StaticString = #file,
    line: UInt = #line
  ) -> FeedStore {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let sut = try! CoreDataFeedStore(bundle: storeBundle)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}
