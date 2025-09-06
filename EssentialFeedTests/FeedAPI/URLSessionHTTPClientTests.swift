import Foundation
import Testing
import EssentialFeed

struct URLSessionHTTPClientTests {
  @Test func testGetFromURLResumesDataTaskWithURL() async throws {
    let url = URL(string: "https://any-url.com")!
    let task = URLSessionDataTaskSpy()
    let session = URLSessionSpy()
    session.stub(url: url, task: task)
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    #expect(task.resumeCallCount == 1)
  }
  
  // MARK: Helpers
  private class URLSessionSpy: URLSession, @unchecked Sendable {
    private(set) var stubs: [URL: URLSessionDataTask] = [:]
    
    func stub(url: URL, task: URLSessionDataTaskSpy) {
      stubs[url] = task
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      return stubs[url] ?? URLSessionDataTaskSpy()
    }
  }

  private class URLSessionDataTaskSpy: URLSessionDataTask, @unchecked Sendable {
    private(set) var resumeCallCount = 0
    
    override func resume() {
      resumeCallCount += 1
    }
  }
}
