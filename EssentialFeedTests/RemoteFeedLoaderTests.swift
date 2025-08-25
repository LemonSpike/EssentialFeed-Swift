import Foundation
import Testing

class RemoteFeedLoader {
}

class HTTPClient {
  var requestedURL: URL?
}

struct RemoteFeedLoaderTests {
    @Test func testInitDoesNotRequestDataFromURL() async throws {
      let client = HTTPClient()
      _ = RemoteFeedLoader()

      #expect(client.requestedURL == nil)
    }
}
