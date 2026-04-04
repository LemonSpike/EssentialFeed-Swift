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
    FeedErrorViewModel(message: nil)
  }
  
  static func error(message: String) -> FeedErrorViewModel {
    FeedErrorViewModel(message: message)
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
  
  static var title: String {
    return NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: Bundle(for: FeedPresenter.self),
      comment: "Title for the feed view"
    )
  }
  
  private var feedLoadError: String {
    return NSLocalizedString(
      "FEED_VIEW_CONNECTION_ERROR",
      tableName: "Feed",
      bundle: Bundle(for: FeedPresenter.self),
      comment: "Error message displayed when we can't load the image feed from the server"
    )
  }
  
  func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}

class FeedPresenterTests: XCTestCase {

  func test_title_isLocalized() {
    XCTAssertEqual(
      FeedPresenter.title,
      localized("FEED_VIEW_TITLE"),
      "Expected title to be localized"
    )
  }
  
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
      "Expected no error message when starting to load feed"
    )
  }
  
  func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
    let (sut, view) = makeSUT()
    
    sut.didFinishLoadingFeed(with: anyNSError())
    
    XCTAssertEqual(
      view.messages,
      [
        .display(
          errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")
        ),
        .display(isLoading: false)
      ],
      "Expected error message and stop loading when finishing loading feed with error"
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
  
  private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(
      forKey: key,
      value: nil,
      table: table
    )
    
    if value == key {
      XCTFail("Missing localized string for key: \(key)", file: file, line: line)
    }
    
    return value
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
