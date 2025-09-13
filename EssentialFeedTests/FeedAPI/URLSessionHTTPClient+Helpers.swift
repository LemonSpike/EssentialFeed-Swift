import EssentialFeed
import Foundation

extension HTTPClient {
  func get(from url: URL) async throws -> HTTPClientResult {
    try await withCheckedThrowingContinuation { continuation in
      get(from: url) { result in
        continuation.resume(returning: result)
      }
    }
  }
}
