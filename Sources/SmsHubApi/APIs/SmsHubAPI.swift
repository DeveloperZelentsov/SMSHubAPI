//
//  File.swift
//  
//
//  Created by Alexey on 20.03.2023.
//

import Foundation

public protocol ISmsHubAPI: AnyObject {
    /// Retrieves the account balance.
    func getBalance() async throws -> String
    
    /// Buys a phone number with specified parameters.
    /// - Parameter getNumber: A GetNumberRequest object containing the service, operator, and country information.
    ///  - Return: ID, Phone
    func purchasePhoneNumber(by getNumber: GetNumberRequest) async throws -> (Int, Int)
    
    /// Sets the status of an activation.
    /// - Parameters:
    ///   - id: The activation ID received after the request was made buyNumber
    ///   - status: The status to set for the activation.
    func setStatus(id: Int, status: ActivationStatus) async throws -> SetStatusResponse
    
    /// Retrieves the status of an activation.
    /// - Parameter id: The activation ID received after the request was made buyNumber
    func getStatus(id: Int) async throws -> (GetStatusResponse, String?)
    
}

public final class SmsHubAPI: HTTPClient, ISmsHubAPI {
    public init(apiKey: String) {
        Constants.apiKey = apiKey
    }
    
    public func getBalance() async throws -> String {
        let endpoint = SmsHubEndpoint.getBalance
        let result = await sendRequest(endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        if let balance = response.components(separatedBy: ":").last {
            return balance
        }
        throw SMSHubError.badAnswer
    }
    
    public func purchasePhoneNumber(by getNumber: GetNumberRequest) async throws -> (Int, Int) {
        let endpoint = SmsHubEndpoint.purchasePhoneNumber(getNumber)
        let result = await sendRequest(endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        let components = response.components(separatedBy: ":")
        if components.count == 3,
            let id = components[1].toInt(),
            let phone = components[2].toInt() {
            return (id, phone)
        }
        throw SMSHubError.badAnswer
    }
    
    public func setStatus(id: Int, status: ActivationStatus) async throws -> SetStatusResponse {
        let endpoint = SmsHubEndpoint.setStatus(id: id, status: status)
        let result = await sendRequest(endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        if let status = SetStatusResponse(rawValue: response) {
            return status
        }
        throw SMSHubError.badAnswer
    }
    
    public func getStatus(id: Int) async throws -> (GetStatusResponse, String?) {
        let endpoint = SmsHubEndpoint.getStatus(id: id)
        let result = await sendRequest(endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        let components = response.components(separatedBy: ":")
        if components.count == 2,
           let status = GetStatusResponse(rawValue: components[0]) {
            let code: String = components[1]
            return (status, code)
        } else if components.count == 1,
                  let status = GetStatusResponse(rawValue: components[0]) {
            return (status, nil)
        }
        throw SMSHubError.badAnswer
    }
}
