
import Foundation

public protocol HTTPClient: AnyObject {
    func sendRequest<T: Decodable>(session: URLSession,
                                   endpoint: any Endpoint,
                                   responseModel: T.Type) async -> Result<T, HTTPRequestError>
}

public extension HTTPClient { 

    func sendRequest<T: Decodable>(
        session: URLSession = .shared,
        endpoint: any Endpoint,
        responseModel: T.Type
    ) async -> Result<T, HTTPRequestError> {
        guard let url = endpoint.url else {
            return .failure(.invalidURL)
        }
        var request: URLRequest = .init(url: url, timeoutInterval: 30)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        request.httpBody = endpoint.body?.data
        
        do {
            let (data, response) = try await session.data(for: request)
            return handlingDataTask(data: data,
                                    response: response,
                                    error: nil,
                                    responseModel: responseModel)
        } catch {
            return .failure(.request(localizedDiscription: error.localizedDescription))
        }
    }
    
    /// A helper method that handles the response from a request.
    func handlingDataTask<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        responseModel: T.Type
    ) -> Result<T, HTTPRequestError> {
        if let error = error {
            return .failure(.request(localizedDiscription: error.localizedDescription))
        }
        guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {
            return .failure(.noResponse)
        }
        
        switch responseCode {
        case 200...299:
            if let emptyModel = EmptyResponse() as? T {
                return .success(emptyModel)
            }
            if responseModel is Data.Type {
                return .success(responseModel as! T)
            }
            if let decodeData = data?.decode(model: responseModel) {
                return .success(decodeData)
            } else if let data, responseModel is String.Type {
                let response = String(decoding: data, as: UTF8.self)
                let error = SMSHubError.allCases.first { $0.rawValue == response }
                if let error {
                    return .failure(.request(localizedDiscription: error.errorDescription!))
                } else {
                    return .success(response as! T)
                }
            } else {
                return .failure(.decode)
            }
        case 400:
            if let decodeData = data?.decode(model: ValidatorErrorResponse.self) {
                return .failure(.validator(error: decodeData))
            }
            return .failure(.unexpectedStatusCode(code: responseCode,
                                                  localized: responseCode.localStatusCode))
        case 401: return .failure(.unauthorizate)
        default: return .failure(.unexpectedStatusCode(code: responseCode,
                                                       localized: responseCode.localStatusCode))
        }
    }
}
