import Foundation

/// Represents a platform.
public struct CarthagePlatform: Equatable, Hashable {
    public static let knownPlatforms: Set<CarthagePlatform> = [.macOS, .iOS, .tvOS, .watchOS, .linux, .macCatalyst]

    /// The name of the platform.
    public let name: String
    
    internal let aliases: Set<String>
    
    /// Create a platform.
    private init(name: String, aliases: Set<String> = []) {
        self.name = name
        self.aliases = aliases
    }
    
    public static func == (lhs: CarthagePlatform, rhs: CarthagePlatform) -> Bool {
        return lhs.name == rhs.name
    }
    
    public static let macOS: CarthagePlatform = CarthagePlatform(name: "macos")
    public static let iOS: CarthagePlatform = CarthagePlatform(name: "ios")
    public static let tvOS: CarthagePlatform = CarthagePlatform(name: "tvos")
    public static let watchOS: CarthagePlatform = CarthagePlatform(name: "watchos")
    public static let linux: CarthagePlatform = CarthagePlatform(name: "linux")
    public static let macCatalyst: CarthagePlatform = CarthagePlatform(name: "maccatalyst", aliases: ["uikitForMac"])
}

extension CarthagePlatform {
    public var description: String {
        return name
    }
}

extension CarthagePlatform {
    public static func from(_ scanner: Scanner) -> Result<CarthagePlatform, ScannableError> {
        let caseSensitive = scanner.caseSensitive
        defer {
            scanner.caseSensitive = caseSensitive
        }
        scanner.caseSensitive = false
        let knownPlatforms = CarthagePlatform.knownPlatforms
        guard let platform = knownPlatforms.first(where: { (platform) -> Bool in
            if scanner.scanString(platform.name, into: nil) {
                return true
            }
            return platform.aliases.firstIndex(where: { (alias) -> Bool in
                scanner.scanString(alias, into: nil)
            }) != nil
        }) else {
            return .failure(ScannableError(message: "valid platform name not found"))
        }
        
        return .success(platform)
    }
}

public struct PinnedCarthagePlatform {
    public let platform: CarthagePlatform
    
    public init(_ platform: CarthagePlatform) {
        self.platform = platform
    }
}

extension PinnedCarthagePlatform {
    public static func from(_ scanner: Scanner) -> Result<PinnedCarthagePlatform, ScannableError> {
        let platform = CarthagePlatform.from(scanner)
        if case let .failure(error) = platform {
            return .failure(error)
        }
        return .success(PinnedCarthagePlatform(try! platform.get()))
    }
}

extension PinnedCarthagePlatform: CustomStringConvertible {
    public var description: String {
        return "\(platform)"
    }
}

/// Describes which platform(s) are acceptable for satisfying a dependency
/// requirement.
public enum CarthagePlatformSpecifier: Hashable {
    case none
    case list(Set<CarthagePlatform>)
    
    /// Determines whether the given platform satisfies this platform specifier.
    public func isSatisfied(by platform: CarthagePlatform) -> Bool {
        switch self {
        case .none:
            return true
            
        case let .list(platformSet):
            return platformSet.contains(platform)
        }
    }
}

extension CarthagePlatformSpecifier {
    public static func from(_ scanner: Scanner) -> Result<CarthagePlatformSpecifier, ScannableError> {
        guard scanner.scanString("@platforms", into: nil) else {
            return .success(.none)
        }
        guard scanner.scanString("[", into: nil) else {
            return .failure(ScannableError(message: "list of platforms not found"))
        }
        
        var platforms = Set<CarthagePlatform>()
        while true {
            let platform = CarthagePlatform.from(scanner)
            if case let .failure(error) = platform {
                return .failure(error)
            }
            platforms.insert(try! platform.get())
            if scanner.scanString("]", into: nil) {
                break
            }
            if !scanner.scanString(",", into: nil) {
                return .failure(ScannableError(message: "syntax error in platforms list"))
            }
        }
        
        return .success(.list(platforms))
    }
}

extension CarthagePlatformSpecifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return ""
            
        case let .list(platforms):
            return "@platforms [\(platforms)]"
        }
    }
}
