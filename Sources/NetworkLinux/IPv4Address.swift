//
//  IPv4Address.swift
//  Transport
//
//  Created by Brandon Wiley on 6/12/18.
//

import Foundation

public struct IPv4Address
{
    public var address: String
    
    public init?(_ address: String)
    {
        self.address=address
    }
    
    public init?(_ rawValue: Data, _ interface: NWInterface? = nil)
    {
        self.address = String(Int(rawValue[0])) + "." + String(Int(rawValue[1])) + "." + String(Int(rawValue[2])) + "." + String(Int(rawValue[3]))
    }
}
