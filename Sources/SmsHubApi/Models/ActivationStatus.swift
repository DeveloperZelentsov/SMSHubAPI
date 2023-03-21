//
//  File.swift
//  
//
//  Created by Alexey on 21.03.2023.
//

import Foundation

public enum ActivationStatus: Int {
    case smsSent = 1
    case requestAnotherSms = 3
    case activationCompleted = 6
    case cancelActivation = 8
}
