import Foundation

public struct URLSessionHTTPClient {
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
}
