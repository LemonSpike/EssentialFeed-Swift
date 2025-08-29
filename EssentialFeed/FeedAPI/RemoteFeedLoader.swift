import Foundation

public enum HTTPClientResult {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {

  private let url: URL
  private let client: HTTPClient

  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }

  public enum Result: Equatable {
    case success([FeedItem])
    case failure(Error)
  }

  public init(
    url: URL,
    client: HTTPClient
  ) {
    self.url = url
    self.client = client
  }

  public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
    client.get(from: url) { result in
      switch result {
      case let .success(data, response):
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
          completion(.success(root.items))
        } else {
          completion(.failure(.invalidData))
        }
      case .failure:
          completion(.failure(.connectivity))
      }
    }
  }
}

private struct Root: Decodable {
  let items: [FeedItem]
}

extension FeedItem: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    location = try container.decodeIfPresent(String.self, forKey: .location)
    imageURL = try container.decode(URL.self, forKey: .imageURL)
  }
    
  private enum CodingKeys: String, CodingKey {
    case id, description, location
    case imageURL = "image"
  }
}
