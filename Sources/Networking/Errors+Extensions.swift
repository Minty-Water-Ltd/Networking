public enum NetworkingError: Error {
    case invalidURL
    case missingData
    case errorStatusCode(Int, String)

    public var desscription: String {
        switch self {
        case let .errorStatusCode(statusCode, desscription):
            return "\(statusCode) - \(desscription)"
        default:
            return ""
        }
    }
}
