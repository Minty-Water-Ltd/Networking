import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public struct HTTPHeader {
    let field: String
    let value: String

    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}
