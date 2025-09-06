import Foundation
import Testing
import EssentialFeed

struct URLSessionHTTPClientTests {
  @Test func testGetFromURLResumesDataTaskWithURL() async throws {
    let url = URL(string: "https://any-url.com")!
    let task = URLSessionDataTaskSpy()
    let session = HTTPSessionSpy()
    session.stub(url: url, task: task)
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url) { _ in }
    
    #expect(task.resumeCallCount == 1)
  }

  @Test func testGetFromURLFailsOnRequestError() async throws {
    let url = URL(string: "https://any-url.com")!
    let error = NSError(domain: "Any Error", code: 1)
    let session = HTTPSessionSpy()
    session.stub(url: url, error: error)
    let sut = URLSessionHTTPClient(session: session)
    
    _ = await confirmation("Wait for get completion") { fulfill in
      sut.get(from: url) { result in
        switch result {
        case let .failure(receivedError as NSError):
          #expect(error == receivedError)
        default:
          #expect(Bool(false), "Expected failure with error \(error), got \(result) instead.")
        }
        fulfill()
      }
    }
  }
  
  // MARK: Helpers
  private class HTTPSessionSpy: HTTPSession, @unchecked Sendable {
    private var stubs: [URL: Stub] = [:]
    
    private struct Stub {
      let task: HTTPSessionTask
      let error: Error?
    }
    
    func stub(
      url: URL,
      task: HTTPSessionTask = URLSessionDataTaskSpy(),
      error: Error? = nil
    ) {
      stubs[url] = Stub(task: task, error: error)
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
      guard let stub = stubs[url] else {
        fatalError("Couldn't find stub for \(url)")
      }
      completionHandler(nil, nil, stub.error)
      return stub.task
    }
  }

  private class URLSessionDataTaskSpy: HTTPSessionTask, @unchecked Sendable {
    private(set) var resumeCallCount = 0
    
    func resume() {
      resumeCallCount += 1
    }
  }
}
