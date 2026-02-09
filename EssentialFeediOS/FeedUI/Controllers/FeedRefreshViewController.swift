import UIKit

protocol FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
  @IBOutlet public var view: UIRefreshControl?

  var delegate: FeedRefreshViewControllerDelegate?

  // MARK: - FeedLoadingView
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view?.beginRefreshing()
    } else {
      view?.endRefreshing()
    }
  }
  
  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }
}
