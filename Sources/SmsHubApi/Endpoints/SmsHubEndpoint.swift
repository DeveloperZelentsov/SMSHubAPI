//
//  File.swift
//  
//
//  Created by Alexey on 20.03.2023.
//

import Foundation

public enum SmsHubEndpoint {
    case getBalance
    case purchasePhoneNumber(GetNumberRequest)
    case setStatus(id: Int, status: ActivationStatus)
    case getStatus(id: Int)
}

extension SmsHubEndpoint: CustomEndpoint {
    
    public var url: URL? {
        var urlComponents: URLComponents = .default
        urlComponents.queryItems = queryItems
        urlComponents.path = path
        return urlComponents.url
    }
    
    public var queryItems: [URLQueryItem]? {
        var items: [URLQueryItem] = [.init(name: "api_key", value: Constants.apiKey)]
        switch self {
        case .getBalance:
            items.append(.init(name: "action", value: "getBalance"))
        case .purchasePhoneNumber(let request):
            items.append(.init(name: "action", value: "getNumber"))
            items.append(.init(name: "service", value: request.service))
            if let country = request.country {
                items.append(.init(name: "country", value: country.description))
            }
        case .setStatus(let id, let status):
            items.append(.init(name: "action", value: "setStatus"))
            items.append(.init(name: "id", value: id.description))
            items.append(.init(name: "status", value: status.rawValue.description))
        case .getStatus(let id):
            items.append(.init(name: "action", value: "getStatus"))
            items.append(.init(name: "id", value: id.description))
        }
        return items
    }
    
    public var path: String {
        return ""
    }
    
    public var method: HTTPRequestMethods {
        return .get
    }
    
    public var header: [String : String]? {
        return nil
    }
    
    public var body: BodyInfo? {
        return nil
    }
    
    
}
