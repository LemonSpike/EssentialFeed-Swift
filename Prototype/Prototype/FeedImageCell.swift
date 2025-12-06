//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Pranav Kasetti on 06/12/2025.
//

import UIKit

class FeedImageCell: UITableViewCell {
  @IBOutlet private(set) var locationContainer: UIView!
  @IBOutlet private(set) var locationLabel: UILabel!
  @IBOutlet private(set) var feedImageContainer: UIView!
  @IBOutlet private(set) var feedImageView: UIImageView!
  @IBOutlet private(set) var descriptionLabel: UILabel!

  func configure(with model: FeedImageViewModel) {
    locationLabel.text = model.location
    locationContainer.isHidden = model.location == nil

    descriptionLabel.text = model.description
    descriptionLabel.isHidden = model.description == nil

    feedImageView.image = UIImage(named: model.imageName)
  }
}
