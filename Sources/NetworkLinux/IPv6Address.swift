//
//  IPv6Address.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/13/20.
//

import Foundation
import SwiftHexTools

public struct IPv6Address
{
    public var address: String
    public var rawValue: Data
    
    public init?(_ address: String)
    {
        self.address=address

        var result = Data()
        let parts = address.split(separator: ":")
        for part in parts
        {
            var hex = ""
            let missing = 4 - part.count
            for _ in 0..<missing
            {
                hex += "0"
            }
            hex += part
            
            guard let data = Data(hex: hex) else {return nil}
            result += data
        }
        
        self.rawValue = result
    }
    
    public init?(_ rawValue: Data, _ interface: NWInterface? = nil)
    {
        self.address = String(Int(rawValue[0])) + "." + String(Int(rawValue[1])) + "." + String(Int(rawValue[2])) + "." + String(Int(rawValue[3]))
        self.rawValue = rawValue
    }
}

