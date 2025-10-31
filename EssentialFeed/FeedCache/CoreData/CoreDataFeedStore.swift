import CoreData
import Foundation

public class CoreDataFeedStore: FeedStore {
  
  private let managedObjectModel: NSManagedObjectModel?
  private let bundle: Bundle
  
  public init(storeURL: URL, bundle: Bundle = .main) throws {
    self.managedObjectModel = NSManagedObjectModel(contentsOf: storeURL)
    self.bundle = bundle
  }

  public func retrieve(completion: @escaping RetrievalCompletion) {
      completion(.empty)
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    
  }

  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    
  }
}

private class ManagedCache: NSManagedObject {
  @NSManaged var timestamp: Date
  @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var imageDescription: String?
  @NSManaged var location: String?
  @NSManaged var url: URL
  @NSManaged var cache: ManagedCache
}
