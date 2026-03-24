import XCTest

final class FeedPresenter {
  init(view: Any) {
    
  }
}

class FeedPresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let view = ViewSpy()
    
    XCTAssertTrue(view.messages.isEmpty, "Expected no messages sent to view upon creation")
  }

  // MARK: - Helpers
  
  private class ViewSpy {
    let messages: [Any] = []
  }
}
