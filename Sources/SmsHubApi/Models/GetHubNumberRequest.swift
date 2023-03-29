//
//  File.swift
//  
//
//  Created by Alexey on 21.03.2023.
//

import Foundation

public struct GetHubNumberRequest: Encodable {
    let service: String
    let country: Int?
    
    public init(service: Service, country: Country? = nil) {
        self.service = service.rawValue
        self.country = country?.rawValue
    }
}
