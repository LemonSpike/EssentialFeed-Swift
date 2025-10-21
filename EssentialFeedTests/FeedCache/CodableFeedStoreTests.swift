import EssentialFeed
import Foundation
import XCTest

class CodableFeedStore {
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    completion(.empty)
  }
}

final class CodableFeedStoreTests: XCTestCase {
  
  func testRetrieveDeliversEmptyOnEmptyCache() {
    let sut = CodableFeedStore()
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
}
