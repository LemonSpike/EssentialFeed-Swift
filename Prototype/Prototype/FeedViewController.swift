//
//  FeedViewController.swift
//  Prototype
//
//  Created by Pranav Kasetti on 06/12/2025.
//

import UIKit

class FeedViewController: UITableViewController {
  private var viewAppeared = false
  private var feed: [FeedImageViewModel] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    if !viewAppeared {
      refresh()
      viewAppeared = true
    }
    // tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
  }
  
  @IBAction private func refresh() {
    refreshControl?.beginRefreshing()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      guard let self = self else { return }
      if self.feed.isEmpty {
        self.feed = FeedImageViewModel.prototypeFeed
        self.tableView.reloadData()
      }
      self.refreshControl?.endRefreshing()
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    feed.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as? FeedImageCell else {
      return UITableViewCell()
    }
    let model = feed[indexPath.row]
    cell.configure(with: model)
    return cell
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    16
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    16
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return UIView()
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}

