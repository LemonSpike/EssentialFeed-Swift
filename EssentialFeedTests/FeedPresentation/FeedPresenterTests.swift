import EssentialFeed
import XCTest

struct FeedViewModel {
  let feed: [FeedImage]
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

struct FeedLoadingViewModel {
  let isLoading: Bool
}

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedErrorViewModel {
  let message: String?
  
  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: nil)
  }
}

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
  private let feedView: FeedView
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView
  
  init(
    loadingView: FeedLoadingView,
    feedView: FeedView,
    errorView: FeedErrorView,
  ) {
    self.loadingView = loadingView
    self.feedView = feedView
    self.errorView = errorView
  }
  
  func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}

class FeedPresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()
    
    XCTAssertTrue(view.messages.isEmpty, "Expected no messages sent to view upon creation")
  }
  
  func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
    let (sut, view) = makeSUT()
    
    sut.didStartLoadingFeed()
    
    XCTAssertEqual(
      view.messages,
      [
        .display(errorMessage: .none),
        .display(isLoading: true)
      ],
      "Expected no error   message when starting to load feed"
    )
  }
  
  func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
    let (sut, view) = makeSUT()
    let feed = uniqueImageFeed().models
    
    sut.didFinishLoadingFeed(with: feed)
    
    XCTAssertEqual(
      view.messages,
      [
        .display(feed: feed),
        .display(isLoading: false)
      ],
      "Expected no error   message when starting to load feed"
    )
  }

  // MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(
      loadingView: view,
      feedView: view,
      errorView: view
    )
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(view, file: file, line: line)
    return (sut, view)
  }
  
  private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
    enum Message: Hashable {
      case display(errorMessage: String?)
      case display(isLoading: Bool)
      case display(feed: [FeedImage])
    }
    
    private(set) var messages: Set<Message> = []
    
    func display(_ viewModel: FeedErrorViewModel) {
      messages.insert(.display(errorMessage: viewModel.message))
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
      messages.insert(.display(isLoading: viewModel.isLoading))
    }
    
    func display(_ viewModel: FeedViewModel) {
      messages.insert(.display(feed: viewModel.feed))
    }
  }
}
