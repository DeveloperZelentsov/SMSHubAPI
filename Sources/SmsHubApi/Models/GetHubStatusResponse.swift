//
//  File.swift
//  
//
//  Created by Alexey on 21.03.2023.
//

import Foundation

public enum GetHubStatusResponse: String {
    case statusWaitCode = "STATUS_WAIT_CODE"
    case statusWaitRetry = "STATUS_WAIT_RETRY"
    case statusCancel = "STATUS_CANCEL"
    case statusOk = "STATUS_OK"
}
