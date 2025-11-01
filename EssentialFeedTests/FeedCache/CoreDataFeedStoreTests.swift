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
    let sut = makeSUT()
    
    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }
  
  func testRetrieveHasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
  }
  
  func testRetrieveDeliversFailureOnRetrievalError() {
    
  }
  
  func testRetrieveHasNoSideEffectsOnFailure() {
    
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
    
  }
  
  func testInsertHasNoSideEffectsOnInsertionError() {
    
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
    let storeURL = URL(fileURLWithPath: "/dev/null")
    let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}
