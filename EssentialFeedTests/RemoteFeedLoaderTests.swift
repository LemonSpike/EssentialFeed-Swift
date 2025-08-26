import Foundation
import Testing
import EssentialFeed

struct RemoteFeedLoaderTests {
  @Test func testInitDoesNotRequestDataFromURL() async throws {
    let (_, client) = makeSUT()

    #expect(client.requestedURLs.isEmpty)
  }

  @Test func testLoadRequestsDataFromURL() async throws {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load() { _ in }

    #expect(client.requestedURLs == [url])
  }

  @Test func testLoadTwiceRequestsDataFromURLTwice() async throws {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load() { _ in }
    sut.load() { _ in }

    #expect(client.requestedURLs == [url, url])
  }

  @Test func testLoadDeliversErrorOnClientError() async throws {
    let (sut, client) = makeSUT()

    var capturedErrors: [RemoteFeedLoader.Error] = []
    sut.load() { capturedErrors.append($0) }

    let clientError = NSError(domain: "Test", code: 0)
    client.complete(with: clientError)

    #expect(capturedErrors == [.connectivity])
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (RemoteFeedLoader(url: url, client: client), client)
  }

  private class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] {
      return messages.map { $0.url }
    }

    private var messages: [(url: URL, completion: (Error) -> Void)] = []

    func get(from url: URL, completion: @escaping (Error) -> Void) {
      messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(error)
    }
  }
}
