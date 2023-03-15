import Foundation

public protocol APIRequest {
    var method: HTTPMethod { get }
    var path: String? { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [HTTPHeader]? { get }
    var body: Data? { get }
    var baseURL: String { get }
    var port: Int? { get }

    associatedtype DecodableData

    func urlRequest() throws -> URLRequest
}

public class NetworkAPIRequest<T: Decodable>: APIRequest {
    public let method: HTTPMethod
    public let path: String?
    public var queryItems: [URLQueryItem]?
    public let headers: [HTTPHeader]?
    public var body: Data?
    public let baseURL: String = URLs.base
    public let port: Int?

    private let urlSession: URLSession

    public typealias DecodableData = T

    public init(method: HTTPMethod,
         path: Paths? = nil,
         port: Int? = nil,
         headers: [String: String] = [:],
         urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.method = method
        self.path = path?.rawValue
        self.port = port

        var httpHeaders = [HTTPHeader]()
        headers.forEach { httpHeaders.append(HTTPHeader(field: $0.key, value: $0.value)) }
        httpHeaders.append(HTTPHeader(field: "Content-Type", value: "application/json"))

        self.headers = httpHeaders
    }

    public func urlRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.host = baseURL
        urlComponents.port = port
        urlComponents.path = path ?? ""
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw NetworkingError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body

        headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }

        return urlRequest
    }

    func execute() async throws -> DecodableData {
        let request = try urlRequest()

        let (data, response) = try await urlSession.data(for: request)

        if let response = response as? HTTPURLResponse {
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                debugPrint("Networking error: \(String(data: data, encoding: .utf8) ?? "")")
                throw NetworkingError.errorStatusCode(response.statusCode,
                                                      String(data: data, encoding: .utf8) ?? .empty)
            }
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(DecodableData.self, from: data)
        } catch {
            debugPrint("""
                       JSON decoding error: \(error.localizedDescription)
                       Data was: \(String(data: data, encoding: .utf8) ?? "")
                       """)
            throw error
        }
    }
}
