import Foundation

final class FeedItemsMapper {
  private struct Root: Decodable {
    let items: [Item]

    var feedItems: [FeedItem] {
      items.map { $0.feedItem }
    }
  }

  private struct Item: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL

    var feedItem: FeedItem {
      FeedItem(id: id, description: description, location: location, imageURL: image)
    }
  }

  private static let OK_200 = 200

  static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
    guard response.statusCode == OK_200,
          let root = try? JSONDecoder().decode(Root.self, from: data)
    else {
      return .failure(RemoteFeedLoader.Error.invalidData)
    }

    return .success(root.feedItems)
  }
}

