import Foundation

public struct PinnedSpecifier {
    let version: PinnedVersion
    let platformSpecifier: CarthagePlatformSpecifier
}

public struct ResolvedSpecifier {
    let version: PinnedVersion
    let platformSpecifier: CarthagePlatformSpecifier
}

extension ResolvedSpecifier {
    public var description: String {
        if case let .list(platforms) = platformSpecifier {
            return "\(version) @platforms [\(platforms)]"
        } else {
            return "\(version)"
        }
    }
}

public struct Specifier: Equatable {
    let versionSpecifier: VersionSpecifier
    let platformSpecifier: CarthagePlatformSpecifier
    
    public func isSatisfied(byVersion version: PinnedVersion, platform: CarthagePlatform) -> Bool {
        return versionSpecifier.isSatisfied(by: version) && platformSpecifier.isSatisfied(by: platform)
    }
}

//extension Specifier {
//    /// Attempts to parse a semantic version from a PinnedVersion.
//    public static func from(_ specifier: PinnedSpecifier) -> Result<Specifier, ScannableError> {
//        let versionResult = Version.from(specifier.version)
//        if case let .failure(error) = versionResult {
//            return .failure(error)
//        }
//        guard case let .success(version) = versionResult else {
//            return .failure(ScannableError(message: "Unable to retrieve version"))
//        }
//        return .success(Specifier(versionSpecifier: version, PlatformSpecifier: PlatformSpecifier(kind: .list([specifier.platform]))))
//    }
//
//}

