# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

EssentialFeed is a Swift framework implementing Clean Architecture patterns for iOS/macOS development. The project follows the Essential Developer iOS Lead Essentials Course curriculum, focusing on test-driven development and modular architecture.

## Build System & Common Commands

This project uses Xcode's native build system. All commands should be run from the project root directory.

### Building
```bash
# Build the framework
xcodebuild build -project EssentialFeed.xcodeproj -scheme EssentialFeed -destination "platform=macOS"

# Clean build
xcodebuild clean -project EssentialFeed.xcodeproj -scheme EssentialFeed
```

### Testing
```bash
# Run all tests
xcodebuild test -project EssentialFeed.xcodeproj -scheme EssentialFeed -destination "platform=macOS"

# Run specific test
xcodebuild test -project EssentialFeed.xcodeproj -scheme EssentialFeed -destination "platform=macOS" -only-testing:EssentialFeedTests/EssentialFeedTests/example
```

### Xcode Development
```bash
# Open in Xcode
open EssentialFeed.xcodeproj
```

## Architecture & Code Organization

### High-Level Architecture
- **Clean Architecture**: Follows Uncle Bob's Clean Architecture principles with clear separation of concerns
- **Protocol-Oriented Design**: Uses protocols to define boundaries between layers
- **Test-Driven Development**: All features are built using TDD practices

### Directory Structure
```
EssentialFeed/
├── EssentialFeed/                 # Main framework target
│   ├── FeedFeature/              # Feed-related domain logic
│   │   ├── FeedItem.swift        # Feed item model
│   │   └── FeedLoader.swift      # Feed loading protocol & result type
│   ├── EssentialFeed.swift       # Framework entry point (currently empty)
│   └── EssentialFeed.docc/       # Documentation files
└── EssentialFeedTests/           # Test target
    └── EssentialFeedTests.swift  # Test cases
```

### Key Architectural Patterns

**Domain Models**:
- `FeedItem`: Core domain entity representing a feed item with id, description, location, and imageURL
- Models are simple structs with immutable properties

**Use Case Protocols**:
- `FeedLoader`: Defines contract for loading feed items
- Uses custom `LoadFeedResult` enum instead of generic Result type for explicit domain modeling

**Result Handling**:
```swift
enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}
```

**Feature Organization**:
- Features are organized in dedicated directories (e.g., `FeedFeature/`)
- Each feature contains its models, protocols, and implementations
- Clear separation between domain logic and infrastructure concerns

### Testing Framework
- Uses Swift Testing framework (not XCTest)
- Test structure uses `@Test` attributes
- Test classes are structs, not classes
- Import with `import Testing`

### Code Conventions
- Swift 5 with modern Swift features enabled
- Uses Foundation framework for core types
- Protocol-first design for testability and flexibility
- Explicit error types rather than generic Error where possible

## Development Notes
- The project is configured for macOS but uses cross-platform Foundation code
- No external dependencies - pure Swift implementation
- Follows strict TDD cycles: Red-Green-Refactor
- All public APIs should be protocol-based for testability
- Custom result types are preferred over generic Result for domain clarity
