import Foundation
import Testing
import EssentialFeed

struct URLSessionHTTPClientTests {
  @Test func testGetFromURLCreatesDataTaskWithURL() async throws {
    let url = URL(string: "https://any-url.com")!
    let session = URLSessionSpy()
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    #expect(session.receivedURLs == [url])
  }
  
  // MARK: Helpers
  private class URLSessionSpy: URLSession, @unchecked Sendable {
    private(set) var receivedURLs: [URL] = []
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      receivedURLs.append(url)
      return HTTPSessionTaskSpy()
    }
  }

  private class HTTPSessionTaskSpy: URLSessionDataTask, @unchecked Sendable { }
}
