import Foundation

public struct URLSessionHTTPClient: HTTPClient {
  private let session: URLSession
  
  public init(session: URLSession = .shared) {
    self.session = session
  }
  
  public func get(from url: URL) async throws -> HTTPClientResult {
    do {
      let (data, response) = try await session.data(from: url)
      guard let response = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
      }
      return .success(data, response)
    } catch {
      return .failure(error)
    }
  }
  
  public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    Task {
      let result = try await get(from: url)
      completion(result)
    }
  }
}
