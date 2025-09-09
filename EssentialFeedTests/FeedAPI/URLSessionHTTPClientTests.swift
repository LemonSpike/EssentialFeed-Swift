import Foundation
import Testing
import EssentialFeed

@Suite
class URLSessionHTTPClientTests {
  
  init() {
    URLProtocolStub.startInterceptingRequests()
  }
  
  deinit {
    URLProtocolStub.stopInterceptingRequests()
  }
  
  @Test func testGetFromURLPerformsGETRequestWithURL() async throws {
    try await LeakChecker { [weak self] checker in
      guard let self else { return }
      let url = self.anyURL()
      try await confirmation("Wait for request") { fulfill in
        URLProtocolStub.observeRequests { request in
          #expect(request.url == url)
          #expect(request.httpMethod == "GET")
          fulfill()
        }
        
        _ = try await self.makeSUT().get(from: url)
      }
    }
  }
  
  @Test func testGetFromURLFailsOnRequestError() async throws {
    try await LeakChecker { [weak self] checker in
      guard let self else { return }
      let requestError = NSError(domain: "Any Error", code: 1)
      let receivedError = try await resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
      
      #expect(receivedError?.domain == requestError.domain)
      #expect(receivedError?.code == requestError.code)
    }
  }
  
  // `testGetFromURLFailsOnAllNilValues()` is not required because the
  // `get(from: URL)` implementation never returns a `nil` error on failure.
    
  // MARK: Helpers
  
  private func makeSUT(
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
  ) -> URLSessionHTTPClient {
    URLSessionHTTPClient()
  }
  
  private func anyURL() -> URL {
    URL(string: "https://any-url.com")!
  }
  
  private func resultErrorFor(
    data: Data?,
    response: URLResponse?,
    error: Error?,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
  ) async throws -> Error? {
    URLProtocolStub.stub(
      data: data,
      response: response,
      error: error
    )
    
    let sut = self.makeSUT(
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
    
    var receivedError: Error?
    let result = try await sut.get(from: self.anyURL())
    switch result {
    case let .failure(error as NSError):
      receivedError = error
    default:
      let location = SourceLocation(
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      #expect(Bool(false), "Expected failure with error \(error), got \(result) instead.", sourceLocation: location)
    }
    return receivedError
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }
    
    static func stub(
      data: Data?,
      response: URLResponse?,
      error: Error? = nil
    ) {
      stub = Stub(
        data: data,
        response: response,
        error: error
      )
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      request
    }
    
    override func startLoading() {
      guard let stub = URLProtocolStub.stub else {
        client?.urlProtocol(self, didFailWithError: NSError(domain: "URLProtocolStub", code: 1, userInfo: [NSLocalizedDescriptionKey: "No stub available"]))
        client?.urlProtocolDidFinishLoading(self)
        return
      }
      
      if let data = stub.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let response = stub.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      if let error = stub.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
}
