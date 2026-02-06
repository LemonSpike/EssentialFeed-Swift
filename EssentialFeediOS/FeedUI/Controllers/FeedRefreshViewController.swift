import UIKit

protocol FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
  public lazy var view = loadView()

  private let delegate: FeedRefreshViewControllerDelegate

  init(delegate: FeedRefreshViewControllerDelegate) {
    self.delegate = delegate
    super.init()
  }
  
  // MARK: - FeedLoadingView
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }
  
  @objc func refresh() {
    delegate.didRequestFeedRefresh()
  }
  
  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}
