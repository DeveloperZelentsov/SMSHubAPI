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
    /// - Parameter getNumber: A GetHubNumberRequest object containing the service, operator, and country information.
    ///  - Return: ID, Phone
    func purchasePhoneNumber(by getNumber: GetHubNumberRequest) async throws -> (Int, Int)
    
    /// Sets the status of an activation.
    /// - Parameters:
    ///   - id: The activation ID received after the request was made buyNumber
    ///   - status: The status to set for the activation.
    func setStatus(id: Int, status: ActivationStatus) async throws -> SetHubStatusResponse
    
    /// Retrieves the status of an activation.
    /// - Parameter id: The activation ID received after the request was made buyNumber
    func getStatus(id: Int) async throws -> (GetHubStatusResponse, String?)
    
    /// Waits for a code to be received from the server.
    /// - Parameters:
    ///   - id: The activation ID received after the request was made buyNumber
    ///   - attempts: The number of attempts to wait for the code (default is 40). (About 2 minutes)
    ///   - setStatusAfterCompletion: A flag to determine if the activation status should be updated after receiving the code (default is false).
    /// - Returns: The received code as a string.
    func waitForCode(id: Int, attempts: Int, setStatusAfterCompletion: Bool) async throws -> String
    
}

public final class SmsHubAPI: HTTPClient, ISmsHubAPI {
    let urlSession: URLSession
    
    public init(apiKey: String,
                baseScheme: String = Constants.baseScheme,
                baseHost: String = Constants.baseHost,
                path: String = Constants.path,
                urlSession: URLSession = .shared) {
        Constants.apiKey = apiKey
        Constants.baseScheme = baseScheme
        Constants.baseHost = baseHost
        Constants.path = path
        self.urlSession = urlSession
    }
    
    public func getBalance() async throws -> String {
        let endpoint = SmsHubEndpoint.getBalance
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        if let balance = response.components(separatedBy: ":").last {
            return balance
        }
        throw SMSHubError.badAnswer
    }
    
    public func purchasePhoneNumber(by getNumber: GetHubNumberRequest) async throws -> (Int, Int) {
        let endpoint = SmsHubEndpoint.purchasePhoneNumber(getNumber)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        let components = response.components(separatedBy: ":")
        if components.count == 3,
            let id = components[1].toInt(),
            let phone = components[2].toInt() {
            return (id, phone)
        }
        throw SMSHubError.badAnswer
    }
    
    @discardableResult
    public func setStatus(id: Int, status: ActivationStatus) async throws -> SetHubStatusResponse {
        let endpoint = SmsHubEndpoint.setStatus(id: id, status: status)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        if let status = SetHubStatusResponse(rawValue: response) {
            return status
        }
        throw SMSHubError.badAnswer
    }
    
    public func getStatus(id: Int) async throws -> (GetHubStatusResponse, String?) {
        let endpoint = SmsHubEndpoint.getStatus(id: id)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        let components = response.components(separatedBy: ":")
        if components.count == 2,
           let status = GetHubStatusResponse(rawValue: components[0]) {
            let code: String = components[1]
            return (status, code)
        } else if components.count == 1,
                  let status = GetHubStatusResponse(rawValue: components[0]) {
            return (status, nil)
        }
        throw SMSHubError.badAnswer
    }
    
    public func waitForCode(id: Int, attempts: Int = 40, setStatusAfterCompletion: Bool = false) async throws -> String {
        if attempts <= 0 { throw SMSHubError.noCodeReceived }
        let (status, code) = try await getStatus(id: id)
        switch status {
        case .statusOk, .statusWaitRetry:
            guard let code else { throw SMSHubError.badAnswer }
            if setStatusAfterCompletion {
                try await setStatus(id: id, status: .activationCompleted)
            }
            return code
        case .statusWaitCode:
            // Wait for 3 second before retrying
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            return try await waitForCode(id: id, attempts: attempts - 1, setStatusAfterCompletion: setStatusAfterCompletion)
        case .statusCancel:
            if setStatusAfterCompletion {
                try await setStatus(id: id, status: .cancelActivation)
            }
            throw SMSHubError.activationCancelled
        }
    }
}
