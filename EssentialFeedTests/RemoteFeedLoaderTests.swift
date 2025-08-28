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

    expect(sut, toCompleteWithError: .connectivity) {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: clientError)
    }
  }

  @Test func testLoadDeliversErrorOnHTTPErrorStatusCode() async throws {
    let (sut, client) = makeSUT()

    let samples = [199, 201, 300, 400, 500].enumerated()

    samples.forEach { (index, code) in
      expect(sut, toCompleteWithError: .invalidData) {
        client.complete(withStatusCode: code, at: index)
      }
    }
  }

  @Test func testLoadDeliversErrorOnSuccessHTTPResponseWithInvalidJSON() async throws {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWithError: .invalidData) {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (RemoteFeedLoader(url: url, client: client), client)
  }

  private func expect(
    _ sut: RemoteFeedLoader,
    toCompleteWithError error: RemoteFeedLoader.Error,
    when action: () -> Void
  ) {
    var capturedErrors: [RemoteFeedLoader.Error] = []
    sut.load() { capturedErrors.append($0) }

    action()

    // cannot add file and line params with Swift Testing framework yet
    #expect(capturedErrors == [error])
  }

  private class HTTPClientSpy: HTTPClient {
    private var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []

    var requestedURLs: [URL] {
      return messages.map { $0.url }
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success(data, response))
    }
  }
}
