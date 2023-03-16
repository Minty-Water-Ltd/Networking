import Foundation

// swiftlint:disable convenience_type
public struct URLs {
    public static var base: String {
        if let baseUrl = Bundle.main.infoDictionary?["BASE_URL"] as? String {
            return baseUrl
        }

        return .empty
    }
}

public struct Port {
    public static var base: Int? {
        if let baseUrl = ProcessInfo.processInfo.environment["port"] {
            return Int(baseUrl)
        }

        return nil
    }
}

public enum Paths {
    case custom(String)

    public var rawValue: String {
        switch self {
        case let .custom(string):
            return string
        }
    }
}
