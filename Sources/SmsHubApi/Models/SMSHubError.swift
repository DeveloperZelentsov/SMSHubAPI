//
//  File.swift
//  
//
//  Created by Alexey on 21.03.2023.
//

import Foundation

public enum SMSHubError: String, LocalizedError, CaseIterable {
    case badKey = "BAD_KEY"
    case errorSQL = "ERROR_SQL"
    case badAction = "BAD_ACTION"
    case noNumbers = "NO_NUMBERS"
    case noBalance = "NO_BALANCE"
    case wrongService = "WRONG_SERVICE"
    case badService = "BAD_SERVICE"
    case noActivation = "NO_ACTIVATION"
    case badAnswer = ""

    public var errorDescription: String? {
        switch self {
        case .badKey:
            return "Invalid API key"
        case .errorSQL:
            return "SQL server error"
        case .badAction:
            return "General incorrect request formation"
        case .noNumbers:
            return "No numbers with the specified parameters, try again later or change the operator/country"
        case .noBalance:
            return "No balance on the API key"
        case .wrongService:
            return "Incorrect service identifier"
        case .badService:
            return "Incorrect service name"
        case .noActivation:
            return "Activation ID does not exist"
        case .badAnswer:
            return "Incorrect answer"
        }
    }
}
