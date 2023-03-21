//
//  File.swift
//  
//
//  Created by Alexey on 21.03.2023.
//

import Foundation

public enum SetStatusResponse: String {
    case accessReady = "ACCESS_READY"
    case accessRetryGet = "ACCESS_RETRY_GET"
    case accessActivation = "ACCESS_ACTIVATION"
    case accessCancel = "ACCESS_CANCEL"
}
