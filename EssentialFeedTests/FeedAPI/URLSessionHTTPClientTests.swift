import Foundation
import Testing
import EssentialFeed

struct URLSessionHTTPClientTests {
  @Test func testGetFromURLFailsOnRequestError() async throws {
    URLProtocolStub.startInterceptingRequests()
    let url = URL(string: "https://any-url.com")!
    let error = NSError(domain: "Any Error", code: 1)
    URLProtocolStub.stub(
      url: url,
      data: nil,
      response: nil,
      error: error
    )
    let sut = URLSessionHTTPClient()
    
    let result = try await sut.get(from: url)
    switch result {
    case let .failure(receivedError as NSError):
      #expect(error.localizedDescription == receivedError.localizedDescription)
    default:
      #expect(Bool(false), "Expected failure with error \(error), got \(result) instead.")
    }
    URLProtocolStub.stopInterceptingRequests()
  }
  
  // MARK: Helpers
  private class URLProtocolStub: URLProtocol {
    private static var stubs: [URL: Stub] = [:]
    
    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }
    
    static func stub(
      url: URL,
      data: Data?,
      response: URLResponse?,
      error: Error? = nil
    ) {
      stubs[url] = Stub(
        data: data,
        response: response,
        error: error
      )
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stubs = [:]
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      guard let url = request.url else { return false }
      return stubs[url] != nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      request
    }
    
    override func startLoading() {
      guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
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
