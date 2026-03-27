import XCTest

final class FeedPresenter {
  init(view: Any) {
    
  }
}

class FeedPresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()
    
    XCTAssertTrue(view.messages.isEmpty, "Expected no messages sent to view upon creation")
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(view: view)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(view, file: file, line: line)
    return (sut, view)
  }
  
  private class ViewSpy {
    let messages: [Any] = []
  }
}
