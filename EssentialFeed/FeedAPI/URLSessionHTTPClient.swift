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
      guard data.count > 0 else {
        throw URLError(.zeroByteResource)
      }
      return .success(data, response)
    } catch {
      return .failure(error)
    }
  }
}
