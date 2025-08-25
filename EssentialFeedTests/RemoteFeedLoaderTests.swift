import Foundation
import Testing

class RemoteFeedLoader {
  func load() {
    HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
  }
}

class HTTPClient {
  static var shared = HTTPClient()

  func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
  override func get(from url: URL) {
    requestedURL = url
  }

  var requestedURL: URL?
}

struct RemoteFeedLoaderTests {
  @Test func testInitDoesNotRequestDataFromURL() async throws {
    let client = HTTPClientSpy()
    HTTPClient.shared = client
    _ = RemoteFeedLoader()

    #expect(client.requestedURL == nil)
  }

  @Test func testLoadRequestsDataFromURL() async throws {
    let client = HTTPClientSpy()
    HTTPClient.shared = client
    let sut = RemoteFeedLoader()

    sut.load()

    #expect(client.requestedURL != nil)
  }
}
