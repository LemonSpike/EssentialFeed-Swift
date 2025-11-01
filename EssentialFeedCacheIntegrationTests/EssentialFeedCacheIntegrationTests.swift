import EssentialFeed
import XCTest

final class EssentialFeedCacheIntegrationTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    undoStoreSideEffects()
  }
  
  func testLoadDeliversNoItemsOnEmptyCache() {
    let sut = makeSUT()

    let expectation = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
      case let .success(items):
        XCTAssertEqual(items, [], "Expected empty feed result")
      case let .failure(error):
        XCTFail("Expected successful feed result, got \(error) instead")
      @unknown default:
        XCTFail("Unexpected case")
      }
      
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 0.1)
  }
  
  // MARK: - Helpers
  private func makeSUT(
    file: StaticString = #file,
    line: UInt = #line
  ) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(store, file: file, line: line)
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
